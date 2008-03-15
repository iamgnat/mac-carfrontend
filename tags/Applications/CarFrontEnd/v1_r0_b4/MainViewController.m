/*
 * CarFrontEnd - MainViewController.m - David Whittle (iamgnat@gmail.com)
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

#import "MainViewController.h"
#import "PluginManager.h"
#import "AudioVolumeManager.h"
#import "SystemManager.h"

@implementation MainViewController

- (id) init {
    [super init];
    
    mainWindow = nil;
    
#ifndef CFE_DEBUG
    // Capture the main display
    currentDisplayMode = (NSDictionary *) CGDisplayCurrentMode(kCGDirectMainDisplay);
    cfeDisplayMode = currentDisplayMode;
    //cfeDisplayMode = (NSDictionary *) CGDisplayBestModeForParameters(kCGDirectMainDisplay,
    //                                                32, 800, 480, NULL);
    if (CGDisplayCapture(kCGDirectMainDisplay) != kCGErrorSuccess) {
        NSLog( @"Couldn't capture the main display!" );
       [[NSApplication sharedApplication] terminate:nil];
    }
    [currentDisplayMode retain];
    [cfeDisplayMode retain];
    [self changeDisplayTo:cfeDisplayMode];
#endif
    
    // Setup the App support path
    NSFileManager   *fm = [NSFileManager defaultManager];
    appSupportPath = [NSHomeDirectory() stringByAppendingPathComponent:
                      @"Library/Application Support/CarFrontEnd"];
    
    if (![fm fileExistsAtPath:appSupportPath isDirectory:NULL]) {
        [fm createDirectoryAtPath:appSupportPath attributes:nil];
    }
    [appSupportPath retain];
    
    // Load the prefs
    prefsConfigPath = [[appSupportPath stringByAppendingPathComponent:@"CarFrontEnd.plist"]
                       retain];
    prefsConfig = [NSMutableDictionary dictionaryWithContentsOfFile:prefsConfigPath];
    if (prefsConfig == nil) {
        prefsConfig = [NSMutableDictionary dictionary];
    }
    [prefsConfig retain];
    
    return(self);
}

#pragma mark File's Owner Delegates
- (void) applicationDidFinishLaunching: (NSNotification *) notification {
    // Get the shielding window level
    int     windowLevel = CGShieldingWindowLevel();
    
    // Get the screen rect of our main display
    NSRect  screenRect = [[NSScreen mainScreen] frame];
#ifdef CFE_DEBUG
    screenRect.origin.y = screenRect.size.height - 480;
    screenRect.origin.x = 0;
    screenRect.size.width = 800;
    screenRect.size.height = 480;
#endif
    
    // Start the UI update timers.
    [audioVolumeManager initalize];
    [pluginManager initalize];
    [systemManager initalize];
    [self updateDateTime:nil];
    [NSTimer scheduledTimerWithTimeInterval:0.50 target:self
                                   selector:@selector(updateDateTime:)
                                   userInfo:nil repeats:YES];
    
    // Put up a new window
    [self replaceContentWith:splashView];
    mainWindow = [[NSWindow alloc] initWithContentRect:screenRect
#ifndef CFE_DEBUG
                                             styleMask:NSBorderlessWindowMask
#else
                                             styleMask:NSTitledWindowMask
#endif
                                               backing:NSBackingStoreBuffered
                                                 defer:NO
#ifndef CFE_DEBUG
                                                screen:[NSScreen mainScreen]
#endif
                  ];
    
    if ([[[prefsConfig objectForKey:@"CarFrontEnd"] objectForKey:@"DriverSide"]
         isEqualToString:@"right"]) {
        [self swapDriverToSide:@"right"];
    }
    
    [mainView setFrame:screenRect];
    [mainWindow setLevel:windowLevel];
    [mainWindow setTitle:@"CarFrontEnd"];
    [mainWindow setBackgroundColor:[NSColor blackColor]];
    [mainWindow setContentView:mainView];
    [mainWindow makeKeyAndOrderFront:nil];
}

- (void) applicationWillTerminate: (NSNotification *) notification {
    [mainWindow orderOut:self];
    
#ifndef CFE_DEBUG
    // Release the display(s)
    if (CGDisplayRelease( kCGDirectMainDisplay ) != kCGErrorSuccess) {
        NSLog( @"Couldn't release the display(s)!" );
        // Note: if you display an error dialog here, make sure you set
        // its window level to the same one as the shield window level,
        // or the user won't see anything.
    }
#endif
}

// Need to release the display and fix the resolution before we hide the app.
- (void) applicationWillHide: (NSNotification *) notification {
    [self changeDisplayTo:currentDisplayMode];
#ifndef CFE_DEBUG
    if (CGDisplayRelease( kCGDirectMainDisplay ) != kCGErrorSuccess) {
        NSLog( @"Couldn't release the display(s)!" );
        [[NSApplication sharedApplication] terminate:nil];
    }
#endif
}

// Need to reaquire the display and then make mainWindow the front window
//  again after unhide.
// Note: If we make the app change the resolution, we need to bring it back
//          to the desired res here too.
- (void) applicationDidUnhide: (NSNotification *) notification {
#ifndef CFE_DEBUG
    if (CGDisplayCapture(kCGDirectMainDisplay) != kCGErrorSuccess) {
        NSLog( @"Couldn't re-capture the main display!" );
        [[NSApplication sharedApplication] terminate:nil];
    }
#endif
    [self changeDisplayTo:cfeDisplayMode];
    
    NSRect  frame = [mainWindow frame];
    frame.origin.x = 0;
    frame.origin.y = 0;
    [mainWindow setFrame:frame display:YES];
    [mainWindow makeKeyAndOrderFront:nil];
}

#pragma mark Manage Content View
- (void) replaceContentWith: (NSView *) view {
    NSRect  frame = [contentView frame];
    
    frame.origin.x = 0;
    frame.origin.y = 0;
    [view setFrame:frame];
    
    if (contentViewContent == nil) {
        [contentView addSubview:view];
    } else {
        [contentView replaceSubview:contentViewContent with:view];
        [contentViewContent release];
    }
    contentViewContent = [view retain];
    
    // Let the PluginMananger notify the plugin (if applicable) that it has
    //  been replaced.
    [pluginManager changeContentView];
}

#pragma mark Utility Methods
- (void) updateDateTime: (id) ignore {
	NSString			*path = [@"~/Library/Preferences/.GlobalPreferences.plist"
                                 stringByExpandingTildeInPath];
	NSDictionary		*prefs = [NSDictionary dictionaryWithContentsOfFile:path];
	NSString			*dateFormat = [[prefs objectForKey:@"AppleICUDateFormatStrings"]
                                       objectForKey:@"3"];
	NSString			*timeFormat = [[prefs objectForKey:@"AppleICUTimeFormatStrings"]
                                       objectForKey:@"3"];
	NSString			*date, *time;
	CFLocaleRef			locale = NULL;
	CFDateFormatterRef	formatter = NULL;
	
	if (dateFormat == nil) {
		// Default if the user doesn't have anything configured.
		// 2 digit month, 2 digit day, 2 digit year.
		dateFormat = @"MM/dd/yy";
	}
	if (timeFormat == nil) {
		// Default if the user doesn't have anything configured.
		// 24 hour 2 digit hour, 2 digit minute, and 2 digit seconds.
		timeFormat = @"HH:mm:ss";
	}
	
	locale = CFLocaleCopyCurrent();
	formatter = CFDateFormatterCreate(kCFAllocatorDefault, locale,
                                      kCFDateFormatterNoStyle,
                                      kCFDateFormatterNoStyle);
	
    CFDateFormatterSetFormat(formatter, (CFStringRef) dateFormat);
	date = (NSString *) CFDateFormatterCreateStringWithAbsoluteTime(
                                                kCFAllocatorDefault, formatter,
                                                CFAbsoluteTimeGetCurrent());
    
	CFDateFormatterSetFormat(formatter, (CFStringRef) timeFormat);
	time = (NSString *) CFDateFormatterCreateStringWithAbsoluteTime(
                                                kCFAllocatorDefault, formatter,
                                                CFAbsoluteTimeGetCurrent());
    
	CFRelease(locale);
	CFRelease(formatter);
    
    [dateTextField setStringValue:[NSString stringWithFormat:@"%@ %@",
                                   date, time]];
}

- (void) changeDisplayTo: (NSDictionary *) mode {
#ifndef CFE_DEBUG
    CGDisplayErr err = CGDisplaySwitchToMode(kCGDirectMainDisplay,
                                             (CFDictionaryRef) mode);
    if (err != kCGErrorSuccess) {
        NSLog(@"Unable to switch display mode (1): %i", err);
        [[NSApplication sharedApplication] terminate:nil];
    }
#endif
}

- (NSRect) mainWindowFrame {
    return([mainWindow frame]);
}

- (int) mainWindowLevel {
    return([mainWindow level]);
}

- (NSString *) appSupportPath {
    return(appSupportPath);
}

- (NSRect) contentViewFrame {
    return([contentView frame]);
}

- (BOOL) swapDriverToSide: (NSString *) side {
    NSMutableDictionary *prefs = [prefsConfig objectForKey:@"CarFrontEnd"];
    
    if (prefs == nil) {
        prefs = [NSMutableDictionary dictionary];
        [prefs setObject:@"left" forKey:@"DriverSide"];
    }
    
    NSRect      frame;
    NSString    *currSide = [prefs objectForKey:@"DriverSide"];
    
    if ([side isEqualToString:@"left"] && [contentView frame].origin.x == 0) {
        // Move the elements
        NSArray *els = [mainView subviews];
        int     i = 0;
        for (i = 0 ; i < [els count] ; i++) {
            NSView  *el = [els objectAtIndex:i];
            frame = [el frame];
            frame.origin.x = [mainView frame].size.width - frame.size.width - frame.origin.x;
            [el setFrame:frame];
        }
    } else if ([side isEqualToString:@"right"] && [contentView frame].origin.x != 0) {
        // Move the elements
        NSArray *els = [mainView subviews];
        int     i = 0;
        for (i = 0 ; i < [els count] ; i++) {
            NSView  *el = [els objectAtIndex:i];
            frame = [el frame];
            frame.origin.x = [mainView frame].size.width - frame.size.width - frame.origin.x;
            [el setFrame:frame];
        }
    }
    
    if (![currSide isEqualToString:side]) {
        [prefs setObject:side forKey:@"DriverSide"];
        [self setPreferences:prefs forKey:@"CarFrontEnd"];
    }
    
    return(YES);
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

#pragma mark Preferences configInfo
- (NSDictionary *) preferencesForKey: (NSString *) key {
    return([prefsConfig objectForKey:key]);
}

- (void) setPreferences: (NSDictionary *) prefs forKey: (NSString *) key {
    if (prefs == nil) return;
    [prefsConfig setObject:prefs forKey:key];
    [prefsConfig writeToFile:prefsConfigPath atomically:YES];
}

@end
