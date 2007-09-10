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
- (void) observePluginMessage: (NSString *) message with: (id) userInfo {
    if ([message isEqualToString:CFEMessageMenuShowView]) {
        [self showSystemView:nil];
    } else if ([message isEqualToString:CFEMessageMenuHideApp]) {
        [self hide:nil];
    } else if ([message isEqualToString:CFEMessageMenuQuitApp]) {
        [self quit:nil];
    } else if ([message isEqualToString:CFEMessageMenuSwapSide]) {
        if (userInfo == nil || ![userInfo isKindOfClass:[NSString class]] ||
            (![userInfo isEqualToString:@"left"] &&
             ![userInfo isEqualToString:@"right"])) {
            [self sideSwap:nil];
        } else {
            [controller swapDriverToSide:userInfo];
        }
    } else if ([message isEqualToString:CFEMessageMenuSideSwapped]) {
        if ([userInfo isEqualToString:@"right"]) {
            [swapSidesButton setStringValue:@"L Drv"];
        } else {
            [swapSidesButton setStringValue:@"R Drv"];
        }
        
        // Add code here to move the controls around to be side friendly.
    }
}

@end
