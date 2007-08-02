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

@implementation PluginManager

- (id) init {
    [super init];
    
    // Setup the plugin paths
    pluginList = [[NSMutableDictionary alloc] init];
    orderedPluginList = [[NSMutableArray alloc] init];
    pluginMarker = 0;
    currentPlugin = nil;
    
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
    
    return(self);
}

- (void) initalize {
    [self updatePluginButtons:nil];
    [NSTimer scheduledTimerWithTimeInterval:0.50 target:self
                                   selector:@selector(updatePluginButtons:)
                                   userInfo:nil repeats:YES];
}

#pragma mark Actions
- (IBAction) buttonAction: (id) sender {
    if ([[sender stringValue] isEqualToString:@"Prev"]) {
        pluginMarker -= 6;
        if (pluginMarker < 0) pluginMarker = 0;
        [self updatePluginButtons:nil];
    } else if ([[sender stringValue] isEqualToString:@"More"]) {
        pluginMarker += 6;
        [self updatePluginButtons:nil];
    } else {
        int     i = 0;
        
        if (sender == pluginButton1) {
            i = pluginMarker;
        } else if (sender == pluginButton2) {
            i = pluginMarker + 1;
        } else if (sender == pluginButton3) {
            i = pluginMarker + 2;
        } else if (sender == pluginButton4) {
            i = pluginMarker + 3;
        } else if (sender == pluginButton5) {
            i = pluginMarker + 4;
        } else if (sender == pluginButton6) {
            i = pluginMarker + 5;
        } else {
            NSLog(@"PluginManager: buttonAction: from %@", sender);
            return;
        }
        
        id      plugin = [orderedPluginList objectAtIndex:i];
        if (plugin == currentPlugin) return;
        
        // changeContentView will have been called by the time
        //  replaceContentWith: returns.
        NSView  *view = [plugin contentViewForSize:[controller contentViewFrame].size];
        [controller replaceContentWith:view];
        currentPlugin = [plugin retain];
    }
}

#pragma mark Update buttons
- (void) updatePluginButtons: (id) ignore {
    if ([orderedPluginList count] >= pluginMarker + 1 && [orderedPluginList count] > 0) {
        [pluginButton1 setHidden:NO];
        [pluginButton1 setEnabled:YES];
        if ([orderedPluginList count] > 1) {
            [pluginButton1 setImage:nil];
            [pluginButton1 setStringValue:@"Prev"];
        } else {
            NSImage *image = [[orderedPluginList objectAtIndex:pluginMarker]
                              pluginButtonImage];
            [pluginButton1 setImage:image];
            [pluginButton1 setAlternateImage:image];
        }
    } else {
        [pluginButton1 setHidden:YES];
        [pluginButton1 setEnabled:NO];
        [pluginButton1 setImage:nil];
    }
    
    if ([orderedPluginList count] >= pluginMarker + 2) {
        [pluginButton2 setHidden:NO];
        [pluginButton2 setEnabled:YES];
        NSImage *image = [[orderedPluginList objectAtIndex:pluginMarker + 1]
                          pluginButtonImage];
        [pluginButton2 setImage:image];
        [pluginButton2 setAlternateImage:image];
    } else {
        [pluginButton2 setHidden:YES];
        [pluginButton2 setEnabled:NO];
        [pluginButton2 setImage:nil];
    }
    
    if ([orderedPluginList count] >= pluginMarker + 3) {
        [pluginButton3 setHidden:NO];
        [pluginButton3 setEnabled:YES];
        NSImage *image = [[orderedPluginList objectAtIndex:pluginMarker + 2]
                          pluginButtonImage];
        [pluginButton3 setImage:image];
        [pluginButton3 setAlternateImage:image];
    } else {
        [pluginButton3 setHidden:YES];
        [pluginButton3 setEnabled:NO];
        [pluginButton3 setImage:nil];
    }
    
    if ([orderedPluginList count] >= pluginMarker + 4) {
        [pluginButton4 setHidden:NO];
        [pluginButton4 setEnabled:YES];
        NSImage *image = [[orderedPluginList objectAtIndex:pluginMarker + 3]
                          pluginButtonImage];
        [pluginButton4 setImage:image];
        [pluginButton4 setAlternateImage:image];
    } else {
        [pluginButton4 setHidden:YES];
        [pluginButton4 setEnabled:NO];
        [pluginButton4 setImage:nil];
    }
    
    if ([orderedPluginList count] >= pluginMarker + 5) {
        [pluginButton5 setHidden:NO];
        [pluginButton5 setEnabled:YES];
        NSImage *image = [[orderedPluginList objectAtIndex:pluginMarker + 4]
                          pluginButtonImage];
        [pluginButton5 setImage:image];
        [pluginButton5 setAlternateImage:image];
    } else {
        [pluginButton5 setHidden:YES];
        [pluginButton5 setEnabled:NO];
        [pluginButton5 setImage:nil];
    }
    
    if ([orderedPluginList count] >= pluginMarker + 6) {
        [pluginButton6 setHidden:NO];
        [pluginButton6 setEnabled:YES];
        if ([orderedPluginList count] > pluginMarker + 6) {
            [pluginButton6 setImage:nil];
            [pluginButton6 setStringValue:@"More"];
        } else {
            NSImage *image = [[orderedPluginList objectAtIndex:pluginMarker + 5]
                              pluginButtonImage];
            [pluginButton6 setImage:image];
            [pluginButton6 setAlternateImage:image];
        }
    } else {
        [pluginButton6 setHidden:YES];
        [pluginButton6 setEnabled:NO];
        [pluginButton6 setImage:nil];
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
