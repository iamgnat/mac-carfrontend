/*
 * CarFrontEnd - iTunesViewController.m - David Whittle (iamgnat@gmail.com)
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

#import "iTunesViewController.h"

static iTunesViewController *sharedITVC = nil;

@implementation iTunesViewController

- (id) init {
    return([self initWithPluginManager:nil]);
}

- (id) initWithPluginManager: (id) pluginManager {
    if (sharedITVC != nil) {
        [self release];
        return(sharedITVC);
    }
    
    [super init];
    
    // Setup for a single instance.
    sharedITVC = self;
    
    owner = pluginManager;
    if (owner != nil) [owner retain];
    
    // Generate our button image
    NSMutableDictionary     *attributes = [NSMutableDictionary dictionary];
    NSSize                  stringSize;
    NSRect                  imageSize;

    [attributes setObject:[NSFont fontWithName:@"Helvetica" size:24]
                   forKey:NSFontAttributeName];
	[attributes setObject:[NSColor whiteColor] forKey:NSForegroundColorAttributeName];
	stringSize = [@"iTunes" sizeWithAttributes:attributes];
	imageSize.size = stringSize;
    imageSize.origin = NSZeroPoint;
    
    // Setup the AppleScripts
    prevTrackScript = [[NSAppleScript alloc]
                       initWithSource:@"tell application \"iTunes\" to previous track"];
    playScript = [[NSAppleScript alloc]
                  initWithSource:@"tell application \"iTunes\" to play"];
    pauseScript = [[NSAppleScript alloc]
                   initWithSource:@"tell application \"iTunes\" to pause"];
    nextTrackScript = [[NSAppleScript alloc]
                       initWithSource:@"tell application \"iTunes\" to next track"];
    shuffleOnScript = [[NSAppleScript alloc]
                       initWithSource:@"tell application \"iTunes\" to set shuffle of current playlist to true"];
    shuffleOffScript = [[NSAppleScript alloc]
                        initWithSource:@"tell application \"iTunes\" to set shuffle of current playlist to false"];
    repeatAllScript = [[NSAppleScript alloc]
                    initWithSource:@"tell application \"iTunes\" to set song repeat of current playlist to all"];
    repeatOneScript = [[NSAppleScript alloc]
                    initWithSource:@"tell application \"iTunes\" to set song repeat of current playlist to one"];
    repeatOffScript = [[NSAppleScript alloc]
                    initWithSource:@"tell application \"iTunes\" to set song repeat of current playlist to off"];
    playerInfoScript = [[NSAppleScript alloc]
                        initWithSource:@"set info to {}\ntell application \"iTunes\"\nset info to info & {(player position)}\nset info to info & {(duration of current track as integer)}\nset info to info & {(player state as string)}\nset info to info & {(shuffle of current playlist)}\nset info to info & {(song repeat of current playlist as string)}\nset info to info & {(id of current track)}\nend tell\nget info"];
    trackInfoScript = [[NSAppleScript alloc]
                       initWithSource:@"set info to {}\ntell application \"iTunes\"\nset info to info & {(artist of current track)}\nset info to info & {(album of current track)}\nset info to info & {(name of current track)}\ntry\nset info to info & {(data of (get first artwork of current track))}\nend try\nend tell\nget info"];
    playlistsScript = [[NSAppleScript alloc]
                       initWithSource:@"set info to {}\ntell application \"iTunes\"\nrepeat with s in sources\nset x to {}\nset x to x & name of s\nset x to x & kind of s\nset ps to {}\nrepeat with p in playlists of s\nset ps to ps & name of p\nend repeat\nset x to x & {ps}\nset info to info & {x}\nend repeat\nend tell\nget info"];
    currentPlaylistScript = [[NSAppleScript alloc]
                             initWithSource:@"tell application \"iTunes\" to get name of container of current playlist & \": \" & name of current playlist"];
    
    // Compile the scripts
    NSDictionary    *error = nil;
    if (![prevTrackScript compileAndReturnError:&error]) {
        NSLog(@"iTunesViewController: init: prevTrackScript: %@",
              [error objectForKey:@"NSAppleScriptErrorMessage"]);
        [self release];
        return(nil);
    }
    if (![playScript compileAndReturnError:&error]) {
        NSLog(@"iTunesViewController: init: playScript: %@",
              [error objectForKey:@"NSAppleScriptErrorMessage"]);
        [self release];
        return(nil);
    }
    if (![pauseScript compileAndReturnError:&error]) {
        NSLog(@"iTunesViewController: init: pauseScript: %@",
              [error objectForKey:@"NSAppleScriptErrorMessage"]);
        [self release];
        return(nil);
    }
    if (![nextTrackScript compileAndReturnError:&error]) {
        NSLog(@"iTunesViewController: init: nextTrackScript: %@",
              [error objectForKey:@"NSAppleScriptErrorMessage"]);
        [self release];
        return(nil);
    }
    if (![shuffleOnScript compileAndReturnError:&error]) {
        NSLog(@"iTunesViewController: init: shuffleOnScript: %@",
              [error objectForKey:@"NSAppleScriptErrorMessage"]);
        [self release];
        return(nil);
    }
    if (![shuffleOffScript compileAndReturnError:&error]) {
        NSLog(@"iTunesViewController: init: shuffleOffScript: %@",
              [error objectForKey:@"NSAppleScriptErrorMessage"]);
        [self release];
        return(nil);
    }
    if (![repeatAllScript compileAndReturnError:&error]) {
        NSLog(@"iTunesViewController: init: repeatAllScript: %@",
              [error objectForKey:@"NSAppleScriptErrorMessage"]);
        [self release];
        return(nil);
    }
    if (![repeatOneScript compileAndReturnError:&error]) {
        NSLog(@"iTunesViewController: init: repeatOneScript: %@",
              [error objectForKey:@"NSAppleScriptErrorMessage"]);
        [self release];
        return(nil);
    }
    if (![repeatOffScript compileAndReturnError:&error]) {
        NSLog(@"iTunesViewController: init: repeatOffScript: %@",
              [error objectForKey:@"NSAppleScriptErrorMessage"]);
        [self release];
        return(nil);
    }
    if (![playerInfoScript compileAndReturnError:&error]) {
        NSLog(@"iTunesViewController: init: playerInfoScript: %@",
              [error objectForKey:@"NSAppleScriptErrorMessage"]);
        [self release];
        return(nil);
    }
    if (![trackInfoScript compileAndReturnError:&error]) {
        NSLog(@"iTunesViewController: init: trackInfoScript: %@",
              [error objectForKey:@"NSAppleScriptErrorMessage"]);
        [self release];
        return(nil);
    }
    if (![playlistsScript compileAndReturnError:&error]) {
        NSLog(@"iTunesViewController: init: playlistsScript: %@",
              [error objectForKey:@"NSAppleScriptErrorMessage"]);
        [self release];
        return(nil);
    }
    if (![currentPlaylistScript compileAndReturnError:&error]) {
        NSLog(@"iTunesViewController: init: currentPlaylistScript: %@",
              [error objectForKey:@"NSAppleScriptErrorMessage"]);
        [self release];
        return(nil);
    }
    
    return(self);
}

- (void) dealloc {
    if (fastTimer != nil) {
        [fastTimer invalidate];
        [fastTimer release];
    }
    if (playlistTimer != nil) {
        [playlistTimer invalidate];
        [playlistTimer release];
    }
    
    if (pluginButtonImage != nil) [pluginButtonImage release];
    if (prevTrackScript != nil) [prevTrackScript release];
    if (playScript != nil) [playScript release];
    if (pauseScript != nil) [pauseScript release];
    if (nextTrackScript != nil) [nextTrackScript release];
    if (shuffleOnScript != nil) [shuffleOnScript release];
    if (shuffleOffScript != nil) [shuffleOffScript release];
    if (repeatAllScript != nil) [repeatAllScript release];
    if (repeatOneScript != nil) [repeatOneScript release];
    if (repeatOffScript != nil) [repeatOffScript release];
    if (playerInfoScript != nil) [playerInfoScript release];
    if (trackInfoScript != nil) [trackInfoScript release];
    if (playlistsScript != nil) [playlistsScript release];
    if (currentPlaylistScript != nil) [currentPlaylistScript release];
    if (owner != nil) [owner release];
    
    [super dealloc];
}

#pragma mark CarFrontEndProtocol methods
- (NSString *) name {
    return(@"iTunesMusicPlayer");
}

- (void) initalize {
    NSString    *resourcePath = [[NSBundle bundleForClass:[iTunesViewController
                                                           class]] resourcePath];
    NSImage     *itunes = [[[NSImage alloc] initWithContentsOfFile:[resourcePath
                            stringByAppendingPathComponent:@"iTunes.tif"]]
                           autorelease];
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    CarFrontEndButton   *button = [CarFrontEndButton new];

    [attributes setObject:[NSFont systemFontOfSize:27.0]
                   forKey:NSFontAttributeName];
	[attributes setObject:[button textColor]
                   forKey:NSForegroundColorAttributeName];
    [button release];
	NSSize  size = [@" iTunes" sizeWithAttributes:attributes];
    
    [itunes setScalesWhenResized:YES];
    [itunes scaleForHeight:size.height];
    size.width += [itunes size].width;
    
    NSPoint     origin = NSZeroPoint;
    NSRect      rect = NSZeroRect;
    pluginButtonImage = [[NSImage alloc] initWithSize:size];
    origin.x = [itunes size].width;
    rect.size = [itunes size];
    [pluginButtonImage lockFocus];
    [itunes drawInRect:rect fromRect:NSZeroRect
             operation:NSCompositeSourceOver fraction:1.0];
    [@" iTunes" drawAtPoint:origin withAttributes:attributes];
    [itunes unlockFocus];
    
    // Setup the key bindings
    [owner addKeyBinding:self selector:@selector(keyDown:options:)
                     key:NSRightArrowFunctionKey
                 options:NSShiftKeyMask|NSFunctionKeyMask|NSNumericPadKeyMask];
    [owner addKeyBinding:self selector:@selector(keyDown:options:)
                     key:10 options:0];
    [owner addKeyBinding:self selector:@selector(keyDown:options:)
                     key:13 options:0];
    [owner addKeyBinding:self selector:@selector(keyDown:options:)
                     key:3 options:NSNumericPadKeyMask];
    [owner addKeyBinding:self selector:@selector(keyDown:options:)
                     key:NSLeftArrowFunctionKey
                 options:NSShiftKeyMask|NSFunctionKeyMask|NSNumericPadKeyMask];
    [owner addKeyBinding:self selector:@selector(keyDown:options:)
                     key:NSUpArrowFunctionKey
                 options:NSShiftKeyMask|NSFunctionKeyMask|NSNumericPadKeyMask];
    [owner addKeyBinding:self selector:@selector(keyDown:options:)
                     key:NSRightArrowFunctionKey
                 options:NSFunctionKeyMask|NSNumericPadKeyMask];
    [owner addKeyBinding:self selector:@selector(keyDown:options:)
                     key:' ' options:0];
    [owner addKeyBinding:self selector:@selector(keyDown:options:)
                     key:NSLeftArrowFunctionKey
                 options:NSFunctionKeyMask|NSNumericPadKeyMask];
    [owner addKeyBinding:self selector:@selector(keyDown:options:)
                     key:'m' options:0];
    [owner addKeyBinding:self selector:@selector(keyDown:options:)
                     key:'s' options:0];
    [owner addKeyBinding:self selector:@selector(keyDown:options:)
                     key:'r' options:0];

    return;
}

- (NSImage *) pluginButtonImage {
    return(pluginButtonImage);
}

- (NSView *) contentViewForSize: (NSSize) size {
    if (iTunesView == nil) {
        [NSBundle loadNibNamed:@"iTunesMusicPlayer" owner:self];
        
        // Start iTunes
        NSDictionary            *error = nil;
        NSAppleEventDescriptor  *res = nil;
        
        res = [self runWithSource:playScript andReturnError:&error];
        if (error != nil) {
            NSLog(@"iTunesViewController: contentViewForSize: %@",
                  [error objectForKey:@"NSAppleScriptErrorMessage"]);
            return(nil);
        }
    }
    
    // Update the playlists
    NSNotificationCenter    *nc = [[NSWorkspace sharedWorkspace] notificationCenter];
    [self updateSourceList:nil];
	[nc addObserver:self selector:@selector(updateSourceList:)
               name:NSWorkspaceDidMountNotification object:nil];
	[nc addObserver:self selector:@selector(updateSourceList:)
               name:NSWorkspaceDidUnmountNotification object:nil];
    
    // Start the update timer.
    [self fastTimer:nil];
    fastTimer = [[NSTimer scheduledTimerWithTimeInterval:0.25 target:self
                                                selector:@selector(fastTimer:)
                                                userInfo:nil repeats:YES]
                 retain];
    
    // Update the driver side.
    [owner addObserver:self selector:@selector(swapDriverSide:with:)
                  name:CFEMessageMenuSideSwapped];
    [self swapDriverSide:CFEMessageMenuSideSwapped with:nil];
    
    // We don't care about the size, it's one view for all sizes here.
    return(iTunesView);
}

- (void) removePluginFromView {
    // Stop the timer.
    [fastTimer invalidate];
    [fastTimer release];
    fastTimer = nil;
    
    if (playlistTimer != nil) {
        [playlistTimer invalidate];
        [playlistTimer release];
        playlistTimer = nil;
    }
    
    // Stop caring about disk mount activity
    NSNotificationCenter    *nc = [[NSWorkspace sharedWorkspace] notificationCenter];
    [nc removeObserver:self];
    
    // Ignore driver side swap messages
    [owner removeObserver:self name:CFEMessageMenuSideSwapped];
}

#pragma mark Actions
- (IBAction) selectPlaylist: (id) sender {
    NSDictionary            *error = nil;
    NSString                *script = nil;
    NSAppleEventDescriptor  *res = nil;
    NSDictionary            *list = [[sourceList selectedObjects] objectAtIndex:0];
    
    if (list == nil) return;
    
    NSString    *source = [list objectForKey:@"source"];
    NSString    *playlist = [list objectForKey:@"playlist"];
    if ([[list objectForKey:@"type"] isEqualToString:@"library"]) {
        script = [NSString
                  stringWithFormat:@"tell application \"iTunes\" to play playlist \"%@\"",
                  playlist];
    } else {
        script = [NSString
                  stringWithFormat:@"tell application \"iTunes\" to tell source \"%@\" to play playlist \"%@\"",
                  source, playlist];
    }
    res = [self runWithSource:script andReturnError:&error];
    if (error != nil) {
        NSLog(@"iTunesViewController: selectPlaylist: %@: %@",
              source, [error objectForKey:@"NSAppleScriptErrorMessage"]);
        return;
    }
}

- (IBAction) ejectMedia: (id) sender {
    NSDictionary            *error = nil;
    NSString                *script = nil;
    NSAppleEventDescriptor  *res = nil;
    NSDictionary            *list = [[sourceList selectedObjects] objectAtIndex:0];
    
    if (list == nil) return;
    
    NSString    *source = [list objectForKey:@"source"];
    NSString    *type = [list objectForKey:@"type"];
    
    if ([type isEqualToString:@"library"]) return;
    if ([type isEqualToString:@"radio tuner"]) return;
    
    if ([type isEqualToString:@"iPod"]) {
        script = [NSString stringWithFormat:@"tell application \"iTunes\"\npause\neject \"%@\"\nend tell",
                  source];
    } else {
        script = [NSString stringWithFormat:@"tell application \"iTunes\" to pause\ntell application \"Finder\" to eject \"%@\"",
                  source];
    }
    
    res = [self runWithSource:script andReturnError:&error];
    if (error != nil) {
        NSLog(@"iTunesViewController: ejectMedia: %@: %@",
              script, [error objectForKey:@"NSAppleScriptErrorMessage"]);
        return;
    }
}

- (IBAction) jumpToPositionInTrack: (id) sender {
    NSDictionary            *error = nil;
    NSString                *source = nil;
    NSAppleEventDescriptor  *res = nil;
    
    source = [NSString
              stringWithFormat:@"tell application \"iTunes\" to set player position to %d",
              [trackTimeIndicator intValue]];
    res = [self runWithSource:source andReturnError:&error];
    if (error != nil) {
        NSLog(@"iTunesViewController: jumpToPositionInTrack: %@: %@",
              source, [error objectForKey:@"NSAppleScriptErrorMessage"]);
        return;
    }
}

- (IBAction) prevTrack: (id) sender {
    NSDictionary            *error = nil;
    NSAppleEventDescriptor  *res = nil;
    
    // Restart the current track if we have advanced more than 10 seconds.
    if ([trackTimeIndicator intValue] > 10) {
        [trackTimeIndicator setIntValue:0];
        [self jumpToPositionInTrack:nil];
        return;
    }
    
    res = [self runWithSource:prevTrackScript andReturnError:&error];
    if (error != nil) {
        NSLog(@"iTunesViewController: prevTrack: %@",
              [error objectForKey:@"NSAppleScriptErrorMessage"]);
        return;
    }
}

- (IBAction) playPause: (id) sender {
    NSDictionary            *error = nil;
    NSAppleScript           *script = nil;
    NSAppleEventDescriptor  *res = nil;
    
    if ([[playPauseButton stringValue] isEqualToString:@">"]) {
        script = playScript;
    } else {
        script = pauseScript;
    }
    
    res = [self runWithSource:script andReturnError:&error];
    if (error != nil) {
        NSLog(@"iTunesViewController: playPause: %@",
              [error objectForKey:@"NSAppleScriptErrorMessage"]);
        return;
    }
}

- (IBAction) nextTrack: (id) sender {
    NSDictionary            *error = nil;
    NSAppleEventDescriptor  *res = nil;
    
    res = [self runWithSource:nextTrackScript andReturnError:&error];
    if (error != nil) {
        NSLog(@"iTunesViewController: nextTrack: %@",
              [error objectForKey:@"NSAppleScriptErrorMessage"]);
        return;
    }
}

- (IBAction) changeMixMode: (id) sender {
    NSDictionary            *error = nil;
    NSAppleScript           *script = nil;
    NSAppleEventDescriptor  *res = nil;
    
    if ([[mixModeButton stringValue] isEqualToString:@"no mix"]) {
        script = shuffleOffScript;
    } else {
        script = shuffleOnScript;
    }
    res = [self runWithSource:script andReturnError:&error];
    if (error != nil) {
        NSLog(@"iTunesViewController: changeMixMode: %@",
              [error objectForKey:@"NSAppleScriptErrorMessage"]);
        return;
    }
}

- (IBAction) changeRepeatMode: (id) sender {
    NSDictionary            *error = nil;
    NSAppleScript           *script = nil;
    NSAppleEventDescriptor  *res = nil;
    
    if ([[repeatModeButton stringValue] isEqualToString:@"off"]) {
        script = repeatAllScript;
    } else if ([[repeatModeButton stringValue] isEqualToString:@"all"]) {
        script = repeatOneScript;
    } else {
        script = repeatOffScript;
    }
    res = [self runWithSource:script andReturnError:&error];
    if (error != nil) {
        NSLog(@"iTunesViewController: changeRepeatMode: %@",
              [error objectForKey:@"NSAppleScriptErrorMessage"]);
        return;
    }
}

#pragma mark AppleScript Utilities
- (NSAppleEventDescriptor *) runWithSource: (id) source
                            andReturnError: (NSDictionary **) error {
    NSAppleScript           *script = nil;
    
    // [NSString class] == NSString unlike NSCFString of an instance...
    if ([source class] == [@"" class]) {
        script = [[[NSAppleScript alloc] initWithSource:source] autorelease];
    } else {
        script = source;
    }
    NSAppleEventDescriptor  *res = [script executeAndReturnError:error];
    
    return(res);
}

#pragma mark UI management
- (void) fastTimer: (id) ignored {
    NSDictionary            *error = nil;
    NSAppleEventDescriptor  *res = nil;
    
    res = [self runWithSource:playerInfoScript andReturnError:&error];
    if (error != nil) {
        NSString    *msg = [error objectForKey:@"NSAppleScriptErrorMessage"];
        
        // Probably just ejected a source and no playlist has been selected
        //  to play yet.
        // NB: It's the apostrophe...
        if (![msg isEqualToString:@"Can’t make duration of current track into type integer."])
            NSLog(@"iTunesViewController: fastTimer: playerInfo: %@", msg);
        [artistNameField setStringValue:@"No information available."];
        [albumNameField setStringValue:@"No information available."];
        [trackNameField setStringValue:@"No information available."];
        [albumArtImage setImage:nil];
        [trackTimeIndicator setIntValue:0];
        [currentTrackTimeField setStringValue:[self formatTime:0]];
        [trackTimeIndicator setMaxValue:0.0];
        [trackTimeField setStringValue:[self formatTime:0]];
        currentTrackId = -1;
        return;
    }
    
    // Play/Pause
    if ([[[res descriptorAtIndex:3] stringValue] isEqualToString:@"paused"]) {
        [playPauseButton setStringValue:@">"];
    } else {
        [playPauseButton setStringValue:@"||"];
    }
    
    // Mix Mode
    if ([[[res descriptorAtIndex:4] stringValue] isEqualToString:@"true"]) {
        [mixModeButton setStringValue:@"no mix"];
    } else {
        [mixModeButton setStringValue:@"mix"];
    }

    // Repeat Mode
    [repeatModeButton setStringValue:[[res descriptorAtIndex:5] stringValue]];
    
    int trackId = [[res descriptorAtIndex:6] int32Value];
    
    // Elapsed time
    [trackTimeIndicator setIntValue:[[res descriptorAtIndex:1] int32Value]];
    [currentTrackTimeField
     setStringValue:[self formatTime:[[res descriptorAtIndex:1] int32Value]]];
    
    // Track time
    float   maxValue = [[res descriptorAtIndex:2] int32Value] * 1.0;
    if (trackId != currentTrackId) {
        currentTrackId = trackId;
        res = [self runWithSource:trackInfoScript andReturnError:&error];
        if (error != nil) {
            NSLog(@"iTunesViewController: fastTimer: trackInfo: %@",
                  [error objectForKey:@"NSAppleScriptErrorMessage"]);
            [artistNameField setStringValue:@"No information available."];
            [albumNameField setStringValue:@"No information available."];
            [trackNameField setStringValue:@"No information available."];
            [albumArtImage setImage:nil];
            [trackTimeIndicator setMaxValue:0.0];
            [trackTimeField setStringValue:[self formatTime:0]];
            return;
        }
        [artistNameField setStringValue:[[res descriptorAtIndex:1] stringValue]];
        [albumNameField setStringValue:[[res descriptorAtIndex:2] stringValue]];
        [trackNameField setStringValue:[[res descriptorAtIndex:3] stringValue]];
        
        // Album Art
        if ([res numberOfItems] < 4) {
            [albumArtImage setImage:nil];
        } else {
            NSImage *art = [[[NSImage alloc] initWithData:[[res descriptorAtIndex:4] data]]
                            autorelease];
            [art setScalesWhenResized:YES];
            if ([art size].width > [art size].height) {
                [art scaleForWidth:[albumArtImage frame].size.width];
            } else {
                [art scaleForHeight:[albumArtImage frame].size.height];
            }
            [albumArtImage setImage:art];
        }
        
        // Playlists
        res = [self runWithSource:currentPlaylistScript andReturnError:&error];
        if (error != nil) {
            NSLog(@"iTunesViewController: fastTimer: playlist: %@",
                  [error objectForKey:@"NSAppleScriptErrorMessage"]);
        } else {
            NSArray     *playlists = [sourceList content];
            NSString    *name = [res stringValue];
            int         i = 0;
            
            for (i = 0 ; i < [playlists count] ; i++) {
                if ([name isEqualToString:[[playlists objectAtIndex:i]
                                           objectForKey:@"displayName"]]) {
                    [sourceList setSelectionIndex:i];
                    break;
                }
            }
            if (i == [playlists count]) [sourceList setSelectionIndex:0];
        }
    }
    [trackTimeIndicator setMaxValue:maxValue];
    [trackTimeField setStringValue:[self formatTime:(int) maxValue]];
}

- (NSString *) formatTime: (int) value {
    int     secs = value % 60;
    int     mins = value / 60;
    
    return [NSString stringWithFormat:@"%02i:%02i", mins, secs];
    
}

- (void) swapDriverSide: (CFEMessage) message with: (id) userInfo {
    if (!CFEMessagesEqual(CFEMessageMenuSideSwapped, message)) return;
    
    NSRect      frame;
    NSString    *side = [owner currentDriverSide];
    
    if ([side isEqualToString:@"left"] && [ejectMediaButton frame].origin.x <= 20) {
        // Move the elements
        NSArray *els = [iTunesView subviews];
        int     i = 0;
        for (i = 0 ; i < [els count] ; i++) {
            NSView  *el = [els objectAtIndex:i];
            frame = [el frame];
            frame.origin.x = [iTunesView frame].size.width - frame.size.width - frame.origin.x;
            [el setFrame:frame];
        }
        [iTunesView setNeedsDisplay:YES];
    } else if ([side isEqualToString:@"right"] && [ejectMediaButton frame].origin.x >= 20) {
        // Move the elements
        NSArray *els = [iTunesView subviews];
        int     i = 0;
        for (i = 0 ; i < [els count] ; i++) {
            NSView  *el = [els objectAtIndex:i];
            frame = [el frame];
            frame.origin.x = [iTunesView frame].size.width - frame.size.width - frame.origin.x;
            [el setFrame:frame];
        }
        [iTunesView setNeedsDisplay:YES];
    }
}

#pragma mark Playlist management
- (void) updateSourceList:(id) arg {
    NSDictionary            *error = nil;
    NSAppleEventDescriptor  *res = nil;
    
    if (arg != playlistTimer) {
        if (playlistTimer != nil) {
            [playlistTimer invalidate];
            [playlistTimer release];
        }
        playlistTimer = [[NSTimer scheduledTimerWithTimeInterval:3 target:self
                                                        selector:@selector(updateSourceList:)
                                                        userInfo:nil
                                                         repeats:NO] retain];
        return;
    }
    [playlistTimer release];
    playlistTimer = nil;
    
    res = [self runWithSource:playlistsScript andReturnError:&error];
    if (error != nil) {
        NSLog(@"iTunesViewController: updateSourceList: playlists: %@",
              [error objectForKey:@"NSAppleScriptErrorMessage"]);
        return;
    }
    
    [sourceList removeObjects:[sourceList content]];
    
    int     i = 0;
    for (i = 1 ; i <= [res numberOfItems] ; i++) {
        NSAppleEventDescriptor  *s = [res descriptorAtIndex:i];
        NSString                *source = [[s descriptorAtIndex:1] stringValue];
        NSString                *type = [[s descriptorAtIndex:2] stringValue];
        NSAppleEventDescriptor  *lists = [s descriptorAtIndex:3];
        
        int c = 0;
        for (c = 1 ; c <= [lists numberOfItems] ; c++) {
            NSMutableDictionary *el = [NSMutableDictionary dictionary];
            NSString            *list = [[lists descriptorAtIndex:c] stringValue];
            
            [el setObject:[NSString stringWithFormat:@"%@: %@", source, list]
                   forKey:@"displayName"];
            [el setObject:source forKey:@"source"];
            [el setObject:type forKey:@"type"];
            [el setObject:list forKey:@"playlist"];
            [sourceList addObject:el];
        }
    }
    
    res = [self runWithSource:currentPlaylistScript andReturnError:&error];
    if (error != nil) {
        NSLog(@"iTunesViewController: fastTimer: playlist: %@",
              [error objectForKey:@"NSAppleScriptErrorMessage"]);
    } else {
        NSArray     *playlists = [sourceList content];
        NSString    *name = [res stringValue];
        int         i = 0;
        
        for (i = 0 ; i < [playlists count] ; i++) {
            if ([name isEqualToString:[[playlists objectAtIndex:i]
                                       objectForKey:@"displayName"]]) {
                [sourceList setSelectionIndex:i];
                break;
            }
        }
        if (i == [playlists count]) [sourceList setSelectionIndex:0];
    }
}

# pragma mark Key Binding handling
- (void) keyDown: (unsigned short) key options: (unsigned int) options {
    if (key == NSRightArrowFunctionKey && options & NSShiftKeyMask) {
        // Shift + right arrow = Previous playlist
        if ([sourceList selectionIndex] == 0) return;
        [sourceList setSelectionIndex:[sourceList selectionIndex] - 1];
    } else if (key == 10 || key == 13 || (key == 3 &&
               options & NSNumericPadKeyMask)) {
        // Enter/Return = select playlist
        [self selectPlaylist:nil];
    } else if (key == NSLeftArrowFunctionKey && options & NSShiftKeyMask) {
        // Shift + left arrow = Previous playlist
        if ([sourceList selectionIndex] + 1 >= [[sourceList arrangedObjects] count])
            return;
        [sourceList setSelectionIndex:[sourceList selectionIndex] + 1];
    } else if (key == NSUpArrowFunctionKey && options & NSShiftKeyMask) {
        // Shift + up arrow = Eject device
        [self ejectMedia:self];
    } else if (key == NSRightArrowFunctionKey) {
        // right arrow = prev track
        [self prevTrack:nil];
    } else if (key == ' ') {
        // space = play/pause
        [self playPause:nil];
    } else if (key == NSLeftArrowFunctionKey) {
        // left arrow = next track
        [self nextTrack:nil];
    } else if (key == 's' || key == 'm') {
        // s/m = change shuffle mode
        [self changeMixMode:nil];
    } else if (key == 'r') {
        // r = change repeat mode
        [self changeRepeatMode:nil];
    }
}

@end
