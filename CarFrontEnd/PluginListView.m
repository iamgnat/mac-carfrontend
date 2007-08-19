/*
 * CarFrontEnd - PluginListView.m - gnat (iamgnat@gmail.com)
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

#import "PluginListView.h"

@implementation PluginListView

- (id) initWithFrame: (NSRect) frame {
    self = [super initWithFrame:frame];
    if (self) {
        items = [[NSMutableArray alloc] init];
        buttonWidth = 100.0;
        buttonHeight = 60.0;
        buttonPad = 20.0;
        
        [self addObserver:self forKeyPath:@"frame"
                  options:NSKeyValueObservingOptionNew context:NULL];
    }
    return self;
}

- (void) drawRect: (NSRect) rect {
    [super drawRect:rect];
}

#pragma mark Grouping size information

- (void) setWidth: (float) width {
    buttonWidth = width;
}

- (float) width {
    return(buttonWidth);
}

- (void) setHeight: (float) height {
    buttonHeight = height;
}

- (float) height {
    return(buttonHeight);
}

- (void) setPad: (float) pad {
    buttonPad = pad;
}

- (float) pad {
    return(buttonPad);
}

#pragma mark Button management

- (CarFrontEndButton *) addButtonWithImage: (NSImage *) image
                                    target: (id) target
                               andSelector: (SEL) selector {
    NSRect      bounds;
    
    // Determine the grouping view location.
    if ([items count] == 0) {
        bounds = [self frameRelativeTo:nil andContainedBy:[self bounds]];
    } else {
        bounds = [self frameRelativeTo:[items lastObject]
                        andContainedBy:[self bounds]];
    }
    
    CarFrontEndButton   *button = [[[CarFrontEndButton alloc]
                                    initWithFrame:bounds] autorelease];
    [button setImage:image];
    [button setAlternateImage:image];
    [button setTarget:target];
    [button setAction:selector];
    [items addObject:button];
    
    // Make it visible
    [self addSubview:button];
    return(button);
}

- (void) removeButton: (CarFrontEndButton *) uButton {
    int     i = 0;
    
    for (i = 0 ; i < [items count] ; i++) {
        CarFrontEndButton   *button = [items objectAtIndex:i];
        if ([button isEqualTo:uButton]) {
            [button removeFromSuperview];
            [items removeObjectAtIndex:i];
            
            // Recalculate the remaining grouping frames.
            for (i = i ; i < [items count] ; i++) {
                CarFrontEndButton   *button = [items objectAtIndex:i];
                if (i == 0) {
                    [button setFrame:[self frameRelativeTo:nil
                                            andContainedBy:[self bounds]]];
                } else {
                    CarFrontEndButton   *prev = [items objectAtIndex:i - 1];
                    [button setFrame:[self frameRelativeTo:prev
                                            andContainedBy:[self bounds]]];
                }
            }
            break;
        }
    }
}

- (NSRect) frameRelativeTo: (CarFrontEndButton *) prev
            andContainedBy: (NSRect) frame {
    NSRect  bounds = NSZeroRect;
    
    if (prev == nil) {
        bounds.origin = NSMakePoint(buttonPad,
                                    frame.size.height - (buttonPad + buttonHeight));
    } else {
        bounds = [prev frame];
        bounds.origin.x += buttonPad + buttonWidth;
        
        // make sure it won't hang off the right edge.
        // Should add a scroller if we hang off the bottom...
        if (bounds.origin.x + buttonWidth + buttonPad > frame.size.width) {
            bounds.origin = NSMakePoint(buttonPad,
                                        bounds.origin.y - (buttonPad + buttonHeight));
        }
    }
    bounds.size = NSMakeSize(buttonWidth, buttonHeight);
    
    return(bounds);
}

- (void) observeValueForKeyPath: (NSString *) keyPath ofObject: (id) object
                         change: (NSDictionary *) change
                        context: (void *) context {
    if ([keyPath isEqualToString:@"frame"]) {
        NSRect  frame;
        [[change objectForKey:NSKeyValueChangeNewKey] getValue:&frame];
        int     i = 0;
        
        // Recalculate the button layout
        for (i = 0 ; i < [items count] ; i++) {
            CarFrontEndButton   *button = [items objectAtIndex:i];
            if (i == 0) {
                [button setFrame:[self frameRelativeTo:nil andContainedBy:frame]];
            } else {
                CarFrontEndButton  *prev = [items objectAtIndex:i - 1];
                [button setFrame:[self frameRelativeTo:prev
                                        andContainedBy:frame]];
            }
        }
    }
}

@end
