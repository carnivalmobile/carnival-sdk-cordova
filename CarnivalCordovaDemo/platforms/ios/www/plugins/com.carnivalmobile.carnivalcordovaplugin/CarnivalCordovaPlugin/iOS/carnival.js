cordova.define("com.carnivalmobile.carnivalcordovaplugin.Carnival", function(require, exports, module) { function Carnival() {}

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

Carnival.prototype.addTags = function(onSuccess, onError, tagsToAdd) {
    cordova.exec(onSuccess, onError, "CarnivalCordovaPlugin", "addTags", tagsToAdd);
};

// Stream
Carnival.prototype.showMessageStream = function() {
    cordova.exec(null, null, "CarnivalCordovaPlugin", "showMessageStream", []);
};

module.exports = new Carnival();
});
