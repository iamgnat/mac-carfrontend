/*
 * CarFrontEndAPI - CarFrontEndTextField.h - David Whittle (iamgnat@gmail.com)
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

@interface CarFrontEndTextField : NSTextField {
    NSString            *fullTitle;
    NSString            *fontName;
    float               fontSize;
    NSColor             *foregroundColor;
    NSColor             *backgroundColor;
    int                 currPos;
    BOOL                inInit;
    
    // Configuration options
    BOOL                scrolling;
    BOOL                scrollOnlyInFrame;
    BOOL                endWithEllipsis;
    
    NSTrackingRectTag   _trackingFrame;

}

#pragma mark NSCoding methods
- (id) initWithCoder: (NSCoder *) coder;
- (void) encodeWithCoder: (NSCoder *) coder;

#pragma mark NSTextField override methods
- (void) setAttributedString: (NSAttributedString *) value;
- (NSAttributedString *) attributedString;
- (void) setStringValue: (NSString *) value;
- (NSString *) stringValue;
- (void) setEditable: (BOOL) flag;

#pragma mark CarFrontEndTextField methods
- (NSColor *) foregroundColor;
- (void) setForegroundColor: (NSColor *) color;
- (NSColor *) backgroundColor;
- (void) setBackgroundColor: (NSColor *) color;
- (NSString *) fontName;
- (void) setFontName: (NSString *) name;
- (float) fontSize;
- (void) setFontSize: (float) size;
- (BOOL) scrolling;
- (void) setScrolling: (BOOL) value;
- (BOOL) scrollOnlyInFrame;
- (void) setScrollOnlyInFrame: (BOOL) value;
- (BOOL) endWithEllipsis;
- (void) setEndWithEllipsis: (BOOL) value;

#pragma mark CarFrontEndTextField class methods
+ (NSColor *) defaultForegroundColor;
+ (void) setDefaultForegroundColor: (NSColor *) color;
+ (NSColor *) defaultBackgroundColor;
+ (void) setDefaultBackgroundColor: (NSColor *) color;
+ (NSString *) defaultFontName;
+ (void) setDefaultFontName: (NSString *) name;
+ (float) defaultFontSize;
+ (void) setDefaultFontSize: (float) size;

@end
