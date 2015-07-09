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

// Custom Attributes
- (void)setString:(CDVInvokedUrlCommand *)command;
- (void)setFloat:(CDVInvokedUrlCommand *)command;
- (void)setInteger:(CDVInvokedUrlCommand *)command;
- (void)setDate:(CDVInvokedUrlCommand *)command;
- (void)setBool:(CDVInvokedUrlCommand *)command;
- (void)removeAttribute:(CDVInvokedUrlCommand *)command;

// UnreadCount
- (void)unreadCount:(CDVInvokedUrlCommand *)command;

@end
