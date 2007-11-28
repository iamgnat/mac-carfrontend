/*
 * CarFrontEndAPI - NSImageUtils.m - David Whittle (iamgnat@gmail.com)
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

#import "NSImageUtils.h"

@implementation NSImage (Utilities)

#pragma mark Size Scaling
+ (NSSize) scaleSize: (NSSize) size forWidth: (double) width {
    if (size.width == width) return(size);
    
    double  diff = width / size.width;
    size.height = size.height * diff;
    size.width = width;
    
    return(size);
}

+ (NSSize) scaleSize: (NSSize) size forHeight: (double) height {
    if (size.height == height) return(size);
    
    double  diff = height / size.height;
    size.width = size.width * diff;
    size.height = height;
    
    return(size);
}

+ (NSSize) scaleSize: (NSSize) size toFitSize: (NSSize) base {
    if ((size.width == base.width && size.height <= base.height) ||
        (size.height == base.height && size.width <= base.width)) {
        return(size);
    }
    
    if (size.width > size.height) {
        // Short & fat.
        return([NSImage scaleSize:size forWidth:base.width]);
    } else {
        // Long & emaciated
        return([NSImage scaleSize:size forHeight:base.height]);
    }
}

- (void) scaleForWidth: (double) width {
    [self setSize:[NSImage scaleSize:[self size] forWidth:width]];
}

- (void) scaleForHeight: (double) height {
    [self setSize:[NSImage scaleSize:[self size] forHeight:height]];
}

- (void) scaleToFitSize: (NSSize) size {
    [self setSize:[NSImage scaleSize:[self size] toFitSize:size]];
}

@end
