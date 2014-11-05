function Carnival() {}

// Initialization
Carnival.prototype.startEngine = function() {
    cordova.exec(null, null, "CarnivalPlugin", "startEngine", []);
};

// Tags
Carnival.prototype.getTags = function(onSuccess, onError) {
    cordova.exec(onSuccess, onError, "CarnivalPlugin", "getTags", []);
};

Carnival.prototype.setTags = function(onSuccess, onError, newTags) {
    cordova.exec(onSuccess, onError, "CarnivalPlugin", "setTags", newTags);
};

// Stream
Carnival.prototype.showMessageStream = function() {
    cordova.exec(null, null, "CarnivalPlugin", "showMessageStream", []);
};

module.exports = new Carnival();