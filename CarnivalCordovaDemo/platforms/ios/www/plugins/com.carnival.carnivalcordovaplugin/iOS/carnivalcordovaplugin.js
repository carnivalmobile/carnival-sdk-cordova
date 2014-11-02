cordova.define("com.carnival.carnivalcordovaplugin.CarnivalCordovaPlugin", function(require, exports, module) { function CarnivalCordovaPlugin() {}

// Initialization
CarnivalCordovaPlugin.prototype.startEngine = function() {
    cordova.exec(null, null, "CarnivalCordovaPlugin", "startEngine", []);
};

// Tags
CarnivalCordovaPlugin.prototype.getTags = function(onSuccess, onError) {
    cordova.exec(onSuccess, onError, "CarnivalCordovaPlugin", "getTags", []);
};

CarnivalCordovaPlugin.prototype.setTags = function(onSuccess, onError, newTags) {
    cordova.exec(onSuccess, onError, "CarnivalCordovaPlugin", "setTags", newTags);
};

CarnivalCordovaPlugin.prototype.addTags = function(onSuccess, onError, tagsToAdd) {
    cordova.exec(onSuccess, onError, "CarnivalCordovaPlugin", "addTags", tagsToAdd);
};

// Stream
CarnivalCordovaPlugin.prototype.showMessageStream = function() {
    cordova.exec(null, null, "CarnivalCordovaPlugin", "showMessageStream", []);
};

module.exports = new CarnivalCordovaPlugin();
});
