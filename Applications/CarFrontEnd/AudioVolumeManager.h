/*
 * CarFrontEnd - AudioVolumeManager.h - David Whittle (iamgnat@gmail.com)
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
@class PluginManager;

@interface AudioVolumeManager : NSObject {
    IBOutlet MainViewController *controller;
    IBOutlet PluginManager      *pluginManager;
    IBOutlet CarFrontEndButton  *muteButton;
    IBOutlet CarFrontEndButton  *volumeButton;
    IBOutlet NSLevelIndicator   *volumeLevel;
    IBOutlet NSView             *volumeView;
    IBOutlet NSButton           *volumeDownButton;
    IBOutlet NSButton           *volumeUpButton;
    
    NSAppleScript               *outputMuted;
    NSAppleScript               *outputMute;
    NSAppleScript               *outputUnMute;
    NSAppleScript               *outputVolume;
    
    NSImage                     *volumeMute;
    NSImage                     *volumeUnmute;
    
    NSWindow                    *volumeWindow;
    NSTimer                     *volumeWindowTimer;
}

- (void) initalize;

#pragma mark Actions
- (IBAction) openVolumeWindow: (id) sender;
- (IBAction) changeVolume: (id) sender;
- (IBAction) muteVolume: (id) sender;

#pragma mark Utility Methods
- (void) closeVolumeWindow: (id) ignored;
- (void) setVolume: (int) level;
- (int) volumeLevel;
- (void) updateVolumeSettings: (id) ignored;

#pragma mark Plugin Message observation
- (void) observePluginMessage: (CFEMessage) message with: (id) userInfo;

@end
