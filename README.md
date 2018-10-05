Carnival SDK Cordova Plugin

This repo contains cordova plugins for both iOS and Android as well as a demo app that contains examples of how to use the SDK.

## Installation

`cordova plugin add https://github.com/carnivalmobile/carnival-sdk-cordova.git`

> Note:
Node version 8.12.0 will return an error if you attempt to add the SDK:
`Failed to fetch plugin https://github.com/carnivalmobile/carnival-sdk-cordova.git via registry.`
Please use Node version 8.11.4 to add the SDK, as we have confirmed it is working correctly. You can check your Node version using the `node --version` command.

### iOS

Add a preference to your `config.xml` file with your Carnival App key (from [http://app.carnivalmobile.com](http://app.carnivalmobile.com)).

e.g.

```xml
<platform name="ios">
    <preference name="carnival_ios_app_key" value="YOUR_APP_KEY_GOES_HERE" />
</platform>
```

(Optional) To be sure the iOS SDK is up to date; open your Xcode project, which should be located in the `platforms/ios` directory of your Cordova/Phonegap project and Drag and drop the `Carnival.framework` into it. The `Carnival.framework` can be downloaded from the [Carnival iOS SDK repo](https://github.com/carnivalmobile/carnival-ios-sdk/releases).

### Android

Add these preferences to your `config.xml` file with your Carnival App key (from [http://app.carnivalmobile.com](http://app.carnivalmobile.com)).

e.g.

```xml
<platform name="android">
    <preference name="carnival_android_app_key" value="YOUR_APP_KEY_GOES_HERE"/>
</platform>
```

#### Android Notification Icon

During the `startEngine` call on Android, the plugin will look for a drawable in the android project called "ic_stat_notification". This drawable will be loaded as the notification icon in the status bar for all push notifications in your application.

The required icon files can be generated using Android Studio or on online generator such as [Romannurik's Android Asset Studio](https://romannurik.github.io/AndroidAssetStudio/icons-notification.html#source.space.trim=1&source.space.pad=0&name=ic_stat_notification).

These files have to be added to your android project's drawable folder in order for Android to be able to locate them.

Users of PhoneGap Build are not able to set a notification icon.

#### PhoneGap Build
To use Carnival with PhoneGap Build (PGB) there a few additional steps to take.

1. Change the ID on the pluign to something unique to your project, as this has to remain unique within the PhoneGap plugin repo.
2. Add `<preference name="android-build-tool" value="gradle" />` to your App's config.xml such that PBG will use Gradle to build and manage dependencies on Android.

PGB can be tricky, so feel free to [contact us](support@carnival.io) if you need assistance here. We are happy to help.

Note: We're not using NPM because of the inability to distribute .framework files with NPM such that they'll work in PBG. We hope this will be resolved soon.

### Methods

```js
Carnival.startEngine(true);
```
Sets the Carnival appKey credentials for this app. This method uses the value of the `carnival_ios_app_key` in your config.xml file. On iOS, if true, the device will register for push notifications and prompt the user. If you wish to delay this prompt, such as with an onboarding scenario, then pass in false and call `Carnival.registerForPushNotifications()` at a later point.

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

#### Attributes

Use `Carnival.AttributeMap` to set one or more attributes.

```js

var attributeMap = new Carnival.AttributeMap();

// String
attributeMap.setString('teststringkey', 'test string');

// Array of strings
attributeMap.setStringArray(
    'teststringarraykey', [
    'test string 1',
    'test string 2',
]);

// Float
attributeMap.setFloat('testfloatkey', 1.23);

// Array of floats
attributeMap.setFloatArray('testfloatarraykey', [1.23, 42.3]);

// Integer
attributeMap.setInteger('testintegerkey', 7777);

// Array of integers
attributeMap.setIntegerArray('testintegerarraykey', [7777, 1337]);

// Date. You can use JavaScript's native Date object
attributeMap.setDate('testdatekey', new Date());

// Array of dates
attributeMap.setDateArray('testdatearraykey', [new Date(), new Date()]);

// Boolean values
attributeMap.setBoolean('testboolkey', true);

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

Carnival.setAttributes(
  function callback() {
    console.log('setAttributes successfully returned');
  },
  function errorHandler(err) {
    console.log('setAttributes returned error: ' + err);
  },
  attributeMap
);

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

```js
Carnival.registerForPushNotifications();
```
Registers for push notifications, prompting the user on iOS to allow notifications. For use when you pass `false` to startEngine.
