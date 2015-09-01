Carnival SDK Cordova Plugin

This repo contains cordova plugins for both iOS and Android as well as a demo app that contains examples of how to use the SDK.

## Installation

`cordova plugin add https://github.com/carnivalmobile/carnival-sdk-cordova.git`

### iOS

Add a preference to your `config.xml` file with your Carnival App key (from [http://app.carnivalmobile.com](http://app.carnivalmobile.com)).

e.g.

```xml
<platform name="ios">
    <preference name="carnival_ios_app_key" value="YOUR_APP_KEY_GOES_HERE" />
</platform>
```

Open your Xcode project, which should be located in the `platforms/ios` directory of your Cordova/Phonegap project and Drag and drop the `Carnival.embeddedframework` into it. The `Carnival.embeddedframework` can be downloaded from the [Carnival iOS SDK repo](https://github.com/carnivalmobile/carnival-ios-sdk/releases).

### Android

Add these preferences to your `config.xml` file with your Carnival App key (from [http://app.carnivalmobile.com](http://app.carnivalmobile.com)) and your Project Number as described in the [Setting Up GCM](http://docs.carnivalmobile.com/sdk/android/current/gcm/) documentation.

e.g.

```xml
<platform name="android">
    <preference name="carnival_android_app_key" value="YOUR_APP_KEY_GOES_HERE"/>
    <preference name="carnival_android_project_number" value="YOUR_PROJECT_NUMBER_GOES_HERE"/>
</platform>
```



### Methods

```js
Carnival.startEngine();
```
Sets the Carnival appKey credentials for this app. This method uses the value of the `carnival_ios_app_key` in your config.xml file.
 
 ```js
Carnival.getTags(
  function callback(data) {
    console.log('getTags returned: ' + data);
  },
  function errorHandler(err) {
    console.log('getTags error: ' + err);
  }
);
```
Asyncronously gets the tags for Carnival for this Device.

```js
Carnival.setTags(
  function callback(data) {
    console.log('setTags returned: ' + data);
  },
  function errorHandler(err) {
    console.log('setTags error: ' + err);
  },
  ['EXAMPLE_SET_TAG_1', 'EXAMPLE_SET_TAG_2']
);
```
Asyncronously sets the tags for Carnival for this Device.

```js
Carnival.showMessageStream();
```
Shows the Carnival Message Stream.

```js
Carnival.updateLocation([-41.292322, 174.777888]);
```
Sends a location update to Carnival.

```js
Carnival.logEvent("event_name");
```
Logs a custom event with the given name.

```js
Carnival.setString(
  function callback() {
    console.log('setString successfully returned');
  },
  function errorHandler(err) {
    console.log('setString returned error: ' + err);
  },
  "test_string",
  "test_string_key"
);
```
Sets a string custom attribute for the given key

```js
Carnival.setFloat(
  function callback() {
    console.log('setFloat successfully returned');
  },
  function errorHandler(err) {
    console.log('setFloat returned error: ' + err);
  },
  1.23,
  "test_float_key"
);
```
Sets a float custom attribute for the given key

```js
Carnival.setInteger(
  function callback() {
    console.log('setFloat successfully returned');
  },
  function errorHandler(err) {
    console.log('setFloat returned error: ' + err);
  },
  1,
  "test_integer_key"
);
```
Sets a integer custom attribute for the given key

```js
Carnival.setDate(
  function callback() {
    console.log('setDate successfully returned');
  },
  function errorHandler(err) {
    console.log('setDate returned error: ' + err);
  },
  new Date(),
  "test_date_key"
);
```
Sets a date custom attribute for the given key

```js
Carnival.setBool(
  function callback() {
    console.log('setBool successfully returned');
  },
  function errorHandler(err) {
    console.log('setBool returned error: ' + err);
  },
  true,
  "test_bool_key"
);
```
Sets a boolean custom attribute for the given key

```js
Carnival.removeAttribute(
  function callback() {
    console.log('removeAttribute successfully returned');
  },
  function errorHandler(err) {
    console.log('removeAttribute returned error: ' + err);
  },
  "test_bool_key"
);
```
Removes the custom attribute for the given key

```js
// Disable
Carnival.setInAppNotificationsEnabled(false);

// Enable
Carnival.setInAppNotificationsEnabled(true);
```
Enabling/Disabling in-app notifications.

```js
Carnival.setUserId(
  function callback(data) {
      console.log('setUserId successfully returned');
  },
  function errorHandler(err) {
      console.log('setUserId returned error: ' + err);
  },
  'TEST_USER_ID'
);
```
Setting a user ID.


```js
Carnival.messages(
  function callback(data) {
    console.log('messages successfully returned: ' + data);
  },
  function errorHandler(err) {
    console.log('messages error: ' + err);
  }
);
```
Getting messages.

There are 3 Message Impression Types: StreamView, DetailView and InAppView.
```js
Carnival.registerImpression(Carnival.MessageImpressionType.DetailView, message);
```
Registering message impressions.

```js
Carnival.removeMessage(
  function callback(data) {
    console.log('removeMessage successfully returned');
  },
  function errorHandler(err) {
    console.log('removeMessage returned error: ' + err);
  },
  messageJSON
);
```
Removing a message.

```js
Carnival.markMessageAsRead(
  function callback(data) {
    console.log('markMessageAsRead successfully returned');
  },
  function errorHandler(err) {
    console.log('markMessageAsRead error: ' + err);
  },
  messageJSON
);
```
Mark a message as read.

```js
Carnival.markMessagesAsRead(
  function callback(data) {
    console.log('markMessagesAsRead successfully returned');
  },
  function errorHandler(err) {
    console.log('markMessagesAsRead error: ' + err);
  },
  data
);
```
Marking an array of messages as read.

```js
Carnival.presentMessageDetail(message);
```
Presenting the message detail screen for a message.

```js
Carnival.dismissMessageDetail();
```
Dismissing message detail. (This method does nothing on Android as Activity dismissal is handled by the Activity)

```js
Carnival.unreadCount(
  function callback(unreadCount) {
    console.log('unreadCount succesfully returned: ' + unreadCount);
  },
  function errorHandler(err) {
    console.log('unreadCount error: ' + err);
  }
);
```
Getting the unreadCount of the Carnival Message Stream.

```js
document.addEventListener('unreadcountdidchange', this.onUnreadCountChange, false);
...
onUnreadCountChange: function(event) {
    console.log('unreadCountChanged: ' + event.detail.unreadCount);
}
```
Receiving unreadCountDidChange events

```js
Carnival.deviceID(
  function callback(deviceID) {
    console.log('deviceID successfully returned: ' + deviceID);
  },
  function errorHandler(err) {
    console.log('deviceID error: ' + err);
  }
);
```
Gets the current device's deviceID.
