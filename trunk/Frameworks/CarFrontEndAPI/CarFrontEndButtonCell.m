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
 * The inspiration was provided by Sean Patrick O'Brien's iLife Controls
 * Framework which could be found at
 * http://www.seanpatrickobrien.com/2006/09/28/ilifecontrols-10/ which gave me
 * a good start at understanding sub-classing a cell, but the real knowledge
 * came from pooring through the GNUStep code.
 */

#import "CarFrontEndButtonCell.h"
#import "CTGradient.h"
#import "NSBezierPath-RoundedRect.h"
#import "NSImageUtils.h"
#import "NSString.h"

@implementation CarFrontEndButtonCell

/*
 * NOTE: Until there is an IB Palette available, you will need to manually set
 *          set the font information in IB. For consistance, please use
 *          Helvetica as the face and 27 for the point size.
 */

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
    
    _buttonType = -1;
    [self buttonType];
    
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
    _buttonType = -1;
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

#pragma mark Button Type
// Because I find it damn annoying to not have a simple way to know what type
//  of button this is!!!
- (void) setButtonType: (NSButtonType) type {
    _buttonType = type;
    [super setButtonType:type];
}

// Information "borrowed" from NSButtonCell.m in GNUStep.
- (NSButtonType) buttonType {
    if (_buttonType < 0 || _buttonType > 7) {
        if ([self highlightsBy] == NSChangeBackgroundCellMask &&
            [self showsStateBy] == NSNoCellMask &&
            [self imageDimsWhenDisabled]) {
            _buttonType = NSMomentaryLightButton;
        } else if ([self highlightsBy] == NSPushInCellMask | NSChangeGrayCellMask &&
                   [self showsStateBy] == NSNoCellMask &&
                   [self imageDimsWhenDisabled]) {
            _buttonType = NSMomentaryPushInButton;
        } else if ([self highlightsBy] == NSContentsCellMask &&
                   [self showsStateBy] == NSNoCellMask &&
                   [self imageDimsWhenDisabled]) {
            _buttonType = NSMomentaryChangeButton;
        } else if ([self highlightsBy] == NSPushInCellMask | NSChangeGrayCellMask &&
                   [self showsStateBy] == NSChangeBackgroundCellMask &&
                   [self imageDimsWhenDisabled]) {
            _buttonType = NSPushOnPushOffButton;
        } else if ([self highlightsBy] == NSChangeBackgroundCellMask &&
                   [self showsStateBy] == NSChangeBackgroundCellMask &&
                   [self imageDimsWhenDisabled]) {
            _buttonType = NSOnOffButton;
        } else if ([self highlightsBy] == NSPushInCellMask | NSContentsCellMask &&
                   [self showsStateBy] == NSContentsCellMask &&
                   [self imageDimsWhenDisabled]) {
            _buttonType = NSToggleButton;
        } else if ([self highlightsBy] == NSContentsCellMask &&
                   [self showsStateBy] == NSContentsCellMask &&
                   ![self imageDimsWhenDisabled]) {
            NSData      *imgData = [[self image] TIFFRepresentation];
            NSData      *swtData = nil;
            NSButton    *tmpButton = [NSButton new];
            
            // Using the NSSwitch image as the GNUStep version does not equate to
            //  the Cocoa image, it is a X11 style image.
            [tmpButton setButtonType:NSSwitchButton];
            swtData = [[tmpButton image] TIFFRepresentation];
            [tmpButton release];
            
            if ([imgData isEqualToData:swtData]) {
                _buttonType = NSSwitchButton;
            } else {
                _buttonType = NSRadioButton;
            }
        }
    }
    
    return(_buttonType);
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
- (void) getRadius: (float *) radius lineWidth: (float *) lineWidth
         andBounds: (NSRect *) bounds fromFrame: (NSRect) frame {
    NSBezelStyle    bezel = [self bezelStyle];
    NSButtonType    type = [self buttonType];
    
    *bounds = NSZeroRect;
    bounds->size = frame.size;
    
    *radius = 0.0;
    *lineWidth = (MIN(bounds->size.width, bounds->size.height) * 0.10) * 0.25;
    
    switch (bezel) {
        case NSRoundedBezelStyle:
        case NSRegularSquareBezelStyle:
            // Really belongs below, but until there is an IB palette for
            //  the buttons this is the only style that IB 2.x will let you
            //  change the height of :/
            if (type == NSSwitchButton || type == NSRadioButton) {
                *radius = 0.0;
                break;
            }
        case NSCircularBezelStyle:
        case NSHelpButtonBezelStyle:
        case NSRoundRectBezelStyle:
        case NSRecessedBezelStyle:
            // Round sides
            *radius = MIN(bounds->size.width, bounds->size.height) / 2.0;
            break;
        //case NSRegularSquareBezelStyle:
        case NSThickSquareBezelStyle:
        case NSThickerSquareBezelStyle:
        case NSTexturedSquareBezelStyle:
        case NSTexturedRoundedBezelStyle:
        case NSRoundedDisclosureBezelStyle:
            // Rounded corners
            *radius = MIN(bounds->size.width, bounds->size.height) / 4.0;
            break;
        case NSShadowlessSquareBezelStyle:
        case NSSmallSquareBezelStyle:
        case NSDisclosureBezelStyle:
        default:
            // Square corners
            *radius = 0.0;
            break;
    }
    // Setup the bounding box to accomidate the outline.
    bounds->size.width -= *lineWidth;
    bounds->size.height -= *lineWidth;
    bounds->origin.x += *lineWidth / 2.0;
    bounds->origin.y += *lineWidth / 2.0;
}

// Stolen from NSActionCell.m in GNUStep.
- (void) drawWithFrame: (NSRect) frame inView: (NSView *) control {
    if (NSIsEmptyRect(frame)) {
        return;
    }
    
    [self drawBorderAndBackgroundWithFrame:frame inView:control];
    [self drawInteriorWithFrame:frame inView:control];
    
    // Needed for larger NSSwitchButton to be redrawn, but "normal" size 
    //  updates the image fine...
    [[self controlView] setNeedsDisplay:YES];
}

- (void) drawBorderAndBackgroundWithFrame: (NSRect) frame
                                   inView: (NSView *) view {
    NSBezelStyle    bezel = [self bezelStyle];
    NSButtonType    type = [self buttonType];
    
    // No background for Disclosure, Switch, or Radio buttons
    if (bezel == NSDisclosureBezelStyle || type == NSSwitchButton ||
        type == NSRadioButton) {
        return;
    }
    
    NSRect  bounds = NSZeroRect;
    float   radius = 0.0;
    float   lineWidth = 0.0;
    
    [self getRadius:&radius lineWidth:&lineWidth andBounds:&bounds
          fromFrame:frame];
    
    NSBezierPath    *buttonShape = [NSBezierPath
                                        bezierPathWithRoundRectInRect:bounds
                                                               radius:radius];
    CTGradient      *bgGradient = [self backgroundGradient];
    
    // Draw the background texture
    [bgGradient fillBezierPath:buttonShape angle:90.0];
    
    if ([self isBordered]) {
        // Add the border
        [[self borderColor] set];
        [buttonShape setLineWidth:lineWidth];
        [buttonShape stroke];
    }
}

- (void) drawInteriorWithFrame: (NSRect) frame inView: (NSView *) control {
    NSBezelStyle    bezel = [self bezelStyle];
    NSButtonType    type = [self buttonType];
    NSRect          bounds = NSZeroRect;
    float           radius = 0.0;
    float           lineWidth = 0.0;
    float           radiusPad = 0.0;
    
    [self getRadius:&radius lineWidth:&lineWidth andBounds:&bounds
          fromFrame:frame];
    
    // Determine writable area.
    radiusPad = radius * 0.4;
    if (bezel != NSHelpButtonBezelStyle) {
        bounds.origin.x = radiusPad + lineWidth;
        bounds.origin.y = radiusPad + lineWidth;
        bounds.size.width -= (radiusPad * 2.0) + lineWidth;
        bounds.size.height -= (radiusPad * 2.0) + lineWidth;
    } else {
        bounds.origin.x = lineWidth * 1.0;
        bounds.origin.y = lineWidth * 1.0;
        bounds.size.width -= lineWidth * 1.0;
        bounds.size.height -= lineWidth * 1.0;
    }
    
    // Add the image
    NSImage         *image = nil;
    NSRect          imageRect = bounds;
    
    if (type == NSSwitchButton || type == NSRadioButton ||
        bezel == NSHelpButtonBezelStyle || bezel == NSDisclosureBezelStyle) {
        image = [self drawCustomImageForSize:imageRect.size];
    } else {
        if ([self isHighlighted]) {
            image = [self alternateImage];
        }
        if (image == nil) {
            image = [self image];
        }
    }
    
    if (image != nil) {
        // Fix the image position
        if (bezel == NSHelpButtonBezelStyle || bezel == NSDisclosureBezelStyle) {
            [self setImagePosition:NSImageOnly];
        }
        
        // Account for padding between the image and title if they are stacked.
        switch ([self imagePosition]) {
            case NSImageAbove:
            case NSImageBelow:
                imageRect.size.height -= radiusPad;
                break;
        }
        
        NSSize  imageSize = [self drawImage:image withFrame:imageRect
                                     inView:control];
        
        // Update the leftover space for the title.
        switch ([self imagePosition]) {
            case NSImageLeft:
                bounds.origin.x += imageSize.width + radiusPad / 2.0;
            case NSImageRight:
                bounds.size.width -= imageSize.width + radiusPad / 2.0;
                break;
            case NSImageAbove:
                bounds.size.height -= imageSize.height + radiusPad / 2.0;
                break;
            case NSImageBelow:
                bounds.size.height -= imageSize.height;
                bounds.origin.y += imageSize.height + radiusPad / 2.0;
                break;
        }
    }
    
    // Button styles that have no text.
    switch (bezel) {
        case NSHelpButtonBezelStyle:
        case NSDisclosureBezelStyle:
            return;
    }
    
    // Add the title
    NSMutableDictionary         *attrs = nil;
    NSMutableAttributedString   *title = nil;
    NSRect                      titleRect = bounds;
    
    if ([self isHighlighted]) {
        title = [[NSMutableAttributedString alloc]
                    initWithString:[self alternateTitle]];
    }
    if (title == nil || [title length] == 0) {
        title = [[NSMutableAttributedString alloc]
                    initWithString:[self title]];
    }
    
    if (title != nil && [title length] > 0 && !NSIsEmptyRect(frame)) {
        // Setup the attributes.
        NSRange     attrsRange = NSMakeRange(0, [title length]);
        
        attrs = [NSMutableDictionary dictionary];
        [attrs setObject:[self font] forKey:NSFontAttributeName];
        [attrs setObject:[self textColor]
                  forKey:NSForegroundColorAttributeName];
        [title setAttributes:attrs range:attrsRange];
        
        [self drawTitle:title withFrame:titleRect inView:control];
    }
}

- (void) drawTitle: (NSAttributedString *) title withFrame: (NSRect) frame
            inView: (NSView *) control {
    NSPoint point = NSZeroPoint;
    NSSize  size = [title size];
    NSImage *image = [[NSImage alloc] initWithSize:frame.size];
    
    // Adjust the alignment.
    point.y = (frame.size.height / 2.0) - (size.height / 2.0);
    switch ([self alignment]) {
        case NSLeftTextAlignment:
            point.x = 0;
            break;
        case NSRightTextAlignment:
            point.x = frame.size.width - size.width;
            break;
        case NSCenterTextAlignment:
        default:
            point.x = (frame.size.width / 2.0) - (size.width / 2.0);
            break;
    }
    
    // Draw the text.
    [image lockFocus];
    [title drawAtPoint:point];
    [image unlockFocus];
    
    point = frame.origin;
    if ([[self controlView] isFlipped]) {
        point.y += [image size].height;
    }
    [image compositeToPoint:point operation:NSCompositeSourceOver
                   fraction:1.0];
    [image release];
}

- (NSSize) drawImage: (NSImage *) image withFrame: (NSRect) frame
              inView: (NSView *) control {
    if ([self imagePosition] == NSNoImage || image == nil) {
        return(NSZeroSize);
    }
    
    NSSize  imageSize = NSZeroSize;
    NSRect  imageRect = NSZeroRect;
    
    [image setScalesWhenResized:YES];
    
    // Determine where to draw the image.
    imageRect.size = frame.size;
    switch ([self imagePosition]) {
        case NSImageLeft:
        case NSImageRight:
            [image scaleToFitSize:frame.size];
            imageSize = [image size];
            
            imageRect.origin.y += (imageRect.size.height / 2.0) - (imageSize.height / 2.0);
            if ([self imagePosition] == NSImageRight) {
                imageRect.origin.x += imageRect.size.width - imageSize.width;
            }
            break;
        case NSImageAbove:
        case NSImageBelow:
            imageRect.size.height /= 2.0;
            
            [image scaleToFitSize:frame.size];
            imageSize = [image size];
            
            imageRect.origin.x += (imageRect.size.width / 2.0) - (imageSize.width / 2.0);
            imageRect.origin.y += (imageRect.size.height / 2.0) - (imageSize.height / 2.0);
            if ([self imagePosition] == NSImageAbove) {
                imageRect.origin.y += imageRect.size.height;
            }
            break;
        case NSImageOverlaps:
        case NSImageOnly:
        default:
            [image scaleToFitSize:frame.size];
            imageSize = [image size];
            
            imageRect.origin.y += (imageRect.size.height / 2.0) - (imageSize.height / 2.0);
            imageRect.origin.x += (imageRect.size.width / 2.0) - (imageSize.width / 2.0);
            break;
    }
    
    // Draw the image while dealing with a flipped view.
    NSPoint point = frame.origin;
    imageRect.origin = NSZeroPoint;
    if ([[self controlView] isFlipped]) {
        point.y += imageSize.height;
    }
    [image compositeToPoint:point fromRect:imageRect
            operation:NSCompositeSourceOver fraction:1.0];
    
    return(imageSize);
}

// Draws the images to use for:
//  NSSwitchButton
//  NSRadioButton
//  NSHelpButtonBezelStyle
//  NSDisclosureBezelStyle
- (NSImage *) drawCustomImageForSize: (NSSize) size {
    NSBezelStyle    bezel = [self bezelStyle];
    NSButtonType    type = [self buttonType];
    NSImage         *image = nil;
    
    if (bezel == NSHelpButtonBezelStyle) {
        // Create a question mark image.
        NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
        NSString            *fontName = [[[self font] fontName]
                                            stringByAppendingString:@"-Bold"];
        
        [attrs setObject:[NSFont fontWithName:fontName
                                         size:[[self font] pointSize]]
                  forKey:NSFontAttributeName];
        [attrs setObject:[self textColor] forKey:NSForegroundColorAttributeName];
        
        NSAttributedString  *string = [@"?" attributedStringForSize:size
                                                     withAttributes:attrs];
        if (string == nil) {
            NSLog(@"CarFrontEndButtonCell: Button too small for '?' image!");
        } else {
            NSSize              strSize = [string size];
            NSPoint             point = NSZeroPoint;
            
            // Center it.
            point.y = (size.height / 2.0) - (strSize.height / 2.0);
            point.x = (size.width / 2.0) - (strSize.width / 2.0);
            
            // Create the image representation.
            image = [[[NSImage alloc] initWithSize:size] autorelease];
            [image lockFocus];
            [string drawAtPoint:point];
            [image unlockFocus];
        }
    } else if (bezel == NSDisclosureBezelStyle) {
        float           pad = MIN(size.width, size.height) * 0.1;
        NSSize          imageSize = NSMakeSize(MIN(size.width, size.height),
                                               MIN(size.width, size.height));
        NSPoint         pt1 = NSMakePoint(pad, imageSize.height - pad);
        NSPoint         pt2 = NSMakePoint(pad, pad);
        NSPoint         pt3 = NSMakePoint(imageSize.width - pad,
                                          imageSize.height / 2.0);
        
        if ([self state] == NSOnState) {
            // pointing down.
            pt2 = NSMakePoint(imageSize.width / 2.0, pad);
            pt3 = NSMakePoint(imageSize.width - pad, imageSize.height - pad);
        }
        
        // Create the path.
        NSBezierPath    *path = [NSBezierPath bezierPath];
        [path moveToPoint:pt1];
        [path lineToPoint:pt2];
        [path lineToPoint:pt3];
        [path lineToPoint:pt1];
        
        // Create the image.
        image = [[[NSImage alloc] initWithSize:imageSize] autorelease];
        [image lockFocus];
        
        [[self borderColor] set];
        [path fill];
        [image unlockFocus];
    } else if (type == NSRadioButton) {
        NSBezierPath    *buttonShape = nil;
        CTGradient      *bgGradient = nil;
        NSRect          imageRect = NSZeroRect;
        NSSize          imageSize = NSMakeSize(MIN(size.width, size.height),
                                               MIN(size.width, size.height));
        float           lineWidth = (imageSize.width * 0.10);
        
        imageRect.size = imageSize;
        imageRect.size.width -= lineWidth * 2.0;
        imageRect.size.height -= lineWidth * 2.0;
        imageRect.origin.x = lineWidth;
        imageRect.origin.y = lineWidth;
        
        buttonShape = [NSBezierPath bezierPathWithOvalInRect:imageRect];
        bgGradient = [self backgroundGradient];
        image = [[[NSImage alloc] initWithSize:imageSize] autorelease];
        
        // Draw the background texture
        [image lockFocus];
        [bgGradient fillBezierPath:buttonShape angle:90.0];
        
        // Add the border
        [[self borderColor] set];
        [buttonShape setLineWidth:lineWidth];
        [buttonShape stroke];
        
        // Add the dot if we are selected.
        if ([self state] == NSOnState) {
            imageRect = NSZeroRect;
            imageRect.size.width = [image size].width * 0.35;
            imageRect.size.height = imageRect.size.width;
            imageRect.origin.y = ([image size].height / 2.0) - (imageRect.size.height / 2.0);
            imageRect.origin.x = ([image size].width / 2.0) - (imageRect.size.width / 2.0);

            buttonShape = [NSBezierPath bezierPathWithOvalInRect:imageRect];
            [[self borderColor] set];
            [buttonShape fill];
        }
        
        [image unlockFocus];
    } else if (type == NSSwitchButton) {
        NSBezierPath    *buttonShape = nil;
        CTGradient      *bgGradient = nil;
        NSRect          imageRect = NSZeroRect;
        NSSize          imageSize = NSMakeSize(MIN(size.width, size.height),
                                               MIN(size.width, size.height));
        float           radius = imageSize.width / 4.0;
        float           lineWidth = (imageSize.width * 0.10) * 0.5;
        
        imageRect.size = imageSize;
        imageRect.size.width -= lineWidth * 4.0;
        imageRect.size.height -= lineWidth * 4.0;
        imageRect.origin.x = lineWidth * 2.0;
        imageRect.origin.y = lineWidth * 2.0;
        buttonShape = [NSBezierPath bezierPathWithRoundRectInRect:imageRect
                                                           radius:radius];
        bgGradient = [self backgroundGradient];
        image = [[[NSImage alloc] initWithSize:imageSize] autorelease];
        
        // Draw the background texture
        [image lockFocus];
        [bgGradient fillBezierPath:buttonShape angle:90.0];
        
        // Add the border
        [[self borderColor] set];
        [buttonShape setLineWidth:lineWidth];
        [buttonShape stroke];
        
        // Add the state identifier.
        if ([self state] == NSMixedState) {
            // Dash
            NSBezierPath    *path = [NSBezierPath bezierPath];
            NSPoint         point = NSMakePoint([image size].width * 0.25,
                                                [image size].height / 2.0);
            
            [path setLineWidth:lineWidth * 2.0];
            [path moveToPoint:point];
            point = NSMakePoint([image size].width * 0.75,
                                [image size].height / 2.0);
            [path lineToPoint:point];
            
            [[self borderColor] set];
            [path stroke];
        } else if ([self state] == NSOnState) {
            // Check
            NSBezierPath    *path = [NSBezierPath bezierPath];
            NSPoint         point = NSMakePoint([image size].width * 0.25,
                                                [image size].height * 0.6);
            
            lineWidth *= 2.0;
            [path setLineWidth:lineWidth];
            [path moveToPoint:point];
            point = NSMakePoint([image size].width / 2.0,
                                [image size].height / 3.0);
            [path lineToPoint:point];
            point = NSMakePoint([image size].width - lineWidth,
                                [image size].height);
            [path lineToPoint:point];
            
            [[self borderColor] set];
            [path stroke];
        }
        
        [image unlockFocus];
    }
    
    return(image);
}

- (CTGradient *) backgroundGradient {
    CTGradient      *bgGradient = nil;
    NSButtonType    type = [self buttonType];
    BOOL            highlighted = [self isHighlighted];
    
    if (type == NSSwitchButton || type == NSRadioButton) {
        highlighted = NO;
        switch ([self state]) {
            case NSMixedState:
                if (type != NSSwitchButton) {
                    break;
                }
            case NSOnState:
                highlighted = YES;
        }
    }
    
    switch ([self buttonTexture]) {
        case CFEUnifiedButtonTexture:
            if (highlighted) {
                bgGradient = [CTGradient unifiedPressedGradient];
            } else {
                bgGradient = [CTGradient unifiedNormalGradient];
            }
            break;
        default:
            bgGradient = [[[CTGradient alloc] init] autorelease];
            NSArray         *colors = nil;
            int             i = 0;
            
            if (highlighted) {
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
    
    return(bgGradient);
}

@end
