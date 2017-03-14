  function Carnival() {}
  Carnival.prototype.AttributeMap = function() {
    this.MergeRules = {Update: 1, Replace: 2}

    var mergeRule = this.MergeRules.Update;
    var attributes = {};
    this.getAttributes = function() {return {attributes: attributes, mergeRule: mergeRule}}
    this.get = function(key) {return attributes[key] || null}
    this.remove = function(key) {delete attributes[key]}
    this.setMergeRule = function(rule) {
      switch (rule) {
        case this.MergeRules.Update:
        case this.MergeRules.Replace:
          mergeRule = rule;
          return;
      }

      throw new TypeError('Invalid merge rule');
    }

    this.setString = function(key, value) {
      if (typeof value === 'string') {
        attributes[key] = {type: 'string', value: value};
      } else {
        throw new TypeError(key + ' is not a string');
      }
    }

    this.setStringArray = function(key, value) {
      if (Object.prototype.toString.call(value) !== '[object Array]') {
        throw new TypeError(key + ' is not an array');
        return;
      }

      var array = [];
      for (var i in value) {
        if (typeof value[i] === 'string') {
          array.push(value[i]);
        } else {
          throw new TypeError(key + ': value at index ' + i + ' is not a string');
          return;
        }
      }

      attributes[key] = {type: 'stringArray', value: array};
    }

    this.setInteger = function(key, value) {
      if (typeof value === 'number' && isFinite(value) && Math.floor(value) === value) {
        attributes[key] = {type: 'integer', value: value};
      } else {
        throw new TypeError(key + ' is not an integer');
      }
    }

    this.setIntegerArray = function(key, value) {
      if (Object.prototype.toString.call(value) !== '[object Array]') {
        throw new TypeError(key + ' is not an array');
        return;
      }

      var array = [];
      for (var i in value) {
        if (typeof value[i] === 'number' && isFinite(value[i]) && Math.floor(value[i]) === value[i]) {
          array.push(value[i]);
        } else {
          throw new TypeError(key + ': value at index ' + i + ' is not an integer');
          return;
        }
      }

      attributes[key] = {type: 'integerArray', value: array};
    }

    this.setBoolean = function(key, value) {
      if (typeof value === 'boolean') {
        attributes[key] = {type: 'boolean', value: value};
      } else {
        throw new TypeError(key + ' is not a boolean');
      }
    }

    this.setFloat = function(key, value) {
      if (typeof value === 'number') {
        attributes[key] = {type: 'float', value: value};
      } else {
        throw new TypeError(key + ' is not a number');
      }
    }

    this.setFloatArray = function(key, value) {
      if (Object.prototype.toString.call(value) !== '[object Array]') {
        throw new TypeError(key + ' is not an array');
        return;
      }

      var array = [];
      for (var i in value) {
        if (typeof value[i] === 'number') {
          array.push(value[i]);
        } else {
          throw new TypeError(key + ': value at index ' + i + ' is not a number');
          return;
        }
      }

      attributes[key] = {type: 'floatArray', value: array};
    }

    this.setDate = function(key, value) {
      if (value instanceof Date && value.toString() !== 'Invalid Date') {
        attributes[key] = {type: 'date', value: value.getTime()};
      } else {
        throw new TypeError(key + ' is not a valid Date object');
      }
    }

    this.setDateArray = function(key, value) {
      if (Object.prototype.toString.call(value) !== '[object Array]') {
        throw new TypeError(key + ' is not an array');
        return;
      }

      var array = [];
      for (var i in value) {
        if (value[i] instanceof Date && value[i].toString() !== 'Invalid Date') {
          array.push(value[i].getTime());
        } else {
          throw new TypeError(key + ': value at index ' + i + ' is not a Date');
          return;
        }
      }

      attributes[key] = {type: 'dateArray', value: array};
    }
  }

  Carnival.prototype.MessageImpressionType = {StreamView: 2000, DetailView: 2001, InAppView: 2002};
  Carnival.prototype.DeviceValues = {Attributes: 1, MessageStream: 2, Events: 4, ClearAll: 7};

  // Initialization
  Carnival.prototype.startEngine = function(registerForPushNotifications) {
      cordova.exec(null, null, 'CarnivalCordovaPlugin', 'startEngine', [registerForPushNotifications]);
  };

  // Location
  Carnival.prototype.updateLocation = function(lat, lon) {
      cordova.exec(null, null, 'CarnivalCordovaPlugin', 'updateLocation', [lat, lon]);
  };

  Carnival.prototype.removeAttribute = function(onSuccess, onError, key) {
      cordova.exec(onSuccess, onError, 'CarnivalCordovaPlugin', 'removeAttribute', [key]);
  };

  Carnival.prototype.clearDevice = function(onSuccess, onError, deviceDataType) {
      cordova.exec(onSuccess, onError, 'CarnivalCordovaPlugin', 'clearDevice', [deviceDataType]);
  };

  Carnival.prototype.setAttributes = function(onSuccess, onError, attributes) {
    if (attributes instanceof this.AttributeMap) {
      cordova.exec(onSuccess, onError, 'CarnivalCordovaPlugin', 'setAttributes', [attributes.getAttributes()]);
    } else {
      throw new TypeError('Attributes must be an instance of Carnival.AttributeMap');
    }
  }

  // Custom Events
  Carnival.prototype.logEvent = function(name) {
      cordova.exec(null, null, 'CarnivalCordovaPlugin', 'logEvent', [name]);
  };

  // Unread Count
  Carnival.prototype.unreadCount = function(onSuccess, onFailure) {
      cordova.exec(onSuccess, onFailure, 'CarnivalCordovaPlugin', 'unreadCount', []);
  };

  Carnival.prototype.setDisplayInAppNotifications = function(enabled) {
    cordova.exec(null, null, 'CarnivalCordovaPlugin', 'setDisplayInAppNotifications', [enabled]);
  }

  // Users
  Carnival.prototype.setUserId = function(onSuccess, onFailure, userId) {
      cordova.exec(onSuccess, onFailure, 'CarnivalCordovaPlugin', 'setUserId', [userId]);
  };

  Carnival.prototype.setUserEmail = function(onSuccess, onFailure, userEmail) {
      cordova.exec(onSuccess, onFailure, 'CarnivalCordovaPlugin', 'setUserEmail', [userEmail]);
  };

  // Messages
  Carnival.prototype.messages = function(onSuccess, onFailure) {
      cordova.exec(onSuccess, onFailure, 'CarnivalCordovaPlugin', 'messages', []);
  };

  // Registering impressions
  Carnival.prototype.registerImpression = function(type, message) {
      cordova.exec(null, null, 'CarnivalCordovaPlugin', 'registerImpression', [type, message]);
  };

  Carnival.prototype.removeMessage = function(onSuccess, onFailure, message) {
      cordova.exec(onSuccess, onFailure, 'CarnivalCordovaPlugin', 'removeMessage', [message]);
  };

  Carnival.prototype.markMessageAsRead = function(onSuccess, onFailure, message) {
      cordova.exec(onSuccess, onFailure, 'CarnivalCordovaPlugin', 'markMessagesAsRead', [message]);
  };

  Carnival.prototype.markMessagesAsRead = function(onSuccess, onFailure, messages) {
      cordova.exec(onSuccess, onFailure, 'CarnivalCordovaPlugin', 'markMessagesAsRead', messages);
  };

  // Present/dismiss message detail
  Carnival.prototype.presentMessageDetail = function(message) {
      cordova.exec(null, null, 'CarnivalCordovaPlugin', 'presentMessageDetail', [message]);
  };

  Carnival.prototype.dismissMessageDetail = function() {
      cordova.exec(null, null, 'CarnivalCordovaPlugin', 'dismissMessageDetail', []);
  };

  // DeviceID
  Carnival.prototype.deviceID = function(onSuccess, onFailure) {
      cordova.exec(onSuccess, onFailure, 'CarnivalCordovaPlugin', 'deviceID', []);
  };

  // Push Registration - iOS Only. Pass in false to startEngine and the call this function at an appropriate time.
  Carnival.prototype.registerForPushNotifications = function() {
      cordova.exec(null, null, 'CarnivalCordovaPlugin', 'registerForPushNotifications', []);
  };

  module.exports = new Carnival();
