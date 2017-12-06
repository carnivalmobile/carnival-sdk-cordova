//
//  CarnivalPhonegapPlugin.m
//  CarnivalPhonegapPlugin
//
//  Created by Carnival.io
//
//

#import "CarnivalCordovaPlugin.h"
#import <Carnival/Carnival.h>
#import <Cordova/CDVConfigParser.h>
#import <WebKit/WebKit.h>

@interface CarnivalMessage ()

- (nullable instancetype)initWithDictionary:(nonnull NSDictionary *)dictionary;
- (nonnull NSDictionary *)dictionary;

@end

@interface Carnival ()
+ (void)setWrapperName:(NSString *)wrapperName andVersion:(NSString *)wrapperVersion;
@end

@interface CarnivalCordovaPlugin () <CarnivalMessageStreamDelegate>

@property (strong, nonatomic) NSDictionary *settings;
@property (strong, nonatomic) UINavigationController *streamNavigationController;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) CDVInvokedUrlCommand *onInAppNotificationDisplayListenerCommand;
@property (strong, nonatomic) CDVInvokedUrlCommand *onMessageDetailDisplayListenerCommand;
@property (strong, nonatomic) NSNumber *displayInAppNotifs;

@end

@implementation CarnivalCordovaPlugin

#pragma mark - setup

- (void)setup {
    if(_displayInAppNotifs == nil) {
        _displayInAppNotifs = [NSNumber numberWithBool:YES];
    }
    [self addNotificationObservers];
}

#pragma mark - notifications

- (void)addNotificationObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(unreadCountDidChange:)
                                                 name:CarnivalMessageStreamUnreadMessageCountDidChangeNotification
                                               object:nil];
}

- (void)removeNotificationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:CarnivalMessageStreamUnreadMessageCountDidChangeNotification
                                                  object:nil];
}

- (void)unreadCountDidChange:(NSNotification *)notification {
    if (notification) {
        NSNumber *unreadCount = notification.userInfo[CarnivalMessageStreamUnreadCountKey];

        if (unreadCount) {
            NSString *formatString = @" var event = new CustomEvent('unreadcountdidchange', { detail : {'unreadCount': %i }});" \
                                     "  document.dispatchEvent(event);";

            NSString *JSString = [NSString stringWithFormat:formatString, [unreadCount integerValue]];
            if ([self.webView respondsToSelector:@selector(stringByEvaluatingJavaScriptFromString:)]) {
                // Cordova-iOS pre-4
                [self.webView performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:JSString waitUntilDone:NO];
            } else {
                // Cordova-iOS 4+
                dispatch_async(dispatch_get_main_queue(), ^{
                    WKWebView *webView = (WKWebView *)self.webView;
                    [webView evaluateJavaScript:JSString completionHandler:NULL];
                });
            }
        }
    }
}

# pragma mark - delegates
- (BOOL)shouldPresentInAppNotificationForMessage:(CarnivalMessage *)message {
    NSError *error;
    NSString *formatString;
    NSString *JSString;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[message dictionary] options:0 error:&error];

    if (error) {
        formatString = @"var event = new CustomEvent('inappnotification', {detail: {error: '%@'}});document.dispatchEvent(event);";
        JSString = [NSString stringWithFormat:formatString, [error localizedDescription]];
    } else {
        formatString = @"var event = new CustomEvent('inappnotification', {detail: {message: %@}});document.dispatchEvent(event);";
        NSString *json = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        JSString = [NSString stringWithFormat:formatString, json];
    }

    if ([self.webView respondsToSelector:@selector(stringByEvaluatingJavaScriptFromString:)]) {
        // Cordova-iOS pre-4
        [self.webView performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:JSString waitUntilDone:NO];
    } else {
        // Cordova-iOS 4+
        dispatch_async(dispatch_get_main_queue(), ^{
            WKWebView *webView = (WKWebView *)self.webView;
            [webView evaluateJavaScript:JSString completionHandler:NULL];
        });
    }

    return [_displayInAppNotifs boolValue];
}

#pragma mark - overriden getters/setters

- (void)setDisplayInAppNotifications:(CDVInvokedUrlCommand *)command {
    if (command.arguments.count > 0) {
        BOOL value = [command.arguments[0] boolValue];
        _displayInAppNotifs = [NSNumber numberWithBool:value];
    }
}

- (NSDictionary *)settings {
    if (!_settings) {
        _settings = [self settingsFromConfigFile];
    }

    return _settings;
}

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"YYYY-MM-dd'T'HH:mm:ss.SSSZ";
    }

    return _dateFormatter;
}

#pragma mark - start engine

- (void)startEngine:(CDVInvokedUrlCommand *)command {
    NSArray *arguments = command.arguments;

    if ([arguments count] > 0)
    {
        [self setup];

        __block BOOL registerForPush = [command.arguments[0] boolValue];

        NSString *appKey = self.settings[@"carnival_ios_app_key"];
        [self.commandDelegate runInBackground:^{

            [Carnival startEngine:appKey registerForPushNotifications:registerForPush];
            [CarnivalMessageStream setDelegate:self];
            [Carnival setWrapperName:@"Cordova" andVersion:@"4.0.2"];

            [self sendPluginResultWithStatus:CDVCommandStatus_OK forCommand:command];
       }];
    }
}

#pragma mark - custom events

- (void)logEvent:(CDVInvokedUrlCommand *)command {
    if ([command.arguments count] > 0) {
        NSString *eventName = command.arguments[0];

        if (eventName && [eventName isKindOfClass:[NSString class]]) {
            [Carnival logEvent:eventName];
        }
    }
}

#pragma mark - customizing in-app notifications
- (void)setOnInAppNotificationDisplayListener:(CDVInvokedUrlCommand *)command {
    _onInAppNotificationDisplayListenerCommand = command;
}

- (void)setOnMessageDetailDisplayListener:(CDVInvokedUrlCommand *)command {
    _onMessageDetailDisplayListenerCommand = command;
}


#pragma mark - pressed actions

- (void)closeButtonPressed:(UIButton *)button {
    [self.streamNavigationController dismissViewControllerAnimated:YES completion:^{
        self.streamNavigationController = nil;
    }];
}

#pragma mark - location

- (void)updateLocation:(CDVInvokedUrlCommand *)command {
    NSArray *arguments = command.arguments;

    if ([arguments count] > 1) {
        double lat = [command.arguments[0] doubleValue];
        double lon = [command.arguments[1] doubleValue];

        [self.commandDelegate runInBackground:^{
            CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
            [Carnival updateLocation:location];
        }];
    }
}

#pragma mark - clear device data
- (void)clearDevice:(CDVInvokedUrlCommand *)command {
    NSArray *arguments = command.arguments;

    [self.commandDelegate runInBackground:^{
        if ([arguments count] < 1) {
            return;
        }

        if ([command.arguments[0] isKindOfClass:[NSNumber class]]) {
            int clearValues = [command.arguments[0] intValue];
            [Carnival clearDeviceData:clearValues withResponse:^(NSError * _Nullable error) {
                [self sendPluginResultWithPossibleError:error forCommand:command];
            }];
        }
    }];
}

#pragma mark - custom attributes

- (void)setAttributes:(CDVInvokedUrlCommand *)command {
    NSArray *arguments = command.arguments;
    if ([arguments count] < 1) {
        return;
    }

    NSDictionary *attributeMap = arguments[0];

    CarnivalAttributes *carnivalAttributeMap = [[CarnivalAttributes alloc] init];

    [carnivalAttributeMap setAttributesMergeRule:(CarnivalAttributesMergeRule)[attributeMap valueForKey:@"mergeRule"]];

    NSDictionary *attributes = [attributeMap valueForKey:@"attributes"];

    for (NSString *key in attributes) {
        NSString *type = [[attributes valueForKey:key] valueForKey:@"type"];

        if ([type isEqualToString:@"string"]) {
            NSString *value = [[attributes valueForKey:key] valueForKey:@"value"];
            [carnivalAttributeMap setString:value forKey:key];

        } else if ([type isEqualToString:@"stringArray"]) {
            NSArray<NSString *> *value = [[attributes valueForKey:key] valueForKey:@"value"];
            [carnivalAttributeMap setStrings:value forKey:key];

        } else if ([type isEqualToString:@"integer"]) {
            NSNumber *value = [[attributes valueForKey:key] objectForKey:@"value"];
            [carnivalAttributeMap setInteger:[value integerValue] forKey:key];

        } else if ([type isEqualToString:@"integerArray"]) {
            NSArray<NSNumber *> *value = [[attributes valueForKey:key] valueForKey:@"value"];
            [carnivalAttributeMap setIntegers:value forKey:key];

        } else if ([type isEqualToString:@"boolean"]) {
            NSNumber *dictionaryValue = [[attributes valueForKey:key] valueForKey:@"value"];
            BOOL value = [dictionaryValue boolValue];
            [carnivalAttributeMap setBool:value forKey:key];

        } else if ([type isEqualToString:@"float"]) {
            NSNumber *numberValue = [[attributes valueForKey:key] objectForKey:@"value"];
            [carnivalAttributeMap setFloat:[numberValue floatValue] forKey:key];

        } else if ([type isEqualToString:@"floatArray"]) {
            NSArray<NSNumber *> *value = [[attributes valueForKey:key] objectForKey:@"value"];
            [carnivalAttributeMap setFloats:value forKey:key];

        } else if ([type isEqualToString:@"date"]) {
            NSNumber *millisecondsValue = [[attributes valueForKey:key] objectForKey:@"value"];
            NSNumber *value = @([millisecondsValue doubleValue] / 1000);

            if (![value isKindOfClass:[NSNumber class]]) {
                return;
            }

            NSDate *date = [NSDate dateWithTimeIntervalSince1970:[value doubleValue]];
            if (date) {
                [carnivalAttributeMap setDate:date forKey:key];
            } else {
                return;
            }

        } else if ([type isEqualToString:@"dateArray"]) {
            NSArray<NSNumber *> *value = [[attributes valueForKey:key] objectForKey:@"value"];
            NSMutableArray<NSDate *> *dates = [[NSMutableArray alloc] init];
            for (NSNumber *millisecondsValue in value) {
                NSNumber *secondsValue = @([millisecondsValue doubleValue] / 1000);

                if (![secondsValue isKindOfClass:[NSNumber class]]) {
                    continue;
                }

                NSDate *date = [NSDate dateWithTimeIntervalSince1970:[secondsValue doubleValue]];
                if (date) {
                    [dates addObject:date];
                }
            }

            [carnivalAttributeMap setDates:dates forKey:key];
        }

        [self.commandDelegate runInBackground:^{
            [Carnival setAttributes:carnivalAttributeMap withResponse:^(NSError * _Nullable error) {
                [self sendPluginResultWithPossibleError:error forCommand:command];
            }];
        }];

    }
}

- (void)removeAttribute:(CDVInvokedUrlCommand *)command {
    NSArray *arguments = command.arguments;

    if ([arguments count] > 0) {
        NSString *key = arguments[0];

        if ([key isKindOfClass:[NSString class]]) {
            [self.commandDelegate runInBackground:^{
                [Carnival removeAttributeWithKey:key withResponse:^(NSError *error) {
                    [self sendPluginResultWithPossibleError:error forCommand:command];
                }];
            }];
        }
    }
}

#pragma mark - messages

- (void)messages:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        [CarnivalMessageStream messages:^(NSArray *messages, NSError *error) {
            CDVPluginResult *result = nil;

            if (!error) {
                NSMutableArray *array = [NSMutableArray array];

                for (CarnivalMessage *message in messages) {
                    [array addObject:[message dictionary]];
                }

                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:array];
            }
            else {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            }

            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }];
    }];
}

- (void)removeMessage:(CDVInvokedUrlCommand *)command {
    NSArray *arguments = command.arguments;

    if (arguments.count > 0) {
        NSDictionary *messageDict = arguments[0];

        if ([messageDict isKindOfClass:[NSDictionary class]]) {
            CarnivalMessage *message = [[CarnivalMessage alloc] initWithDictionary:messageDict];

            if (message) {
                [CarnivalMessageStream removeMessage:message withResponse:^(NSError *error){
                    [self sendPluginResultWithPossibleError:error forCommand:command];
                }];
            }
        }
    }
}

#pragma mark - present/dismiss message detail

- (void)presentMessageDetail:(CDVInvokedUrlCommand *)command {
    NSArray *arguments = command.arguments;

    if (arguments.count > 0) {
        CarnivalMessage *message = [[CarnivalMessage alloc] initWithDictionary:arguments[0]];

        if (message) {
            [CarnivalMessageStream presentMessageDetailForMessage:message];
        }
    }
}

- (void)dismissMessageDetail:(CDVInvokedUrlCommand *)command {
    [CarnivalMessageStream dismissMessageDetail];
}

#pragma mark - unread count

- (void)unreadCount:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        [CarnivalMessageStream unreadCount:^(NSUInteger unreadCount, NSError *error) {
            [self sendPluginResultWithPossibleError:error andInt:unreadCount forCommand:command];
        }];
    }];
}

#pragma mark - register impressions

- (void)registerImpression:(CDVInvokedUrlCommand *)command {
    NSArray *arguments = command.arguments;

    if (arguments.count > 1) {
        CarnivalImpressionType type = [arguments[0] integerValue];
        NSDictionary *messageDict = arguments[1];

        CarnivalMessage *message = [[CarnivalMessage alloc] initWithDictionary:messageDict];

        if (message) {
            [CarnivalMessageStream registerImpressionWithType:type forMessage:message];
        }
    }
}

#pragma mark - marking messages as read

- (void)markMessageAsRead:(CDVInvokedUrlCommand *)command {
    NSArray *arguments = command.arguments;

    if (arguments.count > 0) {
        NSDictionary *messageDict = arguments[0];
        CarnivalMessage *message = [[CarnivalMessage alloc] initWithDictionary:messageDict];

        if (message) {
            [CarnivalMessageStream markMessageAsRead:message withResponse:^(NSError *error) {
                [self sendPluginResultWithPossibleError:error forCommand:command];
            }];
        }
    }
}

- (void)markMessagesAsRead:(CDVInvokedUrlCommand *)command {
    NSArray *arguments = command.arguments;

    if (arguments.count > 0) {
        NSMutableArray *messages = [NSMutableArray array];

        for (NSDictionary *messageDict in arguments) {
            if ([messageDict isKindOfClass:[NSDictionary class]]) {
                CarnivalMessage *message = [[CarnivalMessage alloc] initWithDictionary:messageDict];

                if (message) {
                    [messages addObject:message];
                }
            }
        }

        if (messages.count > 0) {
            [CarnivalMessageStream markMessagesAsRead:messages withResponse:^(NSError *error){
                [self sendPluginResultWithPossibleError:error forCommand:command];
            }];
        }
        else {
            [self sendPluginResultWithStatus:CDVCommandStatus_OK forCommand:command];
        }
    }
}

#pragma mark - users

- (void)setUserId:(CDVInvokedUrlCommand *)command {
    NSArray *arguments = command.arguments;

    if (arguments.count > 0) {
        NSString *userID = arguments[0];

        if ([userID isKindOfClass:[NSString class]] || [userID isKindOfClass:[NSNull class]]) {
            [self.commandDelegate runInBackground:^{
                if ([userID isKindOfClass:[NSNull class]]) {
                    [Carnival setUserId:nil withResponse:^(NSError *error) {
                        [self sendPluginResultWithPossibleError:error forCommand:command];
                    }];
                } else {
                    [Carnival setUserId:userID withResponse:^(NSError *error) {
                        [self sendPluginResultWithPossibleError:error forCommand:command];
                    }];
                }
            }];
        }
    }
}

- (void)setUserEmail:(CDVInvokedUrlCommand *)command {
    NSArray *arguments = command.arguments;

    if (arguments.count > 0) {
        NSString *userEmail = arguments[0];

        if ([userEmail isKindOfClass:[NSString class]] || [userEmail isKindOfClass:[NSNull class]]) {
            [self.commandDelegate runInBackground:^{
                if ([userEmail isKindOfClass:[NSNull class]]) {
                    [Carnival setUserEmail:nil withResponse:^(NSError *error) {
                        [self sendPluginResultWithPossibleError:error forCommand:command];
                    }];
                } else {
                    [Carnival setUserEmail:userEmail withResponse:^(NSError *error) {
                        [self sendPluginResultWithPossibleError:error forCommand:command];
                    }];
                }
            }];
        }
    }
}
#pragma mark - deviceID

- (void)deviceID:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        [Carnival deviceID:^(NSString *deviceID, NSError *error) {
            [self sendPluginResultWithPossibleError:error string:deviceID forCommand:command];
        }];
    }];
}

// Push Registration
- (void)registerForPushNotifications:(CDVInvokedUrlCommand *)command {
    UIUserNotificationType types = UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound;

    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) { // iOS 8+
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else { //iOS 7
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationType)types];
    }
}

#pragma mark - sending plugin results

- (void)sendPluginResultWithStatus:(CDVCommandStatus)status forCommand:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:status] callbackId:command.callbackId];
}

- (void)sendPluginResultWithPossibleError:(NSError *)error andInt:(int)anInt forCommand:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *result = [self pluginResultWithPossibleError:error andInt:anInt];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)sendPluginResultWithPossibleError:(NSError *)error array:(NSArray *)array forCommand:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *result = [self pluginResultWithPossibleError:error array:array];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)sendPluginResultWithPossibleError:(NSError *)error string:(NSString *)string forCommand:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *result = [self pluginResultWithPossibleError:error string:string];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)sendPluginResultWithPossibleError:(NSError *)error forCommand:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *result = [self pluginResultWithPossibleError:error];

    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

#pragma mark - creating plugin results

- (CDVPluginResult *)pluginResultWithPossibleError:(NSError *)error andInt:(int)anInt {
    if (error) return [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    else return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsInt:anInt];
}

- (CDVPluginResult *)pluginResultWithPossibleError:(NSError *)error array:(NSArray *)array {
    if (error) return [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    else return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:array];
}

- (CDVPluginResult *)pluginResultWithPossibleError:(NSError *)error {
    if (error) return [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    else return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
}

- (CDVPluginResult *)pluginResultWithPossibleError:(NSError *)error string:(NSString *)string {
    if (error) return [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    else return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:string];
}

#pragma mark - helpers

- (UIViewController *)presentingViewController {
    UIViewController *presentingViewController = [self hostAppMainWindow].rootViewController;

    while (presentingViewController.presentedViewController) {
        presentingViewController = presentingViewController.presentedViewController;
    }

    return presentingViewController;
}

- (UIWindow *)hostAppMainWindow {
    return [UIApplication sharedApplication].delegate.window;
}

- (NSDictionary *)settingsFromConfigFile {
    CDVConfigParser *parserDelegate = [[CDVConfigParser alloc] init];

    NSString *path = [[NSBundle mainBundle] pathForResource:@"config" ofType:@"xml"];

    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return nil;
    }

    NSURL *url = [NSURL fileURLWithPath:path];

    NSXMLParser *configParser = [[NSXMLParser alloc] initWithContentsOfURL:url];

    if (configParser == nil) {
        return nil;
    }

    [configParser setDelegate:parserDelegate];
    [configParser parse];

    return parserDelegate.settings;
}

#pragma mark - dealloc

- (void)dealloc {
    [self removeNotificationObservers];
}

@end
