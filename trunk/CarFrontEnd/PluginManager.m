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
#import "AudioVolumeManager.h"
#import "SystemManager.h"

static PluginManager    *sharedPM = nil;

@implementation PluginManager

- (id) init {
    if (sharedPM != nil) return(sharedPM);
    
    [super init];
    sharedPM = [self retain];
    
    messagingList = [[NSMutableDictionary alloc] init];
    keyBindingList = [[NSMutableDictionary alloc] init];
    
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
    pluginPrefs = [NSMutableDictionary dictionaryWithDictionary:[controller
                                             preferencesForKey:@"PluginManager"]];
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
    
    // Setup the key bindings
    [self addKeyBinding:self selector:@selector(keyDown:options:)
                    key:'1' options:NSCommandKeyMask];
    [self addKeyBinding:self selector:@selector(keyDown:options:)
                    key:'2' options:NSCommandKeyMask];
    [self addKeyBinding:self selector:@selector(keyDown:options:)
                    key:'3' options:NSCommandKeyMask];
    
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
        [self displayPluginByTag:tag];
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
            pInst = [[pClass alloc] initWithPluginManager:self];
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
            [self addKeyBinding:self selector:@selector(keyDown:options:)
                            key:[orderedPluginList count] - 1 + 32
                        options:NSCommandKeyMask|NSShiftKeyMask];

        }
    }
}

- (void) changeContentView {
    if (currentPlugin == nil) return;
    
    [currentPlugin removePluginFromView];
    [currentPlugin release];
    currentPlugin = nil;
}

- (void) changingContentView {
    if (currentPlugin == nil) return;
    
    id  cp = currentPlugin; // Just to get rid of warnings about the method
    //  not being part of the protocol.
    if ([cp respondsToSelector:@selector(viewWillBeRemovedFromView)]) {
        [cp viewWillBeRemovedFromView];
    }
}

- (void) displayPluginByTag: (int) tag {
    if (tag < 0 || tag >= [orderedPluginList count]) return;
    
    id      plugin = [orderedPluginList objectAtIndex:tag];
    if (plugin == currentPlugin) return;
    
    // changeContentView will have been called by the time
    //  replaceContentWith: returns.
    NSView  *view = [plugin contentViewForSize:[controller contentViewFrame].size];
    
    [controller replaceContentWith:view];
    currentPlugin = [plugin retain];
    if ([plugin respondsToSelector:@selector(viewWasMadeVisible)]) {
        [plugin viewWasMadeVisible];
    }
}

#pragma mark Plugin message utility methods

- (void) addObserver: (id) object selector: (SEL) selector
                name: (CFEMessage) message {
    NSMutableArray      *objects = [messagingList objectForKey:message.name];
    NSMethodSignature   *sig = [[object class]
                                instanceMethodSignatureForSelector:selector];
    NSInvocation        *sel = [NSInvocation invocationWithMethodSignature:sig];
    BOOL                found = NO;
    int                 i = 0;
    
    [sel setTarget:object];
    [sel setSelector:selector];
    
    if (objects == nil) {
        objects = [NSMutableArray array];
        [messagingList setObject:objects forKey:message.name];
    }
    
    // See if we are replacing an existing observation.
    for (i = 0 ; i < [objects count] ; i++) {
        NSMutableDictionary *info = [objects objectAtIndex:i];
        
        if ([info objectForKey:@"observer"] == object &&
            [[info objectForKey:@"activeOnly"] boolValue] == message.activeOnly) {
            [info setObject:sel forKey:@"selector"];;
            found = YES;
            break;
        }
    }
    
    if (!found) {
        NSMutableDictionary *info = [NSMutableDictionary dictionary];
        [info setObject:object forKey:@"observer"];
        [info setObject:sel forKey:@"selector"];
        [info setObject:[NSNumber numberWithBool:message.activeOnly]
                 forKey:@"activeOnly"];
        [objects addObject:info];
    }
}

- (void) removeObserver: (id) object name: (CFEMessage) message {
    NSMutableArray  *objects = [messagingList objectForKey:message.name];
    int             i = 0;
    
    if (objects == nil) return;
    for (i = 0 ; i < [objects count] ; i++) {
        NSDictionary    *info = [objects objectAtIndex:i];
        
        if ([info objectForKey:@"observer"] == object &&
            [[info objectForKey:@"activeOnly"] boolValue] == message.activeOnly) {
            [objects removeObjectAtIndex:i];
        }
    }
}

- (void) removeAllObserversFor: (id) object {
    NSArray     *messages = [messagingList allKeys];
    int         i = 0;
    
    for (i = 0 ; i < [messages count] ; i++) {
        [self removeObserver:object name:(CFEMessage){[messages objectAtIndex:i], YES}];
    }
}

- (void) sendMessage: (CFEMessage) message withObject: (id) userInfo {
    NSMutableArray  *objects = [messagingList objectForKey:message.name];
    int             i = 0;
    
    if (objects == nil) return;
    
    for (i = 0 ; i < [objects count] ; i++) {
        NSMutableDictionary *info = [objects objectAtIndex:i];
        id                  obj = [info objectForKey:@"observer"];
        NSInvocation        *sel = [info objectForKey:@"selector"];
        BOOL                activeOnly = [[info objectForKey:@"activeOnly"]
                                          boolValue];
        
        // Next object if not the current plugin or a CFE object.
        if (activeOnly && [obj conformsToProtocol:@protocol(CarFrontEndProtocol)] &&
            currentPlugin != obj) continue;
        
        [sel setArgument:&message atIndex:2];
        [sel setArgument:&userInfo atIndex:3];
        [sel invoke];
    }
}

#pragma mark Plugin management utilities.

- (NSArray *) plugins {
    NSMutableArray  *names = [NSMutableArray array];
    int             i = 0;
    
    for (i = 0 ; i < [orderedPluginList count] ; i++) {
        [names addObject:[[orderedPluginList objectAtIndex:i] name]];
    }
    
    return(names);
}

- (void) loadViewForPlugin: (int) pluginIndex {
    NSView  *view = [[orderedPluginList objectAtIndex:pluginIndex]
                     contentViewForSize:[controller contentViewFrame].size];
    [controller replaceContentWith:view];
    currentPlugin = [[orderedPluginList objectAtIndex:pluginIndex] retain];
}

- (void) quickSlot1 {
    [self buttonAction:pluginButton1];
}

- (void) quickSlot2 {
    [self buttonAction:pluginButton2];
}

- (void) quickSlot3 {
    [self buttonAction:pluginButton3];
}

#pragma mark Plugin generic utility methods

- (NSWindow *) windowWithContentRect: (NSRect) frame {
    NSWindow    *window = [[NSWindow alloc] initWithContentRect:frame
                                               styleMask:NSBorderlessWindowMask
                                                 backing:NSBackingStoreBuffered
                                                   defer:NO];
    
    [window setReleasedWhenClosed:YES];
    [window setBackgroundColor:[NSColor blackColor]];
    [window setLevel:[controller mainWindowLevel]];
    return(window);
}

- (NSWindow *) mainWindow {
    return([controller mainWindow]);
}

#pragma mark Plugin CarFrontEnd utility methods
- (NSNumber *) currentVolumeLevel {
    return([NSNumber numberWithInt:[audioVolumeManager volumeLevel]]);
}

- (NSString *) currentDriverSide {
    return([controller currentDriverSide]);
}


#pragma mark Plugin Preferences methods
- (NSDictionary *) preferencesForPlugin: (id <CarFrontEndProtocol>) plugin {
    NSDictionary    *prefs = [NSDictionary dictionaryWithDictionary:[pluginPrefs
                                                        objectForKey:@"PluginPrefs"]];
    
    // Stupid hack to avoid "-className not found in protocol" warnings at
    //  compile time.
    NSString        *name = [[plugin name]
                             stringByAppendingString:[plugin performSelector:@selector(className)]];
    
    if (prefs == nil) return(nil);
    return([NSDictionary dictionaryWithDictionary:[prefs objectForKey:name]]);
}

- (void) savePreferences: (NSDictionary *) pluginPreferences
               forPlugin: (id <CarFrontEndProtocol>) plugin {
    NSMutableDictionary *prefs = [NSMutableDictionary
                                  dictionaryWithDictionary:[pluginPrefs
                                                            objectForKey:@"PluginPrefs"]];
    NSString            *name = [[plugin name]
                                 stringByAppendingString:[plugin performSelector:@selector(className)]];
    
    if (pluginPrefs == nil) return;
    
    if (prefs == nil) {
        prefs = [NSMutableDictionary dictionary];
        [pluginPrefs setObject:prefs forKey:@"PluginPrefs"];
    }
    
    [prefs setObject:pluginPrefs forKey:name];
    
    return([controller setPreferences:pluginPrefs forKey:@"PluginManager"]);
}

#pragma mark Key Binding methods
- (void) keyDown: (NSEvent *) event {
    if ([event type] != NSKeyDown) return;
    
    unsigned short  key = [[event charactersIgnoringModifiers] characterAtIndex:0];
    int             options = [event modifierFlags];
    NSString        *keyStr = [NSString stringWithFormat:@"%@%i",
                                [self keyOptionsToString:options], key];
    id              obj = [keyBindingList objectForKey:keyStr];
    
#ifdef CFE_DEBUG
    NSLog(@"Processing %@", keyStr);
#endif
    
    if (obj == nil) return; // Key bound, but not with modifiers.

    if ([obj class] != [[NSMutableDictionary dictionary] class]) {
        NSDictionary    *temp = nil;
        int i = 0;
        
        for (i = 0 ; i < [obj count] ; i++) {
            if (currentPlugin == [[obj objectAtIndex:i] objectForKey:@"observer"]) {
                temp = [obj objectAtIndex:i];
            }
        }
        if (temp == nil) return; // Current plugin not watching for the key.
        obj = temp;
    }
    
    // Call the selector
    NSInvocation    *sel = [obj objectForKey:@"selector"];
    
    [sel setArgument:&key atIndex:2];
    [sel setArgument:&options atIndex:3];
    [sel invoke];
}

- (void) addKeyBinding: (id) object selector: (SEL) selector
                 key: (unsigned short) key options: (unsigned int) options {
    NSString            *keyStr = [NSString stringWithFormat:@"%@%i",
                                    [self keyOptionsToString:options], key];
    id                  objects = [keyBindingList objectForKey:keyStr];
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    NSMethodSignature   *sig = [[object class]
                                instanceMethodSignatureForSelector:selector];
    NSInvocation        *sel = [NSInvocation invocationWithMethodSignature:sig];
    
    [sel setTarget:object];
    [sel setSelector:selector];
    [info setObject:object forKey:@"observer"];
    [info setObject:sel forKey:@"selector"];
    
    if (object == controller || object == systemManager ||
        object == audioVolumeManager || object == self) {
        if (objects == nil) {
            [keyBindingList setObject:info forKey:keyStr];
        } else if ([objects class] == [[NSMutableDictionary dictionary] class] &&
                   [objects objectForKey:@"observer"] != object) {
            NSLog(@"PluginManager: %@: %@ is already in use!", [object class],
                  keyStr);
        } else {
            NSLog(@"PluginManager: %@ being overridden by CarFrontEnd!", keyStr);
            [keyBindingList setObject:info forKey:keyStr];
        }
    } else {
        if ([objects class] == [[NSMutableDictionary dictionary] class]) {
            NSLog(@"PluginManager: %@: %@ is already in use by CarFrontEnd!",
                  [object class], keyStr);
        } else {
            int     i = 0;
            BOOL    found = NO;
            
            if (objects == nil) {
                objects = [NSMutableArray array];
                [keyBindingList setObject:objects forKey:keyStr];
            }
            
            for (i = 0 ; i < [objects count] ; i++) {
                if ([[objects objectAtIndex:i] objectForKey:@"observer"] == object) {
                    found = YES;
                    break;
                }
            }
            
            if (!found) [objects addObject:info];
        }
    }
    
#ifdef CFE_DEBUG
    NSLog(@"Bound %@", keyStr);
#endif
}

- (void) removeKeyBinding: (id) object forKey: (unsigned short) key
                  options: (unsigned int) options {
    NSString    *keyStr = [NSString stringWithFormat:@"%@%i",
                                    [self keyOptionsToString:options], key];
    id          objects = [keyBindingList objectForKey:keyStr];
    
    if (objects == nil) return;
    
    if ([objects class] == [[NSMutableDictionary dictionary] class] &&
        [objects objectForKey:@"observer"] == object) {
        [keyBindingList removeObjectForKey:keyStr];
    } else {
        int     i = 0;
        for (i = 0 ; i < [objects count] ; i++) {
            NSDictionary    *info = [objects objectAtIndex:i];
            
            if ([info objectForKey:@"observer"] == object) {
                [objects removeObjectAtIndex:i];
            }
        }
    }
}

- (void) removeAllKeyBindingsFor: (id) object {
    NSArray     *keyBindings = [keyBindingList allKeys];
    int         i = 0;
    
    // Loop through all the bound keys.
    for (i = 0 ; i < [keyBindings count] ; i++) {
        NSArray *opts = [[keyBindingList
                            objectForKey:[keyBindings objectAtIndex:i]]
                            allKeys];
        int     c = 0;
        
        // Loop through all the options for the given key.
        for (c = 0 ; c < [opts count] ; c++) {
            [self removeKeyBinding:object
                            forKey:[[keyBindings objectAtIndex:i]
                                        characterAtIndex:0]
                           options:[[opts objectAtIndex:c] intValue]];
        }
    }
}

// See NSEvent class reference for modifier flags.
//  NB: Not supporting the NSDeviceIndependentModifierFlagsMask flag.
- (NSString *) keyOptionsToString: (unsigned int) options {
    NSMutableString *str = [NSMutableString string];
    
    if (options & NSAlphaShiftKeyMask) [str appendString:@"Caps + "];
    if (options & NSShiftKeyMask) [str appendString:@"Shift + "];
    if (options & NSControlKeyMask) [str appendString:@"Ctrl + "];
    if (options & NSAlternateKeyMask) [str appendString:@"Opt + "];
    if (options & NSCommandKeyMask) [str appendString:@"Cmd + "];
    if (options & NSNumericPadKeyMask) [str appendString:@"Num + "];
    if (options & NSHelpKeyMask) [str appendString:@"Help + "];
    if (options & NSFunctionKeyMask) [str appendString:@"Func + "];
    
    return([[str copyWithZone:NULL] autorelease]);
}

# pragma mark Key Binding handling
- (void) keyDown: (unsigned short) key options: (unsigned int) options {
    if (options & NSCommandKeyMask && options & NSShiftKeyMask) {
        // Cmd + Shift + ... = Load plugin based on tag + 32
        int tag = key - 32;
        [self displayPluginByTag:tag];
    } else if (key == '1' && options & NSCommandKeyMask) {
        // Cmd + 1 = Load Quick Slot 1.
        [self displayPluginByTag:[pluginButton1 tag]];
    } else if (key == '2' && options & NSCommandKeyMask) {
        // Cmd + 2 = Load Quick Slot 2
        [self displayPluginByTag:[pluginButton2 tag]];
    } else if (key == '3' && options & NSCommandKeyMask) {
        // Cmd + 3 = Load Quick Slot 3
        [self displayPluginByTag:[pluginButton3 tag]];
    }
}

@end

