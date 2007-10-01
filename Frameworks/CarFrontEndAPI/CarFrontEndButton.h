/*
 * CarFrontEndAPI - CarFrontEndButton.h - David Whittle (iamgnat@gmail.com)
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

@interface CarFrontEndButton : NSButton <NSCoding> {
    NSImage     *image;
    NSImage     *altImage;
    NSImage     *userImage;
    NSImage     *userAltImage;
    
    NSImage     *leftUpImage;
    NSImage     *middleUpImage;
    NSImage     *rightUpImage;
    NSImage     *leftDownImage;
    NSImage     *middleDownImage;
    NSImage     *rightDownImage;
    
    NSString    *string;
    
    NSColor     *stringColor;
    NSString    *fontName;
    float       fontSize;
    
    BOOL        inInit;
}

#pragma mark NSCoding methods
- (id) initWithCoder: (NSCoder *) coder;
- (void) encodeWithCoder: (NSCoder *) coder;

#pragma mark NSButton override methods
- (void) setStringValue: (NSString *) value;
- (NSString *) stringValue;
- (void) setImage: (NSImage *) value;
- (void) setAlternateImage: (NSImage *) value;
- (void) setFrame: (NSRect) frame;

// Stub out these methods as they could have adverse effects.
- (void) setButtonType: (NSButtonType) type;            // Noop
- (void) setImagePosition: (NSCellImagePosition) pos;   // Noop
- (void) setBordered: (BOOL) flag;                      // Noop
- (void) setTransparent: (BOOL) flag;                   // Noop

#pragma mark CFEButton methods
- (NSColor *) stringColor;
- (void) setStringColor: (NSColor *) color;
- (NSString *) fontName;
- (void) setFontName: (NSString *) name;
- (float) fontSize;
- (void) setFontSize: (float) size;

#pragma mark CFEButton class methods
+ (NSColor *) defaultStringColor;
+ (void) setDefaultStringColor: (NSColor *) color;
+ (NSString *) defaultFontName;
+ (void) setDefaultFontName: (NSString *) name;
+ (float) defaultFontSize;
+ (void) setDefaultFontSize: (float) size;

@end
