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

@interface CarnivalCordovaPlugin () <CarnivalMessageStreamDelegate>

@property (strong, nonatomic) NSDictionary *settings;
@property (strong, nonatomic) UINavigationController *streamNavigationController;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation CarnivalCordovaPlugin

#pragma mark - setup

- (void)setup {
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

#pragma mark - overriden getters/setters

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

            [self sendPluginResultWithStatus:CDVCommandStatus_OK forCommand:command];
       }];
    }
}

#pragma mark - tags

- (void)getTags:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        [Carnival getTagsInBackgroundWithResponse:^(NSArray *tags, NSError *error) {
            [self sendPluginResultWithPossibleError:error array:tags forCommand:command];
        }];
    }];
}

- (void)setTags:(CDVInvokedUrlCommand *)command {
    NSArray *newTags = command.arguments;

    [self.commandDelegate runInBackground:^{
        [Carnival setTagsInBackground:newTags withResponse:^(NSArray *tags, NSError *error) {
            [self sendPluginResultWithPossibleError:error array:tags forCommand:command];
        }];
    }];
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

#pragma mark - custom attributes

- (void)setString:(CDVInvokedUrlCommand *)command {
    NSArray *arguments = command.arguments;

    if ([arguments count] > 1) {
        NSString *string = arguments[0];
        NSString *key = arguments[1];

        if ([string isKindOfClass:[NSString class]] && [key isKindOfClass:[NSString class]]) {
            [self.commandDelegate runInBackground:^{
                [Carnival setString:string forKey:key withResponse:^(NSError *error) {
                    [self sendPluginResultWithPossibleError:error forCommand:command];
                }];
            }];
        }
    }
}

- (void)setFloat:(CDVInvokedUrlCommand *)command {
    NSArray *arguments = command.arguments;

    if ([arguments count] > 1) {
        CGFloat aFloat = [arguments[0] floatValue];
        NSString *key = arguments[1];

        if ([key isKindOfClass:[NSString class]]) {
            [self.commandDelegate runInBackground:^{
                [Carnival setFloat:aFloat forKey:key withResponse:^(NSError *error) {
                    [self sendPluginResultWithPossibleError:error forCommand:command];
                }];
            }];
        }
    }
}

- (void)setInteger:(CDVInvokedUrlCommand *)command {
    NSArray *arguments = command.arguments;

    if ([arguments count] > 1) {
        NSInteger anInteger = [arguments[0] integerValue];
        NSString *key = arguments[1];

        if ([key isKindOfClass:[NSString class]]) {
            [self.commandDelegate runInBackground:^{
                [Carnival setInteger:anInteger forKey:key withResponse:^(NSError *error) {
                    [self sendPluginResultWithPossibleError:error forCommand:command];
                }];
            }];
        }
    }
}

- (void)setDate:(CDVInvokedUrlCommand *)command {
    NSArray *arguments = command.arguments;

    if ([arguments count] > 1) {
        NSString *dateString = arguments[0];
        NSString *key = arguments[1];

        if ([dateString isKindOfClass:[NSString class]] && [key isKindOfClass:[NSString class]]) {
            NSDate *date = [self.dateFormatter dateFromString:dateString];

            if (date) {
                [self.commandDelegate runInBackground:^{
                    [Carnival setDate:date forKey:key withResponse:^(NSError *error) {
                        [self sendPluginResultWithPossibleError:error forCommand:command];
                    }];
                }];
            }
        }
    }
}

- (void)setBool:(CDVInvokedUrlCommand *)command {
    NSArray *arguments = command.arguments;

    if ([arguments count] > 1) {
        BOOL aBool = [arguments[0] boolValue];
        NSString *key = arguments[1];

        if ([key isKindOfClass:[NSString class]]) {
            [self.commandDelegate runInBackground:^{
                [Carnival setBool:aBool forKey:key withResponse:^(NSError *error) {
                    [self sendPluginResultWithPossibleError:error forCommand:command];
                }];
            }];
        }
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


#pragma mark - disabling in-app notifications

- (void)setInAppNotificationsEnabled:(CDVInvokedUrlCommand *)command {
    if (command.arguments.count > 0) {
        BOOL enabled = [command.arguments[0] boolValue];

        [Carnival setInAppNotificationsEnabled:enabled];
    }
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