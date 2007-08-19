/*
 * CarFrontEnd - PluginListView.h - gnat (iamgnat@gmail.com)
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
/*
 *  This subclass will create a matrix like view of buttons.
 *  As the view is resized, it will adjust the number buttons horizontally
 *  so that they fit within the new view size.
 *
 *  NB: Need to add support for scrolling when there are more rows than are
 *  completly visible.
 *
 */
@interface PluginListView : NSView {
    NSMutableArray  *items;
    float           buttonWidth;
    float           buttonHeight;
    float           buttonPad;
}

#pragma mark Grouping size information
- (void) setWidth: (float) width;
- (float) width;
- (void) setHeight: (float) height;
- (float) height;
- (void) setPad: (float) pad;
- (float) pad;

#pragma mark Group management
- (CarFrontEndButton *) addButtonWithImage: (NSImage *) image
                                    target: (id) target
                               andSelector: (SEL) selector;
- (void) removeButton: (CarFrontEndButton *) uButton;
- (NSRect) frameRelativeTo: (CarFrontEndButton *) prev
            andContainedBy: (NSRect) frame;
- (void) observeValueForKeyPath: (NSString *) keyPath ofObject: (id) object
                         change: (NSDictionary *) change
                        context: (void *) context;

@end
