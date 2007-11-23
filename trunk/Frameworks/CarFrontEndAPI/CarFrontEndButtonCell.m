/*
 * CarFrontEndAPI - CarFrontEndButtonCell.m - David Whittle (iamgnat@gmail.com)
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

/*
 * The inspiration and general outline was provided by Sean Patrick O'Brien's
 * iLife Controls Framework which could be found at
 * http://www.seanpatrickobrien.com/2006/09/28/ilifecontrols-10/ at the time
 * of inclusion.
 *
 * Thank you Sean, your guidance greatly simplified my life.
 */

#import "CarFrontEndButtonCell.h"
#import "CTGradient.h"
#import "NSBezierPath-RoundedRect.h"
#import "NSImageUtils.h"

@implementation CarFrontEndButtonCell

#pragma mark NSCoding methods
- (id) initWithCoder: (NSCoder *) coder {
    self = [super initWithCoder:coder];
    
    NSNumber    *texture = [coder decodeObjectForKey:@"CFEButtonCellTexture"];
    NSArray     *colors = [coder decodeObjectForKey:@"CFEButtonCellGradientColors"];
    NSColor     *border = [coder decodeObjectForKey:@"CFEButtonCellBorderColor"];
    NSColor     *text = [coder decodeObjectForKey:@"CFEButtonCellTextColor"];
    
    _buttonTexture = CFEGradientButtonTexture;
    
    if (texture != nil) [self setButtonTexture:[texture intValue]];
    if (colors != nil && [colors count] > 0) {
        [self setGradientTextureColors:colors];
    }
    if (border != nil) [self setBorderColor:border];
    if (text != nil) [self setTextColor:text];
    
    return(self);
}

- (void) encodeWithCoder: (NSCoder *) coder {
    [super encodeWithCoder:coder];
    
    [coder encodeObject:[NSNumber numberWithInt:_buttonTexture]
                 forKey:@"CFEButtonCellTexture"];
    [coder encodeObject:_gradientColors forKey:@"CFEButtonCellGradientColors"];
    [coder encodeObject:_borderColor forKey:@"CFEButtonCellBorderColor"];
    [coder encodeObject:_textColor forKey:@"CFEButtonCellGradientColors"];
}

#pragma mark Override methods
- (id) _init {
    _buttonTexture = CFEGradientButtonTexture;
    [super setBordered:YES];
    [super setButtonType:NSMomentaryChangeButton];
    [super setBezelStyle:NSRegularSquareBezelStyle];
    
    return(self);
}

- (id) init {
    return([self initTextCell:@""]);
}

- (id) initImageCell: (NSImage *) image {
    [super initImageCell:image];
    
    return([self _init]);
}

- (id) initTextCell: (NSString *) string {
    [super initTextCell:string];
    
    return([self _init]);
}

- (void) dealloc {
    [_gradientColors release];
    [_borderColor release];
    [_textColor release];
    
    [super dealloc];
}

#pragma mark Button texture
- (void) setButtonTexture: (CFEButtonTexture) texture {
    // Make sure it is a valid texture.
    if (texture < CFEFirstButtonTexture || texture > CFELastButtonTexture) {
        [NSException raise:@"CFEException"
                    format:@"CarFrontEndButtonCell: The supplied texture value is invalid."];
    }
    _buttonTexture = texture;
    
    // Force the display to update.
    [[self controlView] setNeedsDisplay:YES];
}

- (CFEButtonTexture) buttonTexture {
    if (_buttonTexture < CFEFirstButtonTexture || _buttonTexture > CFELastButtonTexture) {
        _buttonTexture = CFEGradientButtonTexture;
    }
    return(_buttonTexture);
}

#pragma mark Button coloring
- (void) setFlatTextureColor: (NSColor *) color {
    if (color == nil) {
        color = [NSColor blackColor];
    }
    [self setGradientTextureColors:[NSArray arrayWithObject:color]];
}

- (NSColor *) flatTextureColor {
    return([[self gradientTextureColors] objectAtIndex:0]);
}

- (void) setFlatHighlightTextureColor: (NSColor *) color {
    if (color == nil) {
        color = [NSColor colorWithDeviceRed:0.3 green:0.3 blue:0.3 alpha:1.0];
    }
    [self setGradientHighlightTextureColors:[NSArray arrayWithObject:color]];
}

- (NSColor *) flatHighlightTextureColor {
    return([[self gradientHighlightTextureColors] objectAtIndex:0]);
}

- (void) setGradientTextureColors: (NSArray *) colors {
    if (colors == nil) {
        switch ([self buttonTexture]) {
            case CFEFlatButtonTexture:
                [self setFlatTextureColor:nil];
                return;
            default:
                // Gradient and textures that ignore the color array.
                colors = [NSArray arrayWithObjects:
                            [NSColor colorWithDeviceRed:0.2 green:0.2 blue:0.2
                                                  alpha:1.0],
                            [NSColor blackColor], nil];
                break;
        }
    }
    
    [_gradientColors release];
    _gradientColors = [colors copyWithZone:NULL];

    // Force the display to update.
    [[self controlView] setNeedsDisplay:YES];
}

- (NSArray *) gradientTextureColors {
    if (_gradientColors == nil) [self setGradientTextureColors:nil];
    return(_gradientColors);
}

- (void) setGradientHighlightTextureColors: (NSArray *) colors {
    if (colors == nil) {
        switch ([self buttonTexture]) {
            case CFEFlatButtonTexture:
                [self setFlatHighlightTextureColor:nil];
                return;
            default:
                // Gradient and textures that ignore the color array.
                colors = [NSArray arrayWithObjects:
                    [NSColor colorWithDeviceRed:0.6 green:0.6 blue:0.6
                                          alpha:1.0],
                    [NSColor blackColor], nil];
                break;
        }
    }
    
    [_gradientHighlightColors release];
    _gradientHighlightColors = [colors copyWithZone:NULL];
    
    // Force the display to update.
    [[self controlView] setNeedsDisplay:YES];
}

- (NSArray *) gradientHighlightTextureColors {
    if (_gradientHighlightColors == nil) {
        [self setGradientHighlightTextureColors:nil];
    }
    return(_gradientHighlightColors);
}

- (void) setBorderColor: (NSColor *) color {
    if (color == nil) {
        switch ([self buttonTexture]) {
            case CFEFlatButtonTexture:
                color = [NSColor whiteColor];
                break;
            case CFEGradientButtonTexture:
                color = [NSColor colorWithDeviceRed:0.8 green:0.8 blue:0.8
                                              alpha:1.0];
                break;
            case CFEUnifiedButtonTexture:
                color = [NSColor blackColor];
                break;
            default:
                [NSException raise:@"CFEException"
                            format:@"CarFrontEndButtonCell: Unknown default text color!"];
        }
    }
    [_borderColor release];
    _borderColor = [color retain];
}

- (NSColor *) borderColor {
    if (_borderColor == nil) [self setBorderColor:nil];
    return(_borderColor);
}

- (void) setTextColor: (NSColor *) color {
    if (color == nil) {
        // By default, the border and text color should be the same.
        color = [self borderColor];
    }
    [_textColor release];
    _textColor = [color retain];
}

- (NSColor *) textColor {
    if (_textColor == nil) [self setTextColor:nil];
    return(_textColor);
}

#pragma mark Button drawing
- (void) drawImage: (NSImage*) image withFrame: (NSRect) frame
            inView: (NSView*) view {
	if([self showsStateBy] == NSNoCellMask) {
		[super drawImage:image withFrame:frame inView:view];
		return;
	}
	
    [NSException raise:@"CFEException"
                format:@"CarFrontEndButtonCell: Really should do something here sometime..."];
    /*	NSString *state = [self isHighlighted] ? @"P" : @"N";
	NSString *position = [self intValue] ? @"On" : @"Off";
	NSImage *checkImage = [NSImage frameworkImageNamed:[NSString stringWithFormat:@"HUDCheckbox%@%@.tiff", position, state]];
	
	NSSize size = [checkImage size];
	float addX = 2;
	float y = NSMaxY(frame) - (frame.size.height-size.height)/2.0;
	float x = frame.origin.x+addX;
	
	[checkImage compositeToPoint:NSMakePoint(x, y) operation:NSCompositeSourceOver]; */
    [super drawImage:image withFrame:frame inView:view];
}

- (void) drawWithFrame: (NSRect) frame inView: (NSView *) view {
	if([self showsStateBy] != NSNoCellMask){
		[super drawWithFrame:frame inView:view];
		return;
	}
    
    NSRect  bounds = NSZeroRect;
    bounds.size = frame.size;
    
    float   radius = (MIN(bounds.size.width, bounds.size.height) / 2) * 1.0;
    float   lineWidth = (MIN(bounds.size.width, bounds.size.height) * 0.10) * 0.25;
    
    // Setup the bounding box to accomidate the outline.
    bounds.size.width -= lineWidth;
    bounds.size.height -= lineWidth;
    bounds.origin.x += lineWidth / 2;
    bounds.origin.y += lineWidth / 2;
    
    NSBezierPath    *buttonShape = [NSBezierPath bezierPathWithRoundRectInRect:bounds
                                                                        radius:radius];
    CTGradient      *bgGradient = nil;
    
    switch ([self buttonTexture]) {
        case CFEUnifiedButtonTexture:
            if ([self isHighlighted]) {
                bgGradient = [CTGradient unifiedPressedGradient];
            } else {
                bgGradient = [CTGradient unifiedNormalGradient];
            }
            break;
        default:
            bgGradient = [[[CTGradient alloc] init] autorelease];
            NSArray         *colors = nil;
            int             i = 0;
            
            if ([self isHighlighted]) {
                colors = [self gradientHighlightTextureColors];
            } else {
                colors = [self gradientTextureColors];
            }
                
            for (i = 0 ; i < [colors count] ; i++) {
                bgGradient = [bgGradient addColorStop:[colors objectAtIndex:i]
                                                                 atPosition:i * 1.0];
            }
            break;
    }
    
    // Draw the background texture
    [bgGradient fillBezierPath:buttonShape angle:85.0];
    
    if ([self isBordered]) {
        // Add the border
        [[self borderColor] set];
        [buttonShape setLineWidth:lineWidth];
        [buttonShape stroke];
    }
    
    // Determine writable area.
    bounds.origin.x = radius * 0.4 + lineWidth;
    bounds.origin.y = radius * 0.4 + lineWidth;
    bounds.size.width = frame.size.width - (bounds.origin.x * 2);
    bounds.size.height = frame.size.height - (bounds.origin.x * 2);
    
    // Handle the image
    BOOL    hasImage = NO;
    if ([self imagePosition] != NSNoImage) {
        NSImage *image = nil;
        NSRect  imageRect = bounds;
        NSSize  imageSize = NSZeroSize;
        
        // Clicked state?
        if ([self isHighlighted] && [self alternateImage] != nil) {
            image = [self alternateImage];
        } else {
            image = [self image];
        }
        
        if (image != nil) {
            hasImage = YES;
            
            // Determine where to draw the image.
            switch ([self imagePosition]) {
                case NSImageLeft:
                case NSImageRight:
                    if (imageRect.size.width < imageRect.size.height) {
                        [image scaleForWidth:imageRect.size.width];
                    } else {
                        [image scaleForHeight:imageRect.size.height];
                    }
                    imageSize = [image size];
                    
                    imageRect.origin.y += (imageRect.size.height / 2) - (imageSize.height / 2);
                    if ([self imagePosition] == NSImageRight) {
                        imageRect.origin.x += imageRect.size.width - imageSize.width;
                    }
                    break;
                case NSImageAbove:
                case NSImageBelow:
                    imageRect.size.height /= 2.0;
                    
                    if (imageRect.size.width < imageRect.size.height) {
                        [image scaleForWidth:imageRect.size.width];
                    } else {
                        [image scaleForHeight:imageRect.size.height];
                    }
                    imageSize = [image size];
                    
                    imageRect.origin.x += (imageRect.size.width / 2) - (imageSize.width / 2);
                    imageRect.origin.y += (imageRect.size.height / 2) - (imageSize.height / 2);
                    if ([self imagePosition] == NSImageAbove) {
                        imageRect.origin.y += imageRect.size.height;
                    }
                    break;
                case NSImageOverlaps:
                case NSImageOnly:
                default:
                    if (imageRect.size.width < imageRect.size.height) {
                        [image scaleForWidth:imageRect.size.width];
                    } else {
                        [image scaleForHeight:imageRect.size.height];
                    }
                    imageSize = [image size];
                    
                    imageRect.origin.y += (imageRect.size.height / 2) - (imageSize.height / 2);
                    imageRect.origin.x += (imageRect.size.width / 2) - (imageSize.width / 2);
                    break;
            }
            
            // Draw the image while dealing with a flipped view.
            NSPoint point = imageRect.origin;
            imageRect.origin = NSZeroPoint;
            if ([[self controlView] isFlipped]) {
                point.y += imageSize.height;
            }
            [image compositeToPoint:point fromRect:imageRect
                    operation:NSCompositeSourceOver fraction:1.0];
            
            // Update the bounds rect info for the text (if applicable)
            switch ([self imagePosition]) {
                case NSImageLeft:
                    bounds.origin.x += imageSize.width;
                case NSImageRight:
                    bounds.size.width -= imageSize.width;
                    break;
                case NSImageAbove:
                    bounds.size.height -= imageSize.height;
                    break;
                case NSImageBelow:
                    bounds.size.height -= imageSize.height;
                    bounds.origin.y += imageSize.height;
                    break;
            }
        }
    }
    
    // Handle the text
    if (!hasImage || ([self imagePosition] != NSImageOnly &&
        [self imagePosition] != NSImageOverlaps)) {
        NSMutableDictionary *attrs = nil;
        NSString            *string = nil;
        NSRect              stringRect = bounds;
        NSSize              stringSize = NSZeroSize;
        
        // Clicked state?
        if ([self isHighlighted]) {
            string = [self alternateTitle];
        }
        if (string == nil || [string isEqualToString:@""]) {
            string = [self title];
        }
        
        if (string != nil && ![string isEqualToString:@""]) {
            // Setup the attributes.
            attrs = [NSMutableDictionary dictionary];
            [attrs setObject:[self font] forKey:NSFontAttributeName];
            [attrs setObject:[self textColor]
                      forKey:NSForegroundColorAttributeName];
            stringSize = [string sizeWithAttributes:attrs];
            
            // Adjust the alignment.
            stringRect.origin.y += (stringRect.size.height / 2) - (stringSize.height / 2);
            switch ([self alignment]) {
                case NSRightTextAlignment:
                    stringRect.origin.x += stringRect.size.width - stringSize.width;
                    break;
                case NSCenterTextAlignment:
                    stringRect.origin.x += (stringRect.size.width / 2) - (stringSize.width / 2);
                    break;
            }
            
            // Draw the string
            [string drawInRect:stringRect withAttributes:attrs];
        }
    }
}

@end
