/*
 * SamplePlugin - SamplePlugin.h - gnat (iamgnat@gmail.com)
 * Copyright (C) 2007  gnat (iamgnat@gmail.com)
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

#import <Cocoa/Cocoa.h>
#import <CarFrontEndAPI/CarFrontEndAPI.h>

@interface SamplePlugin : NSObject <CarFrontEndProtocol> {
    id                  owner;
    IBOutlet NSView     *samplePluginView;
    NSImage             *buttonImage;
}

- (id) initWithPluginManager: (id) pluginManager;
- (NSString *) name;
- (void) initalize;
- (NSImage *) pluginButtonImage;
- (NSView *) contentViewForSize: (NSSize) size;
- (void) removePluginFromView;

- (IBAction) buttonClicked: (id) sender;

@end
