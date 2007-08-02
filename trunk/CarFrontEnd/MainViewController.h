/*
 * CarFrontEnd - MainViewController.h - David Whittle (iamgnat@gmail.com)
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
#import <ApplicationServices/ApplicationServices.h>
#import <CarFrontEndAPI/CarFrontEndAPI.h>

@class AudioVolumeManager;
@class PluginManager;
@class SystemManager;

@interface MainViewController : NSObject {
    IBOutlet AudioVolumeManager *audioVolumeManager;
    IBOutlet PluginManager      *pluginManager;
    IBOutlet SystemManager      *systemManager;
    
    IBOutlet NSTextField        *dateTextField;
    
    IBOutlet NSView             *contentView;
    IBOutlet NSView             *mainView;
    IBOutlet NSView             *splashView;
        
    // Other
    NSString                    *appSupportPath;
    NSView                      *contentViewContent;
    NSWindow                    *mainWindow;
    
    // Resolution change
    NSDictionary                *currentDisplayMode;
    NSDictionary                *cfeDisplayMode;
}

#pragma mark File's Owner Delegates
- (void) applicationDidFinishLaunching: (NSNotification *) notification;
- (void) applicationWillTerminate: (NSNotification *) notification;
- (void) applicationWillHide: (NSNotification *) notification;
- (void) applicationDidUnhide: (NSNotification *) notification;

#pragma mark Manage Content View
- (void) replaceContentWith:(NSView *) view;

#pragma mark Utility Methods
- (void) updateDateTime: (id) ignored;
- (void) changeDisplayTo: (NSDictionary *) mode;
- (NSRect) mainWindowFrame;
- (int) mainWindowLevel;
- (NSString *) appSupportPath;
- (NSRect) contentViewFrame;

#pragma mark AppleScript Utilities
- (NSAppleEventDescriptor *) runWithSource: (id) source
                       andReturnError: (NSDictionary **) error;

@end
