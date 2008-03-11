/*
 * CarFrontEnd - CFEApplication.h - David Whittle (iamgnat@gmail.com)
 * Copyright (C) 2008  Alexander Bock (myself@alexander-bock.eu)
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

#import "shade.h"

static Shade *sharedSP = nil;

@implementation Shade

- (id) init {
    return([self initWithPluginManager:nil]);
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
    return(@"Shade");
}

- (void) initalize {
    // No-op for this example.
    //  Should generate the button image here rather than on demand.
}

- (NSImage *) pluginButtonImage {
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    
    [attributes setObject:[NSFont fontWithName:@"Helvetica" size:26]
                   forKey:NSFontAttributeName];
        [attributes setObject:[NSColor whiteColor]
                   forKey:NSForegroundColorAttributeName];
    
    NSSize          size = [[self name] sizeWithAttributes:attributes];
    NSImage         *image = [[[NSImage alloc] initWithSize:size] autorelease];
    
    [image lockFocus];
    [[self name] drawAtPoint:NSZeroPoint withAttributes:attributes];
    [image unlockFocus];
    
    return(image);
}

- (NSView *) contentViewForSize: (NSSize) size {
    // We are ignoring the size value, but it is there incase you have differnt
    //  views based on the size that CarFrontEnd sends you.
    if (shadeView == nil) {
        [NSBundle loadNibNamed:@"shade" owner:self];
    }
	
	NSArray *windows = [[NSApplication sharedApplication] windows];
	NSWindow *window;
	if ([windows count] != 1) {
		//NSLog(@"Too many windows!!!\n%@", windows);
		//return(ShrinkView);
		int i;
		for (i = 0 ; i < [windows count] ; i++) {
			window = [windows objectAtIndex:i];
			if ([[window title] isEqualToString:@"CarFrontEnd"]) 
				break;
		}
	} else {
		window = [windows objectAtIndex:0];
	}
	#ifndef CFE_DEBUG
	if (CGDisplayRelease(kCGDirectMainDisplay) != kCGErrorSuccess) {
		NSLog(@"Couldn't release the display(s)!");
		[[NSApplication sharedApplication] terminate:nil];
	}
	#endif
	NSRect  rect = [window frame];
    NSString    *side = [owner currentDriverSide];
	originalRect = rect;
	rect.size.width = 170;
	//rect.origin.x = 0;
	if ([side isEqualToString:@"right"]) {
		NSRect      frame;
		NSView *mainView = [window contentView];

		rect.origin.x = originalRect.origin.x + (originalRect.size.width - 170);        
		// Move the elements
        NSArray *els = [mainView subviews];
        int     i = 0;
        for (i = 0 ; i < [els count] ; i++) {
            NSView  *el = [els objectAtIndex:i];
            frame = [el frame];
            frame.origin.x = frame.origin.x - (originalRect.size.width - 170);
            //[[el animator] setFrame:frame];
			[el setFrame:frame];
        }
        [mainView setNeedsDisplay:YES];
    }
	[window setFrame:rect display:YES]; //display:YES animate:YES];

    return(shadeView);
}

- (BOOL) viewWillBeRemovedFromView {
    // No-op
    //  If you need to do something when your view is no longer displayed,
    //  add the code here.
	NSArray *windows = [[NSApplication sharedApplication] windows];
	NSWindow *window;
	if ([windows count] != 1) {
		//NSLog(@"Too many windows!!!\n%@", windows);
		//return(ShrinkView);
		int i;
		for (i = 0 ; i < [windows count] ; i++) {
			window = [windows objectAtIndex:i];
			if ([[window title] isEqualToString:@"CarFrontEnd"]) 
				break;
		}
	} else {
		window = [windows objectAtIndex:0];
	}
	#ifndef CFE_DEBUG
	if (CGDisplayRelease(kCGDirectMainDisplay) != kCGErrorSuccess) {
		NSLog(@"Couldn't release the display(s)!");
		[[NSApplication sharedApplication] terminate:nil];
	}
	#endif
	/*NSRect  rect = [window frame];
	rect.size.width = 1440;*/
    NSString    *side = [owner currentDriverSide];
	if ([side isEqualToString:@"right"]) {
		NSRect      frame;
		NSView *mainView = [window contentView];       
		// Move the elements
        NSArray *els = [mainView subviews];
        int     i = 0;
        for (i = 0 ; i < [els count] ; i++) {
            NSView  *el = [els objectAtIndex:i];
            frame = [el frame];
            frame.origin.x = frame.origin.x + (originalRect.size.width - 170);
            [el setFrame:frame];
        }
        [mainView setNeedsDisplay:YES];
    }

	[window setFrame:originalRect display:YES];// display:YES animate:YES];
	[window setViewsNeedDisplay:YES];
	[window update];
	return YES;
}

- (void) removePluginFromView {
}

@end
