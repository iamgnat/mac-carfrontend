/*
 * CarFrontEndAPI - CarFrontEndAPI.h - David Whittle (iamgnat@gmail.com)
 * Copyright (C) 2007  David Whittle (iamgnat@gmail.com)
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

// NSNotification messages

#pragma mark CarFrontEnd UI notifications
// If you are building a new UI element, make sure it responds to any
//  CFENotificationChange* messages that relate to it.

// The sender is requesting that the foreground color should be changed.
//  The new NSColor object should be sent as the object value of the
//      notification.
extern NSString *CFENotificationChangeForegroundColor;

// The sender is requesting that the background color should be changed.
//  The new NSColor object should be sent as the object value of the
//      notification.
extern NSString *CFENotificationChangeBackgroundColor;

#pragma mark CarFrontEnd Plugin Messaging
// The CFEMessage structure.
typedef struct cfe_message_struct {
    NSString    *name;      // The name of the message
    BOOL        activeOnly; // Determines if the message should be sent only
                            //  to the active plugin, or all plugins.
                            //  CFE application objects will always get the
                            //  the messages that tey observe.
} CFEMessage;

// Helper function to create a new CFEMessage.
extern CFEMessage CFECreateMessage(NSString *name, BOOL activeOnly);

// Helper method to cleanup CFEMessages when they are no longer needed.
//  This should almost never be used! Make sure you know what you are doing.
extern void CFEDestroyMessage(CFEMessage msg);

// Helper function to compare CFEMessages.
extern BOOL CFEMessagesEqual(CFEMessage msg1, CFEMessage msg2);

#pragma mark CarFrontEnd Volume Messages
// Toggles the current mute setting.
//  CarFrontEnd will always respond to this message.
//  Any userInfo object will be ignored.
extern CFEMessage   CFEMessageVolumeMute;

// Set the volume level to the given value.
//  CarFrontEnd will always respond to this message.
//  The userInfo object should be a NSNumber with a value between 0 and 100.
//  If userInfo does not respond to intValue or the value is outside of the
//      0 to 100 range, no volume change will occur.
extern CFEMessage   CFEMessageVolumeSet;

// Sent when the volume level is changed.
//  It is expected for plugins that are interested in this information will
//      add an observer for it.
//  The current volume level will be passed as a NSNumber in the userInfo.
extern CFEMessage   CFEMessageVolumeChanged;

#pragma mark CarFrontEnd Menu Messages
// Causes the Menu content to be displayed.
//  CarFrontEnd will always respond to this message.
//  Any userInfo value will be ignored.
extern CFEMessage   CFEMessageMenuShowView;

// Causes CarFrontEnd to be hidden.
//  CarFrontEnd will always respond to this message.
//  Any userInfo value will be ignored.
extern CFEMessage   CFEMessageMenuHideApp;

// Causes CarFrontEnd to exit.
//  CarFrontEnd will always respond to this message.
//  Any userInfo value will be ignored.
extern CFEMessage   CFEMessageMenuQuitApp;

// Causes CarFrontEnd to swap the driver side display.
//  CarFrontEnd will always respond to this message.
//  If userInfo does not respond to isEqualToString, is not "left" or "right",
//      or is nil, then it will swap based on the current setting.
//      If it does it will swap to the given side if that is not the current
//      side.
extern CFEMessage   CFEMessageMenuSwapSide;

// Sent when the driver's side is changed.
//  It is expected for plugins that are interested in this information will
//      add an observer for it.
//  The current side (left/right) will be passed as a NSString in the userInfo.
extern CFEMessage   CFEMessageMenuSideSwapped;

#import <CarFrontEndAPI/CarFrontEndProtocol.h>
#import <CarFrontEndAPI/CarFrontEndButton.h>
#import <CarFrontEndAPI/NSImageUtils.h>
#import <CarFrontEndAPI/PluginManager.h>
