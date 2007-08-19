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

@implementation SystemManager

- (void) initalize {
    NSDictionary    *prefs = [controller preferencesForKey:@"CarFrontEnd"];
    
    if ([[prefs objectForKey:@"DriverSide"] isEqualToString:@"right"]) {
        [swapSidesButton setStringValue:@"L Drv"];
    } else {
        // Should also handle the pref not being set.
        [swapSidesButton setStringValue:@"R Drv"];
    }
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
    if ([[sender stringValue] isEqualToString:@"L Drv"]) {
        if ([controller swapDriverToSide:@"left"]) {
            [sender setStringValue:@"R Drv"];
        }
    } else {
        if ([controller swapDriverToSide:@"right"]) {
            [sender setStringValue:@"L Drv"];
        }
    }
}

@end
