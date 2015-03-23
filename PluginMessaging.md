## Introduction ##
Starting with v1.0a7, CarFrontEnd will support the ability for Plugins to communicate between themselves as well as with CarFrontEnd itself.

## Code Support ##

To utilize the messaging system, you have to implement some basic code. The CarFrontEnd Plugin Messaging interface works in a similar manner to _NSNotification_ in that you need a selector to respond to messages (if you are listening for messages), must register for messages you want to know about, and may send messages for the application or other plugins to respond to.

With v1.0a7, the _-initWithPluginManager:_ method is added to the _CarFrontEndProtocol_. This method is called by the PluginManager after it loads your plugin and passes the PluginManager object as it's argument. You must store and retain this object if you wish to use the messaging interface. In the SamplePlugin code shown on the CreatePlugin wiki page, we use the _owner_ variable to store the PluginManager object.

You must also import CarFrontEndAPI/CarFrontEndAPI.h which will load the PluginManager Protocols as well as the currently known messages.

### Sending Messages ###

To send a message, use the _-sendMessage:with:_ method of PluginManager.
```
[owner sendMessage:SomePredefinedMessage with:nil]
```
  * **SomePredefinedMessage** - The message to be sent.
  * **nil** - This is an object that will be passed to any of the observers of this message. The type and value of this argument is dependent on the message being sent (if it is needed at all).

### Processing Messages ###

To respond to messages is slightly more difficult, but still rather simple. You will need a method to process the message(s) and will need to  register for the message.

Your responder must accept two arguments. The first must be a _NSString_ for the message and the second should be the object type (or a plain _id_ is advised) you are expecting.
```
- (void) observePluginMessage: (CFEMessage) message with: (id) userInfo {
    if (CFEMessagesEqual(SomePredefinedMessage, message)]) {
        if (userInfo != nil && [userInfo isKindOfClass:[NSString class]]) {
            NSLog(@"SomePredefinedMessage: %@", userInfo);
        } else {
            NSLog(@"SomePredefinedMessage: No message supplied.");
        }
    }
}
```

You register your responder using the _-addObserver:selector:name:_ method of the PluginManager. This method expects:
  1. **id** - The object observing the message (normally _self_).
  1. **SEL** - The selector of your responder method.
  1. **CFEMessage** - The message to respond to.
```
[owner addObserver:self
                      selector:@selector(observePluginMessage:with:)
                          name:SomePredefinedMessage];
```

We advise that also remove your responder from processing when your Plugin is not the currently active plugin if your response will make UI changes that are not needed at that time.
```
[owner removeObserver:self name:SomePredefinedMessage];
```
  1. **id** - The object that was responding to the message.
  1. **CFEMessage** - The name of the message.

You may also remove all messages for your object at once with _-removeAllObserversFor:_ which takes the observing object as it's only argument.

## CarFrontEnd Messages ##

These are the messages that are built into CarFrontEnd.
| **Name** | **userInfo Type** | **activeOnly** | **Description** | **Notes** |
|:---------|:------------------|:---------------|:----------------|:----------|
| CFEMessageVolumeMute | N/A | YES | Toggles the current mute setting. |  |
| CFEMessageVolumeSet | NSNumber | YES | Set the volume level to the given value. | userInfo will be ignored if it is nil or the value is not between 0 and 100 |
| CFEMessageVolumeChanged | NSNumber | YES | Sent when the volume level is changed. | The userInfo value is the current volume level. This only occurs if the volume is changed by CarFrontEnd. |
| CFEMessageMenuShowView | N/A | YES | Causes the Menu content to be displayed. |  |
| CFEMessageMenuHideApp | N/A | YES | Causes CarFrontEnd to be hidden. |  |
| CFEMessageMenuQuitApp | N/A | YES | Causes CarFrontEnd to exit. |  |
| CFEMessageMenuSwapSide | NSString | YES | Causes CarFrontEnd to swap the driver side display. | userInfo may be nil or a NSString that equals "left" or "right". If the object is nil or does not equal one of those vaules, it will swap the driver side based on the current setting. |
| CFEMessageMenuSideSwapped | NSString | YES | Sent when the driver's side is changed. | The userInfo will be "left" or "right" depending on the new driver side. |

Additional messages will be added over time (and should be added above), but you are free to listen for and send your own custom messages.

### CFEMessage & Helper Functions ###
```
typedef struct cfe_message_struct {
    NSString    *name;      // The name of the message
    BOOL        activeOnly; // Determines if the message should be sent only
                            //  to the active plugin, or all plugins.
                            //  CFE application objects will always get the
                            //  the messages that tey observe.
} CFEMessage;
```

```
CFEMessage CFECreateMessage(NSString *name, BOOL activeOnly)
```
This function will return a new _CFEMessage_ for you.
  * **name** - The textual name of your message.
  * **activeOnly** - YES = The message is only sent to the active plugin. NO = It is sent to all plugins.

```
void CFEDestroyMessage(CFEMessage message)
```
Does the proper cleanup on the given message.

```
BOOL CFEMessagesEqual(CFEMessage message1, CFEMessage2)
```
Tests to see if the name value of the message are equal.

