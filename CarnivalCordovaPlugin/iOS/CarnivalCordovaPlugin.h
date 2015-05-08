//
//  CarnivalPhonegapPlugin.h
//  CarnivalPhonegapPlugin
//
//  Created by Blair McArthur on 28/10/14.
//
//

#import <Cordova/CDV.h>

@interface CarnivalCordovaPlugin : CDVPlugin

// Initialize
- (void)startEngine:(CDVInvokedUrlCommand *)command;

// Tags
- (void)getTags:(CDVInvokedUrlCommand *)command;
- (void)setTags:(CDVInvokedUrlCommand *)command;

// Stream
- (void)showMessageStream:(CDVInvokedUrlCommand *)command;

// Location
-(void)updateLocation:(CDVInvokedUrlCommand *)command;

@end
