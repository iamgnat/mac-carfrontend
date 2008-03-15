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
#import <CarFrontEndAPI/CarFrontEndButtonCell.h>

@interface CarFrontEndButton : NSButton <NSCoding> {}

/*
 * NOTE: Until there is an IB Palette available, you will need to manually set
 *          set the font information in IB. For consistance, please use
 *          Helvetica as the face and 27 for the point size.
 */

#pragma mark NSCoding methods
- (id) initWithCoder: (NSCoder *) coder;

#pragma mark CFEButton methods
- (NSColor *) stringColor;
- (void) setStringColor: (NSColor *) color;
- (NSString *) fontName;
- (void) setFontName: (NSString *) name;
- (float) fontSize;
- (void) setFontSize: (float) size;

#pragma mark CFEButton class methods
+ (NSColor *) defaultStringColor;                   // Deprecated
+ (void) setDefaultStringColor: (NSColor *) color;  // Deprecated
+ (NSString *) defaultFontName;
+ (void) setDefaultFontName: (NSString *) name;
+ (float) defaultFontSize;
+ (void) setDefaultFontSize: (float) size;

#pragma mark CFEButtonCell methods
- (NSButtonType) buttonType;
- (void) setButtonTexture: (CFEButtonTexture) texture;
- (CFEButtonTexture) buttonTexture;
- (void) setFlatTextureColor: (NSColor *) color;
- (NSColor *) flatTextureColor;
- (void) setFlatHighlightTextureColor: (NSColor *) color;
- (NSColor *) flatHighlightTextureColor;
- (void) setGradientTextureColors: (NSArray *) colors;
- (NSArray *) gradientTextureColors;
- (void) setGradientHighlightTextureColors: (NSArray *) colors;
- (NSArray *) gradientHighlightTextureColors;
- (void) setBorderColor: (NSColor *) color;
- (NSColor *) borderColor;
- (void) setTextColor: (NSColor *) color;
- (NSColor *) textColor;
- (void) setFont: (NSFont *) font;
- (NSFont *) font;

@end
