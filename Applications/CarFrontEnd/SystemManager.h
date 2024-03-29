/*
 * CarFrontEnd - SystemManager.h - David Whittle (iamgnat@gmail.com)
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

@interface SystemManager : NSObject {
    IBOutlet MainViewController *controller;
    IBOutlet PluginManager      *pluginManager;
    IBOutlet CarFrontEndButton  *systemButton;
    IBOutlet CarFrontEndButton  *swapSidesButton;
    IBOutlet CarFrontEndButton  *hideButton;
    IBOutlet NSView             *systemView;
}

- (void) initalize;

#pragma mark Actions
- (IBAction) showSystemView: (id) sender;
- (IBAction) quit: (id) sender;
- (IBAction) hide: (id) sender;
- (IBAction) sideSwap: (id) sender;

#pragma mark Plugin Message observation
- (void) observePluginMessage: (CFEMessage) message with: (id) userInfo;

#pragma mark Other methods
- (void) swapDriverSide;

# pragma mark Key Binding handling
- (void) keyDown: (unsigned short) key options: (unsigned int) options;

@end
