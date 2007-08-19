/*
 * CarFrontEnd - PluginManager.h - David Whittle (iamgnat@gmail.com)
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

#import <Cocoa/Cocoa.h>
#import <CarFrontEndAPI/CarFrontEndAPI.h>

@class MainViewController;
@class PluginListView;

@interface PluginManager : NSObject {
    IBOutlet CarFrontEndButton  *pluginButton1;
    IBOutlet CarFrontEndButton  *pluginButton2;
    IBOutlet CarFrontEndButton  *pluginButton3;
    IBOutlet MainViewController *controller;
    IBOutlet PluginListView     *pluginListView;
    IBOutlet CarFrontEndButton  *modifyButton;
    IBOutlet NSTextField        *quickSlotText;
    IBOutlet NSView             *updateQuickSlotsView;
    IBOutlet CarFrontEndButton  *updateQuickSlotsOkButton;
    
    NSMutableDictionary         *pluginPrefs;
    NSMutableDictionary         *pluginList;
    NSMutableArray              *orderedPluginList;
    int                         pluginMarker;
    
    id <CarFrontEndProtocol>    currentPlugin;
    
    NSTimer                     *modifyTimer;
    
    NSWindow                    *quickSlotsWindow;
}

- (void) initalize;

#pragma mark Actions
- (IBAction) buttonAction: (id) sender;

#pragma mark Update buttons
- (void) updateQuickSlots: (id) ignore;

#pragma mark Utilities
- (void) loadPluginsFromPath: (NSString *) pluginPath;
- (void) changeContentView;

@end
