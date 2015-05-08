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

module.exports = new Carnival();