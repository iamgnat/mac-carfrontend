/*
 * CarFrontEndAPI - CarFrontEndButton.m - David Whittle (iamgnat@gmail.com)
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

#import "CarFrontEndButton.h"
#import "NSImageUtils.h"

#pragma mark private declarations
@interface CarFrontEndButton (private)

- (void) observeValueForKeyPath: (NSString *) keyPath ofObject: (id) object
                         change: (NSDictionary *) change context: (void *) context;
- (void) updateImages;

@end

@implementation CarFrontEndButton

#pragma mark NSCoding methods
- (id) initWithCoder: (NSCoder *) coder {
    if (self = [super initWithCoder:coder]) {
        // Setting manually rather than the setters to skip contant image
        //  updates.
        string = [[coder decodeObjectForKey:@"CFEButtonString"] retain];
        stringColor = [[coder decodeObjectForKey:@"CFEButtonStringColor"]
                       retain];
        image = [[coder decodeObjectForKey:@"CFEButtonImage"] retain];
        altImage = [[coder decodeObjectForKey:@"CFEButtonAltImage"] retain];
        userImage = [[coder decodeObjectForKey:@"CFEButtonUserImage"] retain];
        userAltImage = [[coder decodeObjectForKey:@"CFEButtonUserAltImage"] retain];
        
        // Update the images.
        if (string == nil) {
            string = [[super title] retain];
            [super setTitle:@""];
        }
        if (stringColor == nil) {stringColor = [[NSColor whiteColor] retain];}
        if (userImage == nil) {userImage = [[self image] retain];}
        if (userAltImage == nil) {userAltImage = [[self alternateImage] retain];}
        
        // Load the background images
        NSString    *resourcePath = [[NSBundle bundleForClass:[CarFrontEndButton
                                                               class]] resourcePath];
        leftUpImage = [[NSImage alloc] initWithContentsOfFile:[resourcePath
                            stringByAppendingPathComponent:@"ButtonLeftUp.tif"]];
        middleUpImage = [[NSImage alloc] initWithContentsOfFile:[resourcePath
                            stringByAppendingPathComponent:@"ButtonMiddleUp.tif"]];
        rightUpImage = [[NSImage alloc] initWithContentsOfFile:[resourcePath
                            stringByAppendingPathComponent:@"ButtonRightUp.tif"]];
        leftDownImage = [[NSImage alloc] initWithContentsOfFile:[resourcePath
                            stringByAppendingPathComponent:@"ButtonLeftDown.tif"]];
        middleDownImage = [[NSImage alloc] initWithContentsOfFile:[resourcePath
                            stringByAppendingPathComponent:@"ButtonMiddleDown.tif"]];
        rightDownImage = [[NSImage alloc] initWithContentsOfFile:[resourcePath
                            stringByAppendingPathComponent:@"ButtonRightDown.tif"]];
        
        // Monitor future changes to the frame.
        [self setFrame:[self frame]];
        [self addObserver:self forKeyPath:@"frame"
                  options:NSKeyValueObservingOptionNew context:NULL];
        
        [super setBordered:NO];
        [self updateImages];
    }
    
    return(self);
}

- (void) encodeWithCoder: (NSCoder *) coder {
    [super encodeWithCoder:coder];
    
    [coder encodeObject:string forKey:@"CFEButtonString"];
    [coder encodeObject:stringColor forKey:@"CFEButtonStringColor"];
    [coder encodeObject:image forKey:@"CFEButtonImage"];
    [coder encodeObject:altImage forKey:@"CFEButtonAltImage"];
    [coder encodeObject:userImage forKey:@"CFEButtonUserImage"];
    [coder encodeObject:userAltImage forKey:@"CFEButtonUserAltImage"];
}

#pragma mark NSButton override methods
- (id) initWithFrame: (NSRect) frameRect {
	if ((self = [super initWithFrame:frameRect]) != nil) {
        // Setting manually rather than the setters to skip contant image
        //  updates.
        string = [[NSString alloc] initWithString:@""];
        stringColor = [[NSColor whiteColor] retain];
        image = nil;
        altImage = nil;
        userImage = nil;
        userAltImage = nil;
        
        // Load the background images
        NSString    *resourcePath = [[NSBundle bundleForClass:[CarFrontEndButton
                                                               class]] resourcePath];
        leftUpImage = [[NSImage alloc] initWithContentsOfFile:[resourcePath
                        stringByAppendingPathComponent:@"ButtonLeftUp.tif"]];
        middleUpImage = [[NSImage alloc] initWithContentsOfFile:[resourcePath
                        stringByAppendingPathComponent:@"ButtonMiddleUp.tif"]];
        rightUpImage = [[NSImage alloc] initWithContentsOfFile:[resourcePath
                        stringByAppendingPathComponent:@"ButtonRightUp.tif"]];
        leftDownImage = [[NSImage alloc] initWithContentsOfFile:[resourcePath
                        stringByAppendingPathComponent:@"ButtonLeftDown.tif"]];
        middleDownImage = [[NSImage alloc] initWithContentsOfFile:[resourcePath
                        stringByAppendingPathComponent:@"ButtonMiddleDown.tif"]];
        rightDownImage = [[NSImage alloc] initWithContentsOfFile:[resourcePath
                        stringByAppendingPathComponent:@"ButtonRightDown.tif"]];
        
        // Monitor future changes to the frame.
        [self setFrame:frameRect];
        [self addObserver:self forKeyPath:@"frame"
                  options:NSKeyValueObservingOptionNew context:NULL];
        
        [super setBordered:NO];
    }
	return(self);
}

- (void) dealloc {
    [string release];
    [stringColor release];
    [image release];
    [altImage release];
    [leftUpImage release];
    [middleUpImage release];
    [rightUpImage release];
    [leftDownImage release];
    [middleDownImage release];
    [rightDownImage release];
                                                              
    [super dealloc];
}

- (void) setTitle: (NSString *) value {
    [self setStringValue:value];
}

- (void) setStringValue: (NSString *) value {
    [string release];
    string = [[NSString alloc] initWithString:value];
    
    [self updateImages];
}

- (NSString *) stringValue {return(string);}

- (void) setImage: (NSImage *) value {
    [userImage release];
    userImage = [value copyWithZone:NULL];
    
    [self updateImages];
}

- (void) setAlternateImage: (NSImage *) value {
    [userAltImage release];
    userAltImage = [value copyWithZone:NULL];
    
    [self updateImages];
}

// Stub out these methods as they could have adverse effects.
- (void) setButtonType: (NSButtonType) type {}          // Noop
- (void) setImagePosition: (NSCellImagePosition) pos {} // Noop
- (void) setBordered: (BOOL) flag {}                    // Noop
- (void) setTransparent: (BOOL) flag {}                 // Noop

- (void) setFrame: (NSRect) frame {
    if (frame.size.height > [leftUpImage size].height) {
        frame.size.height = [leftUpImage size].height;
    }
    
    NSSize  size;
    size.width = [middleUpImage size].width + [leftUpImage size].width +
                    [rightUpImage size].width;
    size.height = [leftUpImage size].height;
    size = [NSImage scaleSize:size forHeight:frame.size.height];
    if (frame.size.width < size.width) {
        frame.size.width = size.width;
    }
    
    [super setFrame:frame];
}

- (void) observeValueForKeyPath: (NSString *) keyPath ofObject: (id) object
                         change: (NSDictionary *) change context: (void *) context {
    if ([keyPath isEqualToString:@"frame"]) {
        // Clear the images so that they can be rebuilt.
        [image release];
        image = nil;
        [altImage release];
        altImage = nil;
        
        [self updateImages];
    }
}

#pragma mark CFEButton methods
- (NSColor *) stringColor {return(stringColor);}

- (void) setStringColor: (NSColor *) color {
    [color retain];
    [stringColor release];
    stringColor = color;
    
    [self updateImages];
}

- (void) updateImages {
    NSImage             *normal;
    NSImage             *alternate;
    NSRect              bounds = [self bounds];
    NSRect              imageSize;
	NSPoint             stringOrigin;
	NSSize              stringSize;
	NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    
    // The background for the default (unclicked) image
    if (!image) {
        NSSize  size = bounds.size;
        
        size = [NSImage scaleSize:size forHeight:[leftUpImage size].height];
        image = [[NSImage alloc] initWithSize:size];
        [image lockFocus];
        
        // The left side
        imageSize.size = [leftUpImage size];
        imageSize.origin = NSZeroPoint;
        [leftUpImage drawInRect:imageSize fromRect:NSZeroRect
                      operation:NSCompositeSourceOver fraction:1.0];
        
        // The middle of the button (resize as needed)
        NSImage     *middle = [middleUpImage copyWithZone:NULL];
        imageSize.size.width = size.width - [leftUpImage size].width -
                                [rightUpImage size].width;
        imageSize.origin = NSZeroPoint;
        imageSize.origin.x = [leftUpImage size].width;
        [middle setScalesWhenResized:YES];
        [middle setSize:imageSize.size];
        [middle drawInRect:imageSize fromRect:NSZeroRect
                        operation:NSCompositeSourceOver fraction:1.0];
        [middle release];
        
        // The right side
        imageSize.size = [rightUpImage size];
        imageSize.origin = NSZeroPoint;
        imageSize.origin.x = size.width - [rightUpImage size].width;
        [rightUpImage drawInRect:imageSize fromRect:NSZeroRect
                operation:NSCompositeSourceOver fraction:1.0];
        
        [image unlockFocus];
    }
    
    // The background for the alternate (clicked) image
    if (!altImage) {
        NSSize  size = bounds.size;
        
        size = [NSImage scaleSize:size forHeight:[leftDownImage size].height];
        altImage = [[NSImage alloc] initWithSize:size];
        [altImage lockFocus];
        
        // The left side
        imageSize.size = [leftDownImage size];
        imageSize.origin = NSZeroPoint;
        [leftDownImage drawInRect:imageSize fromRect:NSZeroRect
                      operation:NSCompositeSourceOver fraction:1.0];
        
        // The middle of the button (resize as needed)
        NSImage     *middle = [middleDownImage copyWithZone:NULL];
        imageSize.size.width = size.width - [leftDownImage size].width -
        [rightDownImage size].width;
        imageSize.origin = NSZeroPoint;
        imageSize.origin.x = [leftDownImage size].width;
        [middle setScalesWhenResized:YES];
        [middle setSize:imageSize.size];
        [middle drawInRect:imageSize fromRect:NSZeroRect
                        operation:NSCompositeSourceOver fraction:1.0];
        [middle release];
        
        // The right side
        imageSize.size = [rightDownImage size];
        imageSize.origin = NSZeroPoint;
        imageSize.origin.x = size.width - [rightDownImage size].width;
        [rightDownImage drawInRect:imageSize fromRect:NSZeroRect
                       operation:NSCompositeSourceOver fraction:1.0];
        
        [altImage unlockFocus];
    }
    
    // Setup the string info.
	[attributes setObject:[NSFont fontWithName:@"Helvetica" size:30]
                               forKey:NSFontAttributeName];
	[attributes setObject:stringColor forKey:NSForegroundColorAttributeName];
	stringSize = [string sizeWithAttributes:attributes];
	stringOrigin.x = bounds.origin.x +
    (bounds.size.width - stringSize.width) / 2;
    // The +2 is needed to get it visually centered vertically
	stringOrigin.y = bounds.origin.y +
    (bounds.size.height - stringSize.height) / 2 + 2;
	
    // Composite the background and string value for the default image
    normal = [[NSImage alloc] initWithSize:bounds.size];
    [normal lockFocus];
    imageSize.origin = NSZeroPoint;
    imageSize.size = [self bounds].size;
    [image setScalesWhenResized:YES];
    [image drawInRect:imageSize fromRect:NSZeroRect
            operation:NSCompositeSourceOver fraction:1.0];
    if (!userImage) {
        [string drawAtPoint:stringOrigin withAttributes:attributes];
    } else {
        NSSize  size;
        double  leftPad = 0.0;
        double  leftWidth = 0.0;
        double  rightPad = 0.0;
        double  rightWidth = 0.0;
        
        // Determine the left padding
        size = [leftUpImage size];
        size = [NSImage scaleSize:size forHeight:[self bounds].size.height];
        leftPad = size.width * 0.65;
        leftWidth = size.width;
        
        // Determine the right padding
        size = [rightUpImage size];
        size = [NSImage scaleSize:size forHeight:[self bounds].size.height];
        rightPad = size.width * 0.65;
        rightWidth = size.width;
        
        // Scale the image
        imageSize.size = [self bounds].size;
        imageSize.size.width = imageSize.size.width - (leftWidth + rightWidth) +
                                    (leftPad + rightPad);
        size = [userImage size];
        if (size.height > imageSize.size.height) {
            size = [NSImage scaleSize:size forHeight:imageSize.size.height];
        }
        if (size.width > imageSize.size.width) {
            size = [NSImage scaleSize:size forWidth:imageSize.size.width];
        }
        imageSize.size = size;
        
        // Find the place to put it
        imageSize.origin = NSZeroPoint;
        imageSize.origin.y = [self bounds].size.height - size.height;
        if (imageSize.origin.y <= 0) {
            imageSize.origin.y = 0;
        } else {
            imageSize.origin.y = (imageSize.origin.y / 2);
        }
        imageSize.origin.x = leftWidth - leftPad;
        [userImage setScalesWhenResized:YES];
        [userImage setSize:size];
        [userImage drawInRect:imageSize fromRect:NSZeroRect
                    operation:NSCompositeSourceOver fraction:1.0];
    }
    [normal unlockFocus];
    
    // Composite the background and string value for the alternate image
    alternate = [[NSImage alloc] initWithSize:bounds.size];
    [alternate lockFocus];
    imageSize.origin = NSZeroPoint;
    imageSize.size = [self bounds].size;
    [altImage setScalesWhenResized:YES];
    [altImage drawInRect:imageSize fromRect:NSZeroRect
               operation:NSCompositeSourceOver fraction:1.0];
    if (!userAltImage) {
        [string drawAtPoint:stringOrigin withAttributes:attributes];
    } else {
        NSSize  size;
        double  leftPad = 0.0;
        double  leftWidth = 0.0;
        double  rightPad = 0.0;
        double  rightWidth = 0.0;
        
        // Determine the left padding
        size = [leftDownImage size];
        size = [NSImage scaleSize:size forHeight:[self bounds].size.height];
        leftPad = size.width * 0.65;
        leftWidth = size.width;
        
        // Determine the right padding
        size = [rightDownImage size];
        size = [NSImage scaleSize:size forHeight:[self bounds].size.height];
        rightPad = size.width * 0.65;
        rightWidth = size.width;
        
        // Scale the image
        imageSize.size = [self bounds].size;
        imageSize.size.width = imageSize.size.width - (leftWidth + rightWidth) +
        (leftPad + rightPad);
        size = [userAltImage size];
        if (size.height > imageSize.size.height) {
            size = [NSImage scaleSize:size forHeight:imageSize.size.height];
        }
        if (size.width > imageSize.size.width) {
            size = [NSImage scaleSize:size forWidth:imageSize.size.width];
        }
        imageSize.size = size;
        
        // Find the place to put it
        imageSize.origin = NSZeroPoint;
        imageSize.origin.y = [self bounds].size.height - size.height;
        if (imageSize.origin.y <= 0) {
            imageSize.origin.y = 0;
        } else {
            imageSize.origin.y = (imageSize.origin.y / 2);
        }
        imageSize.origin.x = leftWidth - leftPad;
        [userAltImage setScalesWhenResized:YES];
        [userAltImage setSize:size];
        [userAltImage drawInRect:imageSize fromRect:NSZeroRect
                    operation:NSCompositeSourceOver fraction:1.0];
    }
    [alternate unlockFocus];
    
    // Let's update the display.
    [super setImage:normal];
    [normal release];
    [super setAlternateImage:alternate];
    [alternate release];
    [self setNeedsDisplay:YES];
}

@end