function Carnival() {}

// Initialization
Carnival.prototype.startEngine = function() {
    cordova.exec(null, null, "CarnivalCordovaPlugin", "startEngine", []);
};

// Tags
Carnival.prototype.getTags = function(onSuccess, onError) {
    cordova.exec(onSuccess, onError, "CarnivalCordovaPlugin", "getTags", []);
};

Carnival.prototype.setTags = function(onSuccess, onError, newTags) {
    cordova.exec(onSuccess, onError, "CarnivalCordovaPlugin", "setTags", newTags);
};

// Stream
Carnival.prototype.showMessageStream = function() {
    cordova.exec(null, null, "CarnivalCordovaPlugin", "showMessageStream", []);
};

// Location
Carnival.prototype.updateLocation = function(lat, lon) {
    cordova.exec(null, null, "CarnivalCordovaPlugin", "updateLocation", [lat, lon]);
}

// Custom Attributes
Carnival.prototype.setString = function(onSuccess, onError, string, key) {
    cordova.exec(onSuccess, onError, "CarnivalCordovaPlugin", "setString", [string, key])
}

Carnival.prototype.setFloat = function(onSuccess, onError, float, key) {
    cordova.exec(onSuccess, onError, "CarnivalCordovaPlugin", "setFloat", [float, key])
}

Carnival.prototype.setInteger = function(onSuccess, onError, integer, key) {
    cordova.exec(onSuccess, onError, "CarnivalCordovaPlugin", "setInteger", [integer, key])
}

Carnival.prototype.setDate = function(onSuccess, onError, date, key) {
    cordova.exec(onSuccess, onError, "CarnivalCordovaPlugin", "setDate", [date, key])
}

Carnival.prototype.setBool = function(onSuccess, onError, bool, key) {
    cordova.exec(onSuccess, onError, "CarnivalCordovaPlugin", "setBool", [bool, key])
}

Carnival.prototype.removeAttribute = function(onSuccess, onError, key) {
    cordova.exec(onSuccess, onError, "CarnivalCordovaPlugin", "removeAttribute", [key])
}

// Custom Events
Carnival.prototype.logEvent = function(name) {
    cordova.exec(null, null, "CarnivalCordovaPlugin", "logEvent", [name]);
}

// Unread Count
Carnival.prototype.unreadCount = function(onSuccess, onFailure) {
    cordova.exec(onSuccess, onFailure, "CarnivalCordovaPlugin", "unreadCount", [])
}

module.exports = new Carnival();