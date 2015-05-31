# Webim iOS Sample App
This application demonstrates usage of [Webim SDK for iOS](https://webim.ru/help/mobile-sdk/ios-sdk-howto/)

### Version
Version 1.8 with SDK 2.0

### Usage
Application works with demo account. If you are registered user, you can use your account name (see development section)

Webim SDK supports two kinds of chats:
 - Realtime chat (when requires immediate response from operator)
 - Offline chat (when there are no online operators, will be replied later)

Both could be initiated using SDK's so called "sessions" - WMSesssion and WMOfflineSession. Please, read documentation at [Webim SDK for iOS](https://webim.ru/help/mobile-sdk/ios-sdk-howto/)

### Development
Sample app initializes both online and offline sessions. Depending on your needs, you can use only one of them. Look at WebimController.m for initializing code.

##### Online/Realtime chat
When using realtime session, only one chat is available.
Create that session with your account settings:
- account name
- location
- user fields
- delegate object
Specify your delegate object, which will be informed about changes on your realtime session: new message, start/stop chat, etc..

##### Offline Chat
Offline chats doesn't update unless getHistory* method is called. Thus, your application is responsible for setting updates events for offline chats. History updates a list of chats available for your user.

##### Push Notifications
To be able to receive push notifications, enable them for your app and contact with support team.

License
-------
    
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.