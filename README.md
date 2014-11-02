Carnival SDK Cordova Plugin

This repo contains cordova plugins for both iOS and Android as well as a demo app that contains examples of how to use the SDK.

## Installation

`cordova plugin add https://github.com/carnivalmobile/carnival-sdk-cordova.git`

### iOS

Add a preference to your config.xml file with your Carnival App key (from [http://app.carnivalmobile.com](http://app.carnivalmobile.com)).

e.g.

```xml
<platform name="ios">
    <preference name="carnival_ios_app_key" value="YOUR_APP_KEY_GOES_HERE" />
</platform>
```

### Methods

```js
Carnival.startEngine();
```

> Sets the Carnival appKey credentials for this app. This method uses the value of the `carnival_ios_app_key` in your config.xml file.
 
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
> Asyncronously gets the tags for Carnival for this Device.

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
> Asyncronously sets the tags for Carnival for this Device.

```js
Carnival.addTags(
                  function callback(data) {
                    console.log('addTags returned: ' + data);
                  },
                  function errorHandler(err) {
                    console.log('addTags error: ' + err);
                  },
                  ['EXAMPLE_ADDED_TAG']
                );
```
> Asyncronously adds the tag to Carnival for this Device.  If the tag is already registered with Carnival, this method does not add the tag again.

```js
Carnival.showMessageStream();
```
> Shows the Carnival Message Stream
