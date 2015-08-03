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

// Enabling/disabling in-app notifications
- (void)setInAppNotificationsEnabled:(CDVInvokedUrlCommand *)command;

// Marking messages as read
- (void)markMessageAsRead:(CDVInvokedUrlCommand *)command;
- (void)markMessagesAsRead:(CDVInvokedUrlCommand *)command;

// Users
- (void)setUserId:(CDVInvokedUrlCommand *)command;

// Messages
- (void)messages:(CDVInvokedUrlCommand *)command;
- (void)removeMessage:(CDVInvokedUrlCommand *)command;

// Registering impressions
- (void)registerImpression:(CDVInvokedUrlCommand *)command;

// Present/dismiss message detail
- (void)presentMessageDetail:(CDVInvokedUrlCommand *)command;
- (void)dismissMessageDetail:(CDVInvokedUrlCommand *)command;

// DeviceID
- (void)deviceID:(CDVInvokedUrlCommand *)command;

@end