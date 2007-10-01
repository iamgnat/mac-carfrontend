/*
 * CarFrontEndAPI - NSString.m - David Whittle (iamgnat@gmail.com)
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

#import "NSString.h"

@implementation NSString (NSStringUtils)

- (NSString *) stringForSize: (NSSize) size
              withAttributes: (NSDictionary *) attributes {
    return([self stringForSize:size withAttributes:attributes from:0]);
}

- (NSString *) stringForSize: (NSSize) size
              withAttributes: (NSDictionary *) attributes
                        from: (int) start {
    if (attributes == nil) {
        [NSException raise:@"CTFNSStringException"
                    format:@"No attributes supplied!"];
    }
    
    int         length = [self length] - start;
    NSString    *string = [self substringWithRange:NSMakeRange(start, length)];
    NSSize      strSize = [string sizeWithAttributes:attributes];

    if (strSize.height > size.height) {
        [NSException raise:@"CTFNSStringException"
                    format:@"The height of the string is too tall for the given size with the supplied attributes."];
    }
    
    while (strSize.width > size.width) {
        length--;
        if (length == 0) break;
        
        string = [self substringWithRange:NSMakeRange(start, length)];
        strSize = [string sizeWithAttributes:attributes];
    }
    
    if (length <= 0) {
        [NSException raise:@"CTFNSStringException"
                    format:@"No portion of the string can fit in the given size with the supplied attributes."];
    }
    
    return(string);
}

@end
