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

// Location
- (void)updateLocation:(CDVInvokedUrlCommand *)command;

// Clear Device Data
- (void)clearDevice:(CDVInvokedUrlCommand *)command;

// Custom Attributes
- (void)setAttributes:(CDVInvokedUrlCommand *)command;
- (void)removeAttribute:(CDVInvokedUrlCommand *)command;

// UnreadCount
- (void)unreadCount:(CDVInvokedUrlCommand *)command;

// Show/hide in-app notification standard UX
- (void)setDisplayInAppNotifications:(CDVInvokedUrlCommand *)command;


// Marking messages as read
- (void)markMessageAsRead:(CDVInvokedUrlCommand *)command;
- (void)markMessagesAsRead:(CDVInvokedUrlCommand *)command;

// Users
- (void)setUserId:(CDVInvokedUrlCommand *)command;
- (void)setUserEmail:(CDVInvokedUrlCommand *)command;

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

// Push Registration
- (void)registerForPushNotifications:(CDVInvokedUrlCommand *)command;

@end
