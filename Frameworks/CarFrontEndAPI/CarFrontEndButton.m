/*
 * CarFrontEndAPI - CarFrontEndButton.m - David Whittle (iamgnat@gmail.com)
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

#import "CarFrontEndButton.h"
#import "NSImageUtils.h"
#import "CarFrontEndAPI.h"

static NSColor  *defaultStringColor = nil;
static NSString *defaultFontName = nil;
static float    defaultFontSize = 27.0;

#pragma mark private declarations
@interface CarFrontEndButton (private)

- (void) notificationHandler: (NSNotification *) note;

@end

@implementation CarFrontEndButton

#pragma mark NSCoding methods
- (id) initWithCoder: (NSCoder *) origCoder {
    if(![origCoder isKindOfClass: [NSKeyedUnarchiver class]]){
		self = [super initWithCoder:origCoder]; 
	} else {
		NSKeyedUnarchiver   *coder = (id)origCoder;
		NSString            *oldClassName = [[[self superclass] cellClass]
                                                className];
		Class               oldClass = [coder classForClassName:oldClassName];
		
        if (!oldClass) {
            oldClass = [[super superclass] cellClass];
        }
		[coder setClass:[[self class] cellClass] forClassName:oldClassName];
		self = [super initWithCoder:coder];
		[coder setClass:oldClass forClassName:oldClassName];
		
        // Set the default font information
        NSString    *fontName = [CarFrontEndButton defaultFontName];
        float       fontSize = [CarFrontEndButton defaultFontSize];
        if ([self font] != nil) {
            if (![[[self font] fontName] isEqualToString:@"LucidaGrande"]) {
                fontName = [[self font] fontName];
            }
            if ([[self font] pointSize] != 10.0) {
                fontSize = [[self font] pointSize];
            }
        }
        [self setFont:[NSFont fontWithName:fontName size:fontSize]];
        
        NSNotificationCenter    *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(notificationHandler:)
                   name:CFENotificationChangeForegroundColor object:nil];
    }
    
    return(self);
}

- (void) encodeWithCoder: (NSCoder *) coder {
    [super encodeWithCoder:coder];
}

#pragma mark NSButton override methods
- (id) initWithFrame: (NSRect) frameRect {
	if ((self = [super initWithFrame:frameRect]) != nil) {
        NSNotificationCenter    *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(notificationHandler:)
                   name:CFENotificationChangeForegroundColor object:nil];
    }
    
	return(self);
}

+ (Class) cellClass {
    return([CarFrontEndButtonCell class]);
}

- (void) setStringValue: (NSString *) value {
    [self setTitle:value];
}

- (NSString *) stringValue {
    return([self title]);
}

#pragma mark CFEButton methods
- (NSColor *) stringColor {
    NSLog(@"CarFrontEndButton: -stringColor is deprecated, use -textColor instead.");
    return([self textColor]);
}

- (void) setStringColor: (NSColor *) color {
    NSLog(@"CarFrontEndButton: -setStringColor is deprecated, use -setTextColor instead.");
    [self setTextColor:color];
}

- (NSString *) fontName {
    return([[self font] fontName]);
}

- (void) setFontName: (NSString *) name {
    [self setFont:[NSFont fontWithName:name size:[[self font] pointSize]]];
}

- (float) fontSize {
    return([[self font] pointSize]);
}

- (void) setFontSize: (float) size {
    [self setFont:[NSFont fontWithName:[[self font] fontName] size:size]];
}

#pragma mark CFEButton class methods
+ (NSColor *) defaultStringColor {
    if (defaultStringColor == nil) {defaultStringColor = [[NSColor whiteColor] retain];}
    return(defaultStringColor);
}

+ (void) setDefaultStringColor: (NSColor *) color {
    // NSColor is immutable so we don't need to copy it.
    [defaultStringColor release];
    defaultStringColor = [color retain];
}

+ (NSString *) defaultFontName {
    if (defaultFontName == nil) {defaultFontName = [@"Helvetica" retain];}
    return(defaultFontName);
}

+ (void) setDefaultFontName: (NSString *) name {
    [defaultFontName release];
    // Create a new string in case they gave us  mutable copy.
    defaultFontName = [[NSString alloc] initWithString:name];
}

+ (float) defaultFontSize {
    return(defaultFontSize);
}

+ (void) setDefaultFontSize: (float) size {
    defaultFontSize = size;
}

#pragma mark CFEButtonCell methods
- (void) setButtonTexture: (CFEButtonTexture) texture {
    [[self cell] setButtonTexture:texture];
}

- (CFEButtonTexture) buttonTexture {
    return([[self cell] buttonTexture]);
}

- (void) setFlatTextureColor: (NSColor *) color {
    [[self cell] setFlatTextureColor:color];
}

- (NSColor *) flatTextureColor {
    return([[self cell] flatTextureColor]);
}

- (void) setFlatHighlightTextureColor: (NSColor *) color {
    [[self cell] setFlatHighlightTextureColor:color];
}

- (NSColor *) flatHighlightTextureColor {
    return([[self cell] flatHighlightTextureColor]);
}

- (void) setGradientTextureColors: (NSArray *) colors {
    [[self cell] setGradientTextureColors:colors];
}

- (NSArray *) gradientTextureColors {
    return([[self cell] gradientTextureColors]);
}

- (void) setGradientHighlightTextureColors: (NSArray *) colors {
    [[self cell] setGradientHighlightTextureColors:colors];
}

- (NSArray *) gradientHighlightTextureColors {
    return([[self cell] gradientHighlightTextureColors]);
}

- (void) setBorderColor: (NSColor *) color {
    [[self cell] setBorderColor:color];
}

- (NSColor *) borderColor {
    return([[self cell] borderColor]);
}

- (void) setTextColor: (NSColor *) color {
    [[self cell] setTextColor:color];
}

- (NSColor *) textColor {
    return([[self cell] textColor]);
}

- (void) setFont: (NSFont *) font {
    [[self cell] setFont:font];
}

- (NSFont *) font {
    return([[self cell] font]);
}


#pragma mark private methods
- (void) notificationHandler: (NSNotification *) note {
    if ([[note name] isEqualToString:CFENotificationChangeForegroundColor]) {
        id  color = [note object];
        
        // Make sure they gave us something and it is a color.
        if (color != nil && [color isKindOfClass:[NSColor class]]) {
            [self setTextColor:color];
        }
    }
}

@end
