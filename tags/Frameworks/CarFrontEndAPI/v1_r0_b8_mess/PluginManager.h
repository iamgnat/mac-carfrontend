/*
 * CarFrontEndAPI - CarFrontEndProtocol.h - David Whittle (iamgnat@gmail.com)
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

#import <Foundation/Foundation.h>
#import <CarFrontEndAPI/CarFrontEndAPI.h>

#pragma mark Plugin message utility methods
@protocol PluginMessaging

// Register a method to respond to a given message.
- (void) addObserver: (id) object selector: (SEL) selector
                name: (CFEMessage) message;

// Unregister your method for a message.
- (void) removeObserver: (id) object name: (CFEMessage) message;

// Unregister the object for all messages it listens for.
- (void) removeAllObserversFor: (id) object;

// Send a message for other plugins or CFE to respond to.
- (void) sendMessage: (CFEMessage) message withObject: (id) userInfo;

@end

#pragma mark Plugin management utilities.
@protocol PluginPlugins

// Returns an array of plugin names.
- (NSArray *) plugins;

// Takes the index of a plugin (as returned by -plugins) and loads it's
//  content view.
- (void) loadViewForPlugin: (int) pluginIndex;

// Load the contentView of the plugin associated to the first Quick Slot.
- (void) quickSlot1;

// Load the contentView of the plugin associated to the second Quick Slot if
//  applicable.
- (void) quickSlot2;

// Load the contentView of the plugin associated to the third Quick Slot if
//  applicable.
- (void) quickSlot3;

@end

#pragma mark Plugin generic utility methods
@protocol PluginUtilities

// Return a new window object configured to meet the basic CFE standards.
- (NSWindow *) windowWithContentRect: (NSRect) frame;

@end

#pragma mark Plugin CarFrontEnd utility methods
@protocol PluginCarFrontEnd

// Returns the current volume level.
- (NSNumber *) currentVolumeLevel;

// Returns (left/right) the current side considered the driver's side.
- (NSString *) currentDriverSide;

@end

#pragma mark Plugin Preferences methods
@protocol PluginPreferences

// Returns the current preferences for the given plugin.
//  This is based on the value returned by the -name method of the plugin, so
//      it is critical not to share names with other plugins.
- (NSDictionary *) preferencesForPlugin: (id <CarFrontEndProtocol>) plugin;

// Stores the given preferences dictionary.
//  The structure of the dictionary is completely arbitrary from CFE's point
//      of view and completely in the Plugin's control.
//  This is based on the value returned by the -name method of the plugin, so
//      it is critical not to share names with other plugins.
- (void) savePreferences: (NSDictionary *) pluginPreferences
              forPlugin: (id <CarFrontEndProtocol>) plugin;

@end
