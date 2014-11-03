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

@interface CarnivalCordovaPlugin () <CarnivalMessageStreamDelegate>

@property (strong, nonatomic) NSDictionary *settings;

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
            if (error) {
                CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
                
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            }
            else {
                CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:tags];
                
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            }
        }];
    }];
}

- (void)setTags:(CDVInvokedUrlCommand *)command {
    NSArray *newTags = command.arguments;
    
    [self.commandDelegate runInBackground:^{
        [Carnival setTagsInBackground:newTags withResponse:^(NSArray *tags, NSError *error) {
            if (error) {
                CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
                
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            }
            else {
                CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:tags];
                
                [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
            }
        }];
    }];
}

#pragma mark - stream

- (void)showMessageStream:(CDVInvokedUrlCommand *)command {
    UINavigationController *streamNavigationController = [CarnivalMessageStream streamNavigationController];
    
    [[[self appDelegate] window].rootViewController presentViewController:streamNavigationController animated:YES completion:^{
        CDVPluginResult *result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }];
}

#pragma mark - CarnivalMessageStreamDelegae

- (void)carnivalMessageStreamNeedsDisplay:(UINavigationController *)streamNavigationController fromApplicationState:(UIApplicationState)applicationState {
    id appDelegate = self.appDelegate;
    
    if ([appDelegate conformsToProtocol:@protocol(UIApplicationDelegate)]) {
        id<UIApplicationDelegate> applicationDelegate = appDelegate;
        
        UIViewController *rootViewController = applicationDelegate.window.rootViewController;
        
        [rootViewController presentViewController:streamNavigationController animated:YES completion:NULL];
    }
}

#pragma mark - helpers

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
