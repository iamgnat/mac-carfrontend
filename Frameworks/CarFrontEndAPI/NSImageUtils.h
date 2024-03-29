/*
 * CarFrontEndAPI - NSImageUtils.h - David Whittle (iamgnat@gmail.com)
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

#import <AppKit/AppKit.h>

@interface NSImage (Utilities)

#pragma mark Size Scaling
+ (NSSize) scaleSize: (NSSize) size forWidth: (double) width;
+ (NSSize) scaleSize: (NSSize) size forHeight: (double) height;
+ (NSSize) scaleSize: (NSSize) size toFitSize: (NSSize) base;
- (void) scaleForWidth: (double) width;
- (void) scaleForHeight: (double) height;
- (void) scaleToFitSize: (NSSize) size;

@end
