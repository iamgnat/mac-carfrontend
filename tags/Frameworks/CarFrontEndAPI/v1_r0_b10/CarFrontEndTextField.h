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
}

#pragma mark NSCoding methods
- (id) initWithCoder: (NSCoder *) coder;
- (void) encodeWithCoder: (NSCoder *) coder;

#pragma mark NSTextField override methods
- (NSColor *) textColor;
- (NSColor *) backgroundColor;
- (NSFont *) font;
- (void) setDrawsBackground: (BOOL) value;

#pragma mark CarFrontEndTextField class methods
+ (NSColor *) defaultTextColor;
+ (void) setDefaultTextColor: (NSColor *) color;
+ (NSColor *) defaultBackgroundColor;
+ (void) setDefaultBackgroundColor: (NSColor *) color;
+ (NSFont *) defaultFont;
+ (void) setDefaultFont: (NSFont *) value;

@end
