/*
 * CarFrontEnd - PluginManager.m - David Whittle (iamgnat@gmail.com)
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

#import "PluginManager.h"
#import "MainViewController.h"
#import "PluginListView.h"

@implementation PluginManager

- (id) init {
    [super init];
    
    // Setup the plugin paths
    pluginList = [[NSMutableDictionary alloc] init];
    orderedPluginList = [[NSMutableArray alloc] init];
    pluginMarker = 0;
    currentPlugin = nil;
    
    return(self);
}

- (void) awakeFromNib {
    [modifyButton setHidden:YES];
    [quickSlotText setHidden:YES];
    
    // Setup the PluginListView
    [pluginListView setPad:20.0];
    [pluginListView setWidth:133.0];
    [pluginListView setHeight:60.0];
    
    // Setup the plugin search path.
    NSFileManager   *fm = [NSFileManager defaultManager];
    NSString        *path = nil;
    
    // ~/Library/Application Support/CarFrontEnd/Plugins
    path = [[controller appSupportPath]
            stringByAppendingPathComponent:@"PlugIns"];
    if (![fm fileExistsAtPath:path isDirectory:NULL]) {
        [fm createDirectoryAtPath:path attributes:nil];
    }
    if ([fm fileExistsAtPath:path isDirectory:NULL]) {
        [self loadPluginsFromPath:path];
    }
    
    // ~/Library/Plugins/CarFrontEnd
    path = [NSHomeDirectory() stringByAppendingPathComponent:
            @"Library/PlugIns/CarFrontEnd"];
    if ([fm fileExistsAtPath:path isDirectory:NULL]) {
        [self loadPluginsFromPath:path];
    }
    
    // /Library/Plugins/CarFrontEnd
    path = @"/Library/PlugIns/CarFrontEnd";
    if ([fm fileExistsAtPath:path isDirectory:NULL]) {
        [self loadPluginsFromPath:path];
    }
    
    // CarFrontEnd.app/Contents/Plugins
    path = [[[NSBundle mainBundle] bundlePath]
            stringByAppendingPathComponent:@"Contents/PlugIns"];
    if ([fm fileExistsAtPath:path isDirectory:NULL]) {
        [self loadPluginsFromPath:path];
    }
    
    // Load the prefs
    pluginPrefs = [NSMutableDictionary dictionaryWithDictionary:[controller preferencesForKey:@"PluginManager"]];
    if ([pluginPrefs count] == 0) {
        pluginPrefs = [NSMutableDictionary dictionary];
        [pluginPrefs setObject:[NSMutableDictionary
                                dictionaryWithObjects:[NSArray
                                                       arrayWithObjects:[NSNumber numberWithInt:0],
                                                       [NSNumber numberWithInt:1],
                                                       [NSNumber numberWithInt:2], nil]
                                forKeys:[NSArray
                                         arrayWithObjects:@"1", @"2", @"3", nil]]
                        forKey:@"QuickSlots"];
        [controller setPreferences:pluginPrefs forKey:@"PluginManager"];
    }
    [pluginPrefs retain];
    
    if ([orderedPluginList count] > 3) {
        [modifyButton setHidden:NO];
        [quickSlotText setHidden:NO];
    }
    
    // Set the quick slots
    [pluginButton1 setTag:[[[pluginPrefs objectForKey:@"QuickSlots"] objectForKey:@"1"] intValue]];
    [pluginButton2 setTag:[[[pluginPrefs objectForKey:@"QuickSlots"] objectForKey:@"2"] intValue]];
    [pluginButton3 setTag:[[[pluginPrefs objectForKey:@"QuickSlots"] objectForKey:@"3"] intValue]];
}

- (void) initalize {
    [self updateQuickSlots:nil];
    [NSTimer scheduledTimerWithTimeInterval:0.50 target:self
                                   selector:@selector(updateQuickSlots:)
                                   userInfo:nil repeats:YES];
}

#pragma mark Actions
- (IBAction) buttonAction: (id) sender {
    if (sender == updateQuickSlotsOkButton) {
        if (quickSlotsWindow == nil) return;
        [quickSlotsWindow close];
        quickSlotsWindow = nil;
    } else if (sender == modifyButton) {
        pluginMarker = -1;
        if ([[modifyButton stringValue] isEqualToString:@"Done"]) {
            [modifyButton setStringValue:@"Modify"];
        } else {
            if (quickSlotsWindow != nil) return;
            [modifyButton setStringValue:@"Done"];
            
            NSRect  mainFrame = [controller mainWindowFrame];
            NSRect  frame = [updateQuickSlotsView frame];
            
            frame.origin.x = (mainFrame.size.width / 2) - (frame.size.width / 2);
            frame.origin.y = (mainFrame.size.height / 2) - (frame.size.height / 2);
            
            quickSlotsWindow = [[NSWindow alloc] initWithContentRect:frame
                                                           styleMask:NSBorderlessWindowMask
                                                             backing:NSBackingStoreBuffered
                                                               defer:NO];
            
            [quickSlotsWindow setReleasedWhenClosed:YES];
            [quickSlotsWindow setAlphaValue:0.85];
            [quickSlotsWindow setBackgroundColor:[NSColor blackColor]];
            [quickSlotsWindow setContentView:updateQuickSlotsView];
            [quickSlotsWindow setLevel:[controller mainWindowLevel]];
            [quickSlotsWindow makeKeyAndOrderFront:nil];
        }
    } else if ([[modifyButton stringValue] isEqualToString:@"Done"]) {
        if (sender == pluginButton1 || sender == pluginButton2 ||
            sender == pluginButton3) {
            if (pluginMarker < 0 || pluginMarker > [orderedPluginList count])
                return;
            
            // It is already in a quick slot, don't allow it to appear more
            //  than once.
            if ([pluginButton1 tag] == pluginMarker) return;
            if ([pluginButton2 tag] == pluginMarker) return;
            if ([pluginButton3 tag] == pluginMarker) return;
            
            // Update the plugin that the button should use.
            [sender setTag:pluginMarker];
            [self updateQuickSlots:nil];
            pluginMarker = -1;
        } else {
            pluginMarker = [sender tag];
        }
    } else {
        int     tag = [sender tag];
        if (tag < 0 || tag >= [orderedPluginList count]) return;
        
        id      plugin = [orderedPluginList objectAtIndex:tag];
        if (plugin == currentPlugin) return;
        
        // changeContentView will have been called by the time
        //  replaceContentWith: returns.
        NSView  *view = [plugin contentViewForSize:[controller contentViewFrame].size];
        [controller replaceContentWith:view];
        currentPlugin = [plugin retain];
    }
}

#pragma mark Update buttons
- (void) updateQuickSlots: (id) ignore {
    if ([orderedPluginList count] > 0) {
        [pluginButton1 setHidden:NO];
        [pluginButton1 setEnabled:YES];
        NSImage *image = [[orderedPluginList objectAtIndex:[pluginButton1 tag]]
                          pluginButtonImage];
        [pluginButton1 setImage:image];
        [pluginButton1 setAlternateImage:image];
    } else {
        [pluginButton1 setHidden:YES];
        [pluginButton1 setEnabled:NO];
        [pluginButton1 setImage:nil];
    }
    
    if ([orderedPluginList count] > 1) {
        [pluginButton2 setHidden:NO];
        [pluginButton2 setEnabled:YES];
        NSImage *image = [[orderedPluginList objectAtIndex:[pluginButton2 tag]]
                          pluginButtonImage];
        [pluginButton2 setImage:image];
        [pluginButton2 setAlternateImage:image];
    } else {
        [pluginButton2 setHidden:YES];
        [pluginButton2 setEnabled:NO];
        [pluginButton2 setImage:nil];
    }
    
    if ([orderedPluginList count] > 2) {
        [pluginButton3 setHidden:NO];
        [pluginButton3 setEnabled:YES];
        NSImage *image = [[orderedPluginList objectAtIndex:[pluginButton3 tag]]
                          pluginButtonImage];
        [pluginButton3 setImage:image];
        [pluginButton3 setAlternateImage:image];
    } else {
        [pluginButton3 setHidden:YES];
        [pluginButton3 setEnabled:NO];
        [pluginButton3 setImage:nil];
    }
}

#pragma mark Utilities
- (void) loadPluginsFromPath: (NSString *) pluginPath {
    NSFileManager           *fm = [NSFileManager defaultManager];
    NSDirectoryEnumerator   *dir = nil;
    NSString                *p = nil;
    
#ifdef CFE_DEBUG
    NSLog(@"PluginManager: Loading plugins from %@", pluginPath);
#endif
    dir = [fm enumeratorAtPath:pluginPath];
    while (p = [dir nextObject]) {
        NSBundle    *bundle;
        Class       pClass;
        id          pInst;
        NSString    *name = nil;
        NSString    *path = [pluginPath stringByAppendingPathComponent:p];
        
        if ([[path pathExtension] isEqualToString:@"cfep"]) {
#ifdef CFE_DEBUG
            NSLog(@"PluginManager: Loading plugin from: %@",
                  path);
#endif
            bundle = [NSBundle bundleWithPath:path];
            if (bundle == nil) {
                NSLog(@"PluginManager: Unable to load plugin from: %@", path);
                continue;
            }
            
            pClass = [bundle principalClass];
            if (![pClass conformsToProtocol:@protocol(CarFrontEndProtocol)]) {
                NSLog(@"PluginManager: %@ is not a CarFrontEnd plugin!", path);
                continue;
            }
            
            pInst = [[pClass alloc] init];
            if (pInst == nil) {
                NSLog(@"PluginManager: Unable to create instance of %@", path);
                continue;
            }
            
            [pInst initalize];
            name = [pInst name];
            
            if ([pluginList objectForKey:name] != nil) {
                NSLog(@"PluginManager: The plugin %@ has already been loaded.",
                      name);
                continue;
            }
            [pluginList setObject:pInst forKey:name];
            [orderedPluginList addObject:pInst];
            [[pluginListView addButtonWithImage:[pInst pluginButtonImage]
                                                target:self
                                                andSelector:@selector(buttonAction:)]
             setTag:[orderedPluginList count] - 1];
        }
    }
}

- (void) changeContentView {
    if (currentPlugin == nil) return;
    
    [currentPlugin removePluginFromView];
    [currentPlugin release];
    currentPlugin = nil;
}

@end
