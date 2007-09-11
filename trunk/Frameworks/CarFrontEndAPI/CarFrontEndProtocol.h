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

@protocol CarFrontEndProtocol <NSObject>

// The init method that the PluginManager will call.
- (id) initWithPluginManager: (id) pluginManager;

// Return the name of the plugin.
- (NSString *) name;

// Allow the plugin to perform any startup initialization that may be desired
//  This is called shortly after the plugin is loaded, but is guaranteed to be
//  called before the first call to pluginButton or contentViewForSize:.
//  This will be called regardless of if the plugin is ever used, so care
//  should be taken to only perform work that is absolutely required.
- (void) initalize;

// Return the image to be used for the for the plugin buttons.
//  The current size is 119x45, but this is subject to change so make sure
//  your image will scale up or down effectively.
//  Please cache this data where possible as it will be called as this will
//  be called on a frequent basis (0.1 - 0.2 seconds). This allows you to
//  perform rough animations (e.g. CPU monitor, etc..)
- (NSImage *) pluginButtonImage;

// Return the view to be used for the content view.
//  The client will pass the view size so that you may supply different
//  views based on the size. The client will resize the supplied view
//  before it is displayed.
- (NSView *) contentViewForSize: (NSSize) size;

// Allow the plugin to perform actions when it's view is replaced.
//  Ideally you should stop all processing that is not needed (e.g. UI updates,
//  etc..), but obviously some cases will not fit this scenario.
- (void) removePluginFromView;

@end

