/*
 * CarFrontEnd - CFEApplication.m - David Whittle (iamgnat@gmail.com)
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

#import "CFEApplication.h"
#import "PluginManager.h"

@implementation CFEApplication

- (id) init {
    [super init];
    pluginManager = [[PluginManager alloc] init];
    return(self);
}

- (void) dealloc {
    [pluginManager release];
    [super dealloc];
}

// I am intercepting events here and passing them to the PluginManager so that
//  we don't have to worry about plugins overriding key bindings that CFE wants
//  (e.g. Cmd + q).
- (void) sendEvent: (NSEvent *) event {
    switch([event type]) {
        case NSKeyDown:
            [pluginManager keyDown:event];
            break;
        default:
            [super sendEvent:event];
    }
}

@end
