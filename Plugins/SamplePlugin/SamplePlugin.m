/*
 * SamplePlugin - SamplePlugin.m - gnat (iamgnat@gmail.com)
 * Copyright (C) 2007  gnat (iamgnat@gmail.com)
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

#import "SamplePlugin.h"
#import <CarFrontEndAPI/CarFrontEndAPI.h>

static SamplePlugin *sharedSP = nil;

@implementation SamplePlugin

- (id) init {
    return([self initWithPluginManager:nil]);
}

- (void) dealloc {
    [buttonImage release];
    
    [super dealloc];
}

- (id) initWithPluginManager: (id) pluginManager {
    if (sharedSP != nil) {
        [self release];
        return(sharedSP);
    }
    
    [super init];
    owner = [pluginManager retain];
    
    // Setup for a single instance.
    sharedSP = self;
    
    return(self);
}

- (NSString *) name {
    return(@"Sample Plugin");
}

- (void) initalize {
    CarFrontEndButton   *button = [CarFrontEndButton new];
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    
    [attributes setObject:[NSFont systemFontOfSize:27.0]
                   forKey:NSFontAttributeName];
	[attributes setObject:[button textColor]
                   forKey:NSForegroundColorAttributeName];
    [button release];
    [buttonImage release];
    
    NSSize  size = [[self name] sizeWithAttributes:attributes];
    buttonImage = [[[NSImage alloc] initWithSize:size] autorelease];
    
    [buttonImage lockFocus];
    [[self name] drawAtPoint:NSZeroPoint withAttributes:attributes];
    [buttonImage unlockFocus];
}

- (NSImage *) pluginButtonImage {
    return(buttonImage);
}

- (NSView *) contentViewForSize: (NSSize) size {
    // We are ignoring the size value, but it is there incase you have differnt
    //  views based on the size that CarFrontEnd sends you.
    if (samplePluginView == nil) {
        [NSBundle loadNibNamed:@"SamplePlugin" owner:self];
    }
    
    return(samplePluginView);
}

- (void) removePluginFromView {
    // No-op
    //  If you need to do something when your view is no longer displayed,
    //  add the code here.
}

- (IBAction) buttonClicked: (id) sender {
    if ([[sender stringValue] isEqualToString:@"Click"]) {
        [sender setStringValue:@"Clock"];
    } else if ([[sender stringValue] isEqualToString:@"Clock"]) {
        [sender setStringValue:@"Click"];
    }
}

@end
