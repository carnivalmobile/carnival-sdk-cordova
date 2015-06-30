//
//  CarnivalPhonegapPlugin.m
//  CarnivalPhonegapPlugin
//
//  Created by Blair McArthur on 28/10/14.
//
//

#import "CarnivalCordovaPlugin.h"
#import <Carnival/Carnival.h>
#import <Cordova/CDVConfigParser.h>
#import "CustomBarButtonItem.h"

@interface CarnivalCordovaPlugin () <CarnivalMessageStreamDelegate>

@property (strong, nonatomic) NSDictionary *settings;
@property (strong, nonatomic) UINavigationController *streamNavigationController;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation CarnivalCordovaPlugin

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
    NSString *appKey = self.settings[@"carnival_ios_app_key"];
    
    [self.commandDelegate runInBackground:^{
        [Carnival startEngine:appKey];
        
        [CarnivalMessageStream setDelegate:self];
        
        [self sendPluginResultWithStatus:CDVCommandStatus_OK forCommand:command];
    }];
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

#pragma mark - stream

- (void)showMessageStream:(CDVInvokedUrlCommand *)command {
    CustomBarButtonItem *closeItem = [CustomBarButtonItem closeButtonForTarget:self action:@selector(closeButtonPressed:)];
    
    // Change the color of the close button on the message stream
    [closeItem setTintColor:[UIColor blackColor]];
    
    CarnivalStreamViewController *streamVC = [[CarnivalStreamViewController alloc] init];
    [streamVC.navigationItem setRightBarButtonItem:closeItem];
    
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:streamVC];
    
    // Change the color of the navigation bar
    [navVC.navigationBar setBackgroundColor:[UIColor whiteColor]];
    [navVC.navigationBar setBarTintColor:[UIColor whiteColor]];
    
    // Change the font and color of the nav bar text
    [navVC.navigationBar setTitleTextAttributes:@{
        NSFontAttributeName : [UIFont fontWithName:@"AvenirNext-Regular" size:15.0f],
        NSForegroundColorAttributeName : [UIColor blackColor]
    }];
    
    self.streamNavigationController = navVC;
    
    [[self presentingViewController] presentViewController:navVC animated:YES completion:^{
        // Change the status bar foreground color, Note: you'll need to turn UIViewController-based status bar appearance off in your info.plist
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        
        [self sendPluginResultWithStatus:CDVCommandStatus_OK forCommand:command];
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

#pragma mark - sending plugin results

- (void)sendPluginResultWithStatus:(CDVCommandStatus)status forCommand:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *result = [CDVPluginResult resultWithStatus:status];
    
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)sendPluginResultWithPossibleError:(NSError *)error array:(NSArray *)array forCommand:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *result = [self pluginResultWithPossibleError:error array:array];
    
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)sendPluginResultWithPossibleError:(NSError *)error forCommand:(CDVInvokedUrlCommand *)command {
    CDVPluginResult *result = [self pluginResultWithPossibleError:error];
    
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

#pragma mark - creating plugin results

- (CDVPluginResult *)pluginResultWithPossibleError:(NSError *)error array:(NSArray *)array {
    if (error) return [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    else return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:array];
}

- (CDVPluginResult *)pluginResultWithPossibleError:(NSError *)error {
    if (error) return [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    else return [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
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

@end
