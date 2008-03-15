/*
 * CarFrontEnd - SystemManager.m - David Whittle (iamgnat@gmail.com)
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

#import "SystemManager.h"
#import "MainViewController.h"
#import "PluginManager.h"

@implementation SystemManager

- (void) initalize {
    if ([[controller currentDriverSide] isEqualToString:@"right"]) {
        [swapSidesButton setStringValue:@"L Drv"];
    } else {
        // Should also handle the pref not being set.
        [swapSidesButton setStringValue:@"R Drv"];
    }
    [self swapDriverSide];
    
    // Setup the plugin messaging observers
    [pluginManager addObserver:self selector:@selector(observePluginMessage:with:)
                          name:CFEMessageMenuShowView];
    [pluginManager addObserver:self selector:@selector(observePluginMessage:with:)
                          name:CFEMessageMenuHideApp];
    [pluginManager addObserver:self selector:@selector(observePluginMessage:with:)
                          name:CFEMessageMenuQuitApp];
    [pluginManager addObserver:self selector:@selector(observePluginMessage:with:)
                          name:CFEMessageMenuSwapSide];
    [pluginManager addObserver:self selector:@selector(observePluginMessage:with:)
                          name:CFEMessageMenuSideSwapped];
}

#pragma mark Actions
- (IBAction) showSystemView: (id) sender {
    [controller replaceContentWith:systemView];
}

- (IBAction) quit: (id) sender {
    [[NSApplication sharedApplication] terminate:nil];
}

- (IBAction) hide: (id) sender {
    [[NSApplication sharedApplication] hide:nil];
}

- (IBAction) sideSwap: (id) sender {
    if ([[controller currentDriverSide] isEqualToString:@"right"]) {
        [controller swapDriverToSide:@"left"];
    } else {
        [controller swapDriverToSide:@"right"];
    }
}

#pragma mark Plugin Message observation
- (void) observePluginMessage: (CFEMessage) message with: (id) userInfo {
    if (CFEMessagesEqual(CFEMessageMenuShowView, message)) {
        [self showSystemView:nil];
    } else if (CFEMessagesEqual(CFEMessageMenuHideApp, message)) {
        [self hide:nil];
    } else if (CFEMessagesEqual(CFEMessageMenuQuitApp, message)) {
        [self quit:nil];
    } else if (CFEMessagesEqual(CFEMessageMenuSwapSide, message)) {
        if (userInfo == nil || ![userInfo isKindOfClass:[NSString class]] ||
            (![userInfo isEqualToString:@"left"] &&
             ![userInfo isEqualToString:@"right"])) {
            [self sideSwap:nil];
        } else {
            [controller swapDriverToSide:userInfo];
        }
    } else if (CFEMessagesEqual(CFEMessageMenuSideSwapped, message)) {
        if ([userInfo isEqualToString:@"right"]) {
            [swapSidesButton setStringValue:@"L Drv"];
        } else {
            [swapSidesButton setStringValue:@"R Drv"];
        }
        
        [self swapDriverSide];
    }
}

#pragma mark Other methods
- (void) swapDriverSide {
    NSRect      frame;
    NSString    *side = [controller currentDriverSide];
    
    if ([side isEqualToString:@"left"] && [hideButton frame].origin.x >= 20) {
        // Move the elements
        NSArray *els = [systemView subviews];
        int     i = 0;
        for (i = 0 ; i < [els count] ; i++) {
            NSView  *el = [els objectAtIndex:i];
            frame = [el frame];
            frame.origin.x = [systemView frame].size.width - frame.size.width - frame.origin.x;
            [el setFrame:frame];
        }
        [systemView setNeedsDisplay:YES];
    } else if ([side isEqualToString:@"right"] && [hideButton frame].origin.x <= 20) {
        // Move the elements
        NSArray *els = [systemView subviews];
        int     i = 0;
        for (i = 0 ; i < [els count] ; i++) {
            NSView  *el = [els objectAtIndex:i];
            frame = [el frame];
            frame.origin.x = [systemView frame].size.width - frame.size.width - frame.origin.x;
            [el setFrame:frame];
        }
        [systemView setNeedsDisplay:YES];
    }
}

@end
