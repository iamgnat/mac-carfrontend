/*
 * CarFrontEnd - AudioVolumeManager.m - David Whittle (iamgnat@gmail.com)
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

#import "AudioVolumeManager.h"
#import "MainViewController.h"

@implementation AudioVolumeManager

- (id) init {
    [super init];
    
    volumeWindow = nil;
    outputMuted = [[NSAppleScript alloc]
                   initWithSource:@"get output muted of (get volume settings)"];
    outputMute = [[NSAppleScript alloc]
                   initWithSource:@"set volume with output muted"];
    outputUnMute = [[NSAppleScript alloc]
                   initWithSource:@"set volume without output muted"];
    outputVolume = [[NSAppleScript alloc]
                    initWithSource:@"get output volume of (get volume settings)"];
    
    NSDictionary    *error = nil;
    if (![outputMuted compileAndReturnError:&error]) {
        NSLog(@"AudioVolumeManager: init: outputMuted: %@",
              [error objectForKey:@"NSAppleScriptErrorMessage"]);
        [self release];
        return(nil);
    }
    if (![outputMute compileAndReturnError:&error]) {
        NSLog(@"AudioVolumeManager: init: outputMute: %@",
              [error objectForKey:@"NSAppleScriptErrorMessage"]);
        [self release];
        return(nil);
    }
    if (![outputUnMute compileAndReturnError:&error]) {
        NSLog(@"AudioVolumeManager: init: outputUnMute: %@",
              [error objectForKey:@"NSAppleScriptErrorMessage"]);
        [self release];
        return(nil);
    }
    if (![outputVolume compileAndReturnError:&error]) {
        NSLog(@"AudioVolumeManager: init: outputVolume: %@",
              [error objectForKey:@"NSAppleScriptErrorMessage"]);
        [self release];
        return(nil);
    }
    
    return(self);
}

- (void) dealloc {
    if (outputMuted != nil) [outputMuted release];
    if (outputMute != nil) [outputMute release];
    if (outputUnMute != nil) [outputUnMute release];
    if (outputVolume != nil) [outputVolume release];
    if (volumeWindow != nil) {
        [volumeWindow close];
    }
    if (volumeWindowTimer != nil) {
        [volumeWindowTimer invalidate];
        [volumeWindowTimer release];
    }
    
    [super dealloc];
}

- (void) initalize {
    [self updateVolumeSettings:nil];
    [NSTimer scheduledTimerWithTimeInterval:0.50 target:self
                                   selector:@selector(updateVolumeSettings:)
                                   userInfo:nil repeats:YES];
    
    // Setup the plugin messaging observers
    [pluginManager addObserver:self selector:@selector(observePluginMessage:with:)
                          name:CFEMessageVolumeMute];
    [pluginManager addObserver:self selector:@selector(observePluginMessage:with:)
                          name:CFEMessageVolumeSet];
}

#pragma mark Actions
- (IBAction) openVolumeWindow: (id) sender {
    if (volumeWindow != nil) {
        [volumeWindow makeKeyAndOrderFront:nil];
        return;
    }
    
    NSRect  mainFrame = [controller mainWindowFrame];
    NSRect  volFrame = [volumeView frame];
    
    NSDictionary    *prefs = [controller preferencesForKey:@"CarFrontEnd"];
    if ([[prefs objectForKey:@"DriverSide"] isEqualToString:@"right"]) {
        volFrame.origin.x = mainFrame.size.width - volFrame.size.width;
    } else {
        volFrame.origin.x = 0;
    }
    volFrame.origin.y = mainFrame.origin.y;
    
    [volumeLevel setIntValue:[self volumeLevel]];
    
    volumeWindow = [[NSWindow alloc] initWithContentRect:volFrame
                                               styleMask:NSBorderlessWindowMask
                                                 backing:NSBackingStoreBuffered
                                                   defer:NO];
    
    [volumeWindow setReleasedWhenClosed:YES];
    [volumeWindow setAlphaValue:0.95];
    [volumeWindow setBackgroundColor:[NSColor blackColor]];
    [volumeWindow setContentView:volumeView];
    [volumeWindow setLevel:[controller mainWindowLevel]];
    [volumeWindow makeKeyAndOrderFront:nil];
    
    if (volumeWindowTimer != nil) {
        [volumeWindowTimer invalidate];
        [volumeWindowTimer release];
    }
    
    volumeWindowTimer = [[NSTimer scheduledTimerWithTimeInterval:3.0 target:self
                                                        selector:@selector(closeVolumeWindow:)
                                                        userInfo:nil repeats:NO]
                         retain];
}

- (IBAction) changeVolume: (id) sender {
    [self setVolume:[volumeLevel intValue]];
}

- (IBAction) muteVolume: (id) sender {
    if (volumeWindowTimer != nil) {
        [volumeWindowTimer invalidate];
        [volumeWindowTimer release];
        volumeWindowTimer = [[NSTimer scheduledTimerWithTimeInterval:5.0 target:self
                                                            selector:@selector(closeVolumeWindow:)
                                                            userInfo:nil repeats:NO]
                            retain];
    }
    
    NSDictionary            *error = nil;
    NSAppleScript           *script = nil;
    NSAppleEventDescriptor  *res = nil;
    
    // Update the mute button
    res = [controller runWithSource:outputMuted andReturnError:&error];
    if (error != nil) {
        NSLog(@"AudioVolumeManager: muteVolume: Unable to get mute setting: %@",
              [error objectForKey:@"NSAppleScriptErrorMessage"]);
        return;
    } else {
        if ([res int32Value]) {
            script = outputUnMute;
        } else {
            script = outputMute;
        }
    }
    
    // Update the mute setting
    error = nil;
    res = [controller runWithSource:script andReturnError:&error];
    if (error != nil) {
        NSLog(@"AudioVolumeManager: muteVolume: Unable to change mute setting: %@",
              [error objectForKey:@"NSAppleScriptErrorMessage"]);
        return;
    }
}

- (IBAction) maxVolume: (id) sender {
    [self setVolume:100];
}

#pragma mark Utility Methods
- (void) closeVolumeWindow: (id) ignored {
    if (volumeWindowTimer != nil) {
        [volumeWindowTimer invalidate];
        [volumeWindowTimer release];
        volumeWindowTimer = nil;
    }
    if (volumeWindow == nil) return;
    
    [volumeWindow close];
    volumeWindow = nil;
}

- (void) setVolume: (int) level {
    if (level > 100) level = 100;
    if (level < 0) level = 0;
    
    NSDictionary    *error = nil;
    NSString        *source = [NSString
                               stringWithFormat:@"set volume output volume %i",
                               level];
    [controller runWithSource:source andReturnError:&error];
    if (error != nil) {
        NSLog(@"AudioVolumeManager: setVolume: Unable to set current system volume: %@: %@",
              source, [error objectForKey:@"NSAppleScriptErrorMessage"]);
        return;
    }
    
    [volumeLevel setIntValue:[self volumeLevel]];
    
    if (volumeWindowTimer != nil) {
        [volumeWindowTimer invalidate];
        [volumeWindowTimer release];
    
        volumeWindowTimer = [[NSTimer scheduledTimerWithTimeInterval:5.0 target:self
                                                            selector:@selector(closeVolumeWindow:)
                                                            userInfo:nil repeats:NO]
                            retain];
    }
    
    // Let everyone know the volume changed (at least from within the app).
    [pluginManager sendMessage:CFEMessageVolumeChanged
                    withObject:[NSNumber numberWithInt:level]];
}

- (int) volumeLevel {
    NSDictionary            *error = nil;
    NSAppleEventDescriptor  *res = [controller runWithSource:outputVolume
                                              andReturnError:&error];
    if (error != nil) {
        NSLog(@"AudioVolumeManager: volumeLevel: Unable to get current system volume: %@",
              [error objectForKey:@"NSAppleScriptErrorMessage"]);
        return(0);
    }
    return([res int32Value]);
}

- (void) updateVolumeSettings: (id) ignored {
    NSDictionary            *error = nil;
    NSString                *source = nil;
    NSAppleEventDescriptor  *res = nil;
    
    // Update the mute button
    res = [controller runWithSource:outputMuted andReturnError:&error];
    if (error != nil) {
        NSLog(@"AudioVolumeManager: updateUI: Unable to get mute setting: %@: %@",
              source, [error objectForKey:@"NSAppleScriptErrorMessage"]);
    } else {
        if ([res int32Value]) {
            [muteButton setTitle:@"unmute"];
        } else {
            [muteButton setTitle:@"mute"];
        }
    }
    
    // Update the volume slider
    [volumeLevel setIntValue:[self volumeLevel]];
}

#pragma mark Plugin Message observation
- (void) observePluginMessage: (NSString *) message with: (id) userInfo {
    if ([message isEqualToString:CFEMessageVolumeMute]) {
        [self muteVolume:nil];
    } else if ([message isEqualToString:CFEMessageVolumeSet]) {
        if (userInfo != nil && [userInfo respondsToSelector:@selector(intValue)]) {
            [self setVolume:[userInfo intValue]];
        }
    }
}

@end
