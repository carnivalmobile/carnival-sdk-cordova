function Carnival() {}

Carnival.prototype.MessageImpressionType = {"StreamView":2000, "DetailView":2001, "InAppView":2002};

// Initialization
Carnival.prototype.startEngine = function(registerForPushNotifications) {
    cordova.exec(null, null, "CarnivalCordovaPlugin", "startEngine", [registerForPushNotifications]);
};

// Tags
Carnival.prototype.getTags = function(onSuccess, onError) {
    cordova.exec(onSuccess, onError, "CarnivalCordovaPlugin", "getTags", []);
};

Carnival.prototype.setTags = function(onSuccess, onError, newTags) {
    cordova.exec(onSuccess, onError, "CarnivalCordovaPlugin", "setTags", newTags);
};

// Location
Carnival.prototype.updateLocation = function(lat, lon) {
    cordova.exec(null, null, "CarnivalCordovaPlugin", "updateLocation", [lat, lon]);
};

// Custom Attributes
Carnival.prototype.setString = function(onSuccess, onError, string, key) {
    cordova.exec(onSuccess, onError, "CarnivalCordovaPlugin", "setString", [string, key]);
};

Carnival.prototype.setFloat = function(onSuccess, onError, aFloat, key) {
    cordova.exec(onSuccess, onError, "CarnivalCordovaPlugin", "setFloat", [aFloat, key]);
};

Carnival.prototype.setInteger = function(onSuccess, onError, integer, key) {
    cordova.exec(onSuccess, onError, "CarnivalCordovaPlugin", "setInteger", [integer, key]);
};

Carnival.prototype.setDate = function(onSuccess, onError, date, key) {
    cordova.exec(onSuccess, onError, "CarnivalCordovaPlugin", "setDate", [date, key]);
};

Carnival.prototype.setBool = function(onSuccess, onError, bool, key) {
    cordova.exec(onSuccess, onError, "CarnivalCordovaPlugin", "setBool", [bool, key]);
};

Carnival.prototype.removeAttribute = function(onSuccess, onError, key) {
    cordova.exec(onSuccess, onError, "CarnivalCordovaPlugin", "removeAttribute", [key]);
};

// Custom Events
Carnival.prototype.logEvent = function(name) {
    cordova.exec(null, null, "CarnivalCordovaPlugin", "logEvent", [name]);
};

// Unread Count
Carnival.prototype.unreadCount = function(onSuccess, onFailure) {
    cordova.exec(onSuccess, onFailure, "CarnivalCordovaPlugin", "unreadCount", []);
};

// Disabling in-app notifications
Carnival.prototype.setInAppNotificationsEnabled = function(enabled) {
    cordova.exec(null, null, "CarnivalCordovaPlugin", "setInAppNotificationsEnabled", [enabled]);
};

// Users
Carnival.prototype.setUserId = function(onSuccess, onFailure, userId) {
    cordova.exec(onSuccess, onFailure, "CarnivalCordovaPlugin", "setUserId", [userId]);
};

// Messages
Carnival.prototype.messages = function(onSuccess, onFailure) {
    cordova.exec(onSuccess, onFailure, "CarnivalCordovaPlugin", "messages", []);
};

// Registering impressions
Carnival.prototype.registerImpression = function(type, message) {
    cordova.exec(null, null, "CarnivalCordovaPlugin", "registerImpression", [type, message]);
};

Carnival.prototype.removeMessage = function(onSuccess, onFailure, message) {
    cordova.exec(onSuccess, onFailure, "CarnivalCordovaPlugin", "removeMessage", [message]);
};

Carnival.prototype.markMessageAsRead = function(onSuccess, onFailure, message) {
    cordova.exec(onSuccess, onFailure, "CarnivalCordovaPlugin", "markMessageAsRead", [message]);
};

Carnival.prototype.markMessagesAsRead = function(onSuccess, onFailure, messages) {
    cordova.exec(onSuccess, onFailure, "CarnivalCordovaPlugin", "markMessageAsRead", messages);
};

// Present/dismiss message detail
Carnival.prototype.presentMessageDetail = function(message) {
    cordova.exec(null, null, "CarnivalCordovaPlugin", "presentMessageDetail", [message]);
};

Carnival.prototype.dismissMessageDetail = function() {
    cordova.exec(null, null, "CarnivalCordovaPlugin", "dismissMessageDetail", []);
};

// DeviceID
Carnival.prototype.deviceID = function(onSuccess, onFailure) {
    cordova.exec(onSuccess, onFailure, "CarnivalCordovaPlugin", "deviceID", []);
};

// Push Registration - iOS Only. Pass in false to startEngine and the call this function at an appropriate time.
Carnival.prototype.registerForPushNotifications = function() {
    cordova.exec(null, null, "CarnivalCordovaPlugin", "registerForPushNotifications", []);
};

module.exports = new Carnival();