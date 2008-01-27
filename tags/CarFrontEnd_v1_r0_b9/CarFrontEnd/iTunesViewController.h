/*
 * CarFrontEnd - iTunesViewController.h - David Whittle (iamgnat@gmail.com)
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

@interface iTunesViewController : NSObject <CarFrontEndProtocol> {
    id                              owner;
    
    IBOutlet NSView                 *iTunesView;
    
    IBOutlet NSArrayController      *sourceList;
    
    IBOutlet CarFrontEndButton      *prevPlaylistButton;
    IBOutlet CarFrontEndButton      *selectPlaylistButton;
    IBOutlet CarFrontEndButton      *nextPlaylistButton;
    IBOutlet CarFrontEndButton      *ejectMediaButton;
    
    IBOutlet NSImageView            *albumArtImage;
    IBOutlet NSTextField            *artistNameField;
    IBOutlet NSTextField            *albumNameField;
    IBOutlet NSTextField            *trackNameField;
    
    IBOutlet NSLevelIndicator       *trackTimeIndicator;
    IBOutlet NSTextField            *currentTrackTimeField;
    IBOutlet NSTextField            *trackTimeField;
    
    IBOutlet CarFrontEndButton      *prevTrackButton;
    IBOutlet CarFrontEndButton      *playPauseButton;
    IBOutlet CarFrontEndButton      *nextTrackButton;
    IBOutlet CarFrontEndButton      *mixModeButton;
    IBOutlet CarFrontEndButton      *repeatModeButton;
    
    NSImage                         *pluginButtonImage;
    NSImage                         *playImage;
    NSImage                         *pauseImage;
    NSImage                         *repeatAllImage;
    NSImage                         *repeatOffImage;
    NSImage                         *repeatOneImage;
    NSImage                         *shuffleOffImage;
    NSImage                         *shuffleOnImage;
    
    NSTimer                         *fastTimer;
    NSTimer                         *playlistTimer;
    
    NSAppleScript                   *prevTrackScript;
    NSAppleScript                   *playScript;
    NSAppleScript                   *pauseScript;
    NSAppleScript                   *nextTrackScript;
    NSAppleScript                   *shuffleOnScript;
    NSAppleScript                   *shuffleOffScript;
    NSAppleScript                   *repeatAllScript;
    NSAppleScript                   *repeatOneScript;
    NSAppleScript                   *repeatOffScript;
    NSAppleScript                   *playerInfoScript;
    NSAppleScript                   *trackInfoScript;
    NSAppleScript                   *playlistsScript;
    NSAppleScript                   *currentPlaylistScript;
    
    int                             currentTrackId;
}

#pragma mark CarFrontEndProtocol methods
- (id) initWithPluginManager: (id) pluginManager;
- (NSString *) name;
- (void) initalize;
- (NSImage *) pluginButtonImage;
- (NSView *) contentViewForSize: (NSSize) size;
- (void) removePluginFromView;

#pragma mark Actions
- (IBAction) selectPlaylist: (id) sender;
- (IBAction) ejectMedia: (id) sender;

- (IBAction) jumpToPositionInTrack: (id) sender;
- (IBAction) prevTrack: (id) sender;
- (IBAction) playPause: (id) sender;
- (IBAction) nextTrack: (id) sender;
- (IBAction) changeMixMode: (id) sender;
- (IBAction) changeRepeatMode: (id) sender;

#pragma mark AppleScript Utilities
- (NSAppleEventDescriptor *) runWithSource: (id) source
                            andReturnError: (NSDictionary **) error;

#pragma mark UI management
- (void) fastTimer: (id) ignored;
- (NSString *) formatTime: (int) value;
- (void) swapDriverSide: (CFEMessage) message with: (id) userInfo;

#pragma mark Playlist management
- (void) updateSourceList:(id) note;

# pragma mark Key Binding handling
- (void) keyDown: (unsigned short) key options: (unsigned int) options;

@end
