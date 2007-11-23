/*
 * CarFrontEndAPI - CarFrontEndButtonCell.h - David Whittle (iamgnat@gmail.com)
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

#import <Cocoa/Cocoa.h>

typedef enum _CFEButtonTexture {
    CFEFirstButtonTexture       = 0, // Place holder
    CFEFlatButtonTexture        = 0, // Single color background
    CFEGradientButtonTexture    = 1, // Multi-color gradient background
    CFEUnifiedButtonTexture     = 2, // Unified theme background
    CFELastButtonTexture        = 2, // Place holder
} CFEButtonTexture;

@interface CarFrontEndButtonCell : NSButtonCell <NSCoding> {
    CFEButtonTexture    _buttonTexture;
    NSArray             *_gradientColors;
    NSArray             *_gradientHighlightColors;
    NSColor             *_borderColor;
    NSColor             *_textColor;
}

#pragma mark NSCoding methods
- (id) initWithCoder: (NSCoder *) coder;
- (void) encodeWithCoder: (NSCoder *) coder;

#pragma mark Override methods
- (id) init;
- (id) initImageCell: (NSImage *) image;
- (id) initTextCell: (NSString *) string;
- (void) dealloc;

#pragma mark Button texture
- (void) setButtonTexture: (CFEButtonTexture) texture;
- (CFEButtonTexture) buttonTexture;

#pragma mark Button coloring
// Color used for CFEFlatButtonTexture
//  Pass nil for the color to set it to the default (black for normal and
//      0.6/0.6/0.6 for highlight).
- (void) setFlatTextureColor: (NSColor *) color;
- (NSColor *) flatTextureColor;
- (void) setFlatHighlightTextureColor: (NSColor *) color;
- (NSColor *) flatHighlightTextureColor;

// Colors used for CFEGradientButtonTexture
//  Expects/returns NSArray of NSColor.
//  Passing nil will reset to the default (0.3/0.3/0.3 for normal and 
//      0.6/0.6/0.6 for highlight)
//  NB: You can replicate CFEFlatButtonTexture with a single color.
- (void) setGradientTextureColors: (NSArray *) colors;
- (NSArray *) gradientTextureColors;
- (void) setGradientHighlightTextureColors: (NSArray *) colors;
- (NSArray *) gradientHighlightTextureColors;

// Color for button border.
//  If isBordered == NO, then no border will be drawn.
- (void) setBorderColor: (NSColor *) color;
- (NSColor *) borderColor;

// Text color
//  Obviously ignore if text is not present/displayed.
//  Passing nil will set it to the default (varies with texture type).
- (void) setTextColor: (NSColor *) color;
- (NSColor *) textColor;

#pragma mark Button drawing
- (void) drawImage: (NSImage*) image withFrame: (NSRect) frame
            inView: (NSView*) view;
- (void) drawWithFrame: (NSRect) frame inView: (NSView *) view;

@end
