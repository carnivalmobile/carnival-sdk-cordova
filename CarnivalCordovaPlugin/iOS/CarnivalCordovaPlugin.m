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

@end

@implementation CarnivalCordovaPlugin

#pragma mark - overriden getters/setters

- (NSDictionary *)settings {
    if (!_settings) {
        _settings = [self settingsFromConfigFile];
    }
    
    return _settings;
}

#pragma mark - start engine

- (void)startEngine:(CDVInvokedUrlCommand *)command {
    NSString *appKey = self.settings[@"carnival_ios_app_key"];
    
    [self.commandDelegate runInBackground:^{
        [Carnival startEngine:appKey];
        
        [CarnivalMessageStream setDelegate:self];
        
        [self.commandDelegate sendPluginResult:[CDVPluginResult resultWithStatus:CDVCommandStatus_OK] callbackId:command.callbackId];
    }];
}

#pragma mark - tags

- (void)getTags:(CDVInvokedUrlCommand *)command {
    [self.commandDelegate runInBackground:^{
        [Carnival getTagsInBackgroundWithResponse:^(NSArray *tags, NSError *error) {
            CDVPluginResult *result = nil;
            
            if (error) {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            }
            else {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:tags];
            }
            
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
        }];
    }];
}

- (void)setTags:(CDVInvokedUrlCommand *)command {
    NSArray *newTags = command.arguments;
    
    [self.commandDelegate runInBackground:^{
        [Carnival setTagsInBackground:newTags withResponse:^(NSArray *tags, NSError *error) {
            CDVPluginResult *result = nil;
            
            if (error) {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            }
            else {
                result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:tags];
            }
            
            [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
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
        
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
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
    if ([command.arguments count] > 1) {
        double lat = [command.arguments[0] doubleValue];
        double lon = [command.arguments[1] doubleValue];
        
        [self.commandDelegate runInBackground:^{
            CLLocation *location = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
            [Carnival updateLocation:location];
        }];
    }
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
