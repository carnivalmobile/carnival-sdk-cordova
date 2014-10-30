/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
var app = {
    // Application Constructor
    initialize: function() {
        this.bindEvents();
    },
    // Bind Event Listeners
    //
    // Bind any events that are required on startup. Common events are:
    // 'load', 'deviceready', 'offline', and 'online'.
    bindEvents: function() {
        document.addEventListener('deviceready', this.onDeviceReady, false);
    },
    // deviceready Event Handler
    //
    // The scope of 'this' is the event. In order to call the 'receivedEvent'
    // function, we must explicitly call 'app.receivedEvent(...);'
    onDeviceReady: function() {
        app.receivedEvent('deviceready');
        
        CarnivalCordovaPlugin.startEngine('d532cb136cb5d6154d9b2a07dc8bf19d1c53afbc');
        
        var getTagsButton = document.getElementById('getTags');
        var setTagsButton = document.getElementById('setTags');
        var addTagsButton = document.getElementById('addTags');
        var showStreamButton = document.getElementById('showStream');
        
        // getTags
        getTagsButton.addEventListener('click', function() {
                                       CarnivalCordovaPlugin.getTags(
                                                                     function callback(data) {
                                                                     console.log('getTags returned: ' + data);
                                                                     },
                                                                     function errorHandler(err) {
                                                                     console.log('getTags error: ' + err);
                                                                     }
                                                                     );
                                       });
        
        // setTags
        setTagsButton.addEventListener('click', function() {
                                       CarnivalCordovaPlugin.setTags(
                                                                     function callback(data) {
                                                                     console.log('setTags returned: ' + data);
                                                                     },
                                                                     function errorHandler(err) {
                                                                     console.log('setTags error: ' + err);
                                                                     },
                                                                     ['EXAMPLE_SET_TAG_1', 'EXAMPLE_SET_TAG_2']
                                                                     );
                                       });
        
        // addTags
        addTagsButton.addEventListener('click', function() {
                                       CarnivalCordovaPlugin.addTags(
                                                                     function callback(data) {
                                                                     console.log('addTags returned: ' + data);
                                                                     },
                                                                     function errorHandler(err) {
                                                                     console.log('addTags error: ' + err);
                                                                     },
                                                                     ['EXAMPLE_ADDED_TAG']
                                                                     );
                                       });
        
        // showStream
        showStreamButton.addEventListener('click', function() {
                                          CarnivalCordovaPlugin.showMessageStream();
                                          });
    },
    // Update DOM on a Received Event
    receivedEvent: function(id) {
        var parentElement = document.getElementById(id);
        var listeningElement = parentElement.querySelector('.listening');
        var receivedElement = parentElement.querySelector('.received');

        listeningElement.setAttribute('style', 'display:none;');
        receivedElement.setAttribute('style', 'display:block;');

        console.log('Received Event: ' + id);
    }
};

app.initialize();