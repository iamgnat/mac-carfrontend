/*
 * CarFrontEndAPI - CarFrontEndTextField.m - David Whittle (iamgnat@gmail.com)
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
#import "CarFrontEndAPI.h"

static NSColor                  *DefaultTextColor = nil;
static NSColor                  *DefaultBackgroundColor = nil;
static NSFont                   *DefaultFont = nil;

#pragma mark private declarations
@interface CarFrontEndTextField (private)

- (void) handleNotifications: (NSNotification *) note;

@end

@implementation CarFrontEndTextField

- (id) initWithFrame: (NSRect) frameRect {
    self = [super initWithFrame:frameRect];
    
    [super setEditable:NO];
    [super setDrawsBackground:YES];
    [super setTextColor:[self textColor]];
    [super setBackgroundColor:[self backgroundColor]];
    [super setFont:[self font]];
    
    NSNotificationCenter    *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(handleNotifications:)
               name:NSApplicationDidBecomeActiveNotification object:nil];
    [nc addObserver:self selector:@selector(handleNotifications:)
               name:NSApplicationDidResignActiveNotification object:nil];
    [nc addObserver:self selector:@selector(handleNotifications:)
               name:CFENotificationChangeForegroundColor object:nil];
    [nc addObserver:self selector:@selector(handleNotifications:)
               name:CFENotificationChangeBackgroundColor object:nil];
    
    return(self);
}

#pragma mark NSCoding methods
- (id) initWithCoder: (NSCoder *) coder {
    if (self = [super initWithCoder:coder]) {
        // Check to see if these are the IB defaults. If so, we'll override with
        //  ours.
        NSFont  *font = [super font];
        
        if ([[super textColor] isEqualTo:[NSColor controlTextColor]]) {
            [super setTextColor:[CarFrontEndTextField defaultTextColor]];
        }
        if ([[super backgroundColor] isEqualTo:[NSColor controlColor]]) {
            [super setBackgroundColor:[CarFrontEndTextField defaultBackgroundColor]];
        }
        if ([[font fontName] isEqualToString:@"LucidaGrande"] ||
            [font pointSize] == 13.0) {
            NSFont      *defaultFont = [CarFrontEndTextField defaultFont];
            NSString    *fontName = [defaultFont fontName];
            float       pointSize = [defaultFont pointSize];
            
            if (![[font fontName] isEqualToString:@"LucidaGrande"]) {
                fontName = [font fontName];
            }
            if ([font pointSize] != 13.0) {
                pointSize = [font pointSize];
            }
            [super setFont:[NSFont fontWithName:fontName size:pointSize]];
        }
        
        [super setEditable:NO];
        [super setBordered:NO];
        [super setDrawsBackground:YES];
        
        NSNotificationCenter    *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(handleNotifications:)
                   name:NSApplicationDidBecomeActiveNotification object:nil];
        [nc addObserver:self selector:@selector(handleNotifications:)
                   name:NSApplicationDidResignActiveNotification object:nil];
    }
    
    return(self);
}

- (void) encodeWithCoder: (NSCoder *) coder {
    [super encodeWithCoder:coder];
}


#pragma mark NSTextField override methods
- (void) dealloc {
    NSNotificationCenter    *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
    
    [super dealloc];
}

- (NSColor *) textColor {
    if ([super textColor] != nil) return([super textColor]);
    return([CarFrontEndTextField defaultTextColor]);
}

- (NSColor *) backgroundColor {
    if ([super backgroundColor] != nil) return([super backgroundColor]);
    return([CarFrontEndTextField defaultBackgroundColor]);
}

- (NSFont *) font {
    if ([super font] != nil) return([super font]);
    return([CarFrontEndTextField defaultFont]);
}

- (void) setDrawsBackground: (BOOL) value {
    // No-op
}

#pragma mark CarFrontEndTextField class methods
+ (NSColor *) defaultTextColor {
    if (DefaultTextColor == nil) {
        DefaultTextColor = [[NSColor whiteColor] retain];
    }
    return(DefaultTextColor);
}

+ (void) setDefaultTextColor: (NSColor *) color {
    // NSColor is immutable so we don't need to copy it.
    if (DefaultTextColor != nil) [DefaultTextColor release];
    DefaultTextColor = [color retain];
}

+ (NSColor *) defaultBackgroundColor {
    if (DefaultBackgroundColor == nil) {
        DefaultBackgroundColor = [[NSColor blackColor] retain];
    }
    return(DefaultBackgroundColor);
}

+ (void) setDefaultBackgroundColor: (NSColor *) color {
    // NSColor is immutable so we don't need to copy it.
    if (DefaultBackgroundColor != nil) [DefaultBackgroundColor release];
    DefaultBackgroundColor = [color retain];
}

+ (NSFont *) defaultFont {
    if (DefaultFont == nil) {
        DefaultFont = [[NSFont fontWithName:@"Helvetica" size:27.0] retain];
    }
    return(DefaultFont);
}

+ (void) setDefaultFont: (NSFont *) value {
    if (DefaultFont != nil) [DefaultFont release];
    DefaultFont = [value retain];
}

@end

@implementation CarFrontEndTextField (private)

- (void) handleNotifications: (NSNotification *) note {
    NSString                *name = [note name];
    
    if ([name isEqualToString:CFENotificationChangeForegroundColor]) {
        id  color = [note object];
        
        // Make sure they gave us something and it is a color.
        if (color != nil && [color isKindOfClass:[NSColor class]]) {
            [self setTextColor:color];
        }
    } else if ([name isEqualToString:CFENotificationChangeBackgroundColor]) {
        id  color = [note object];
        
        // Make sure they gave us something and it is a color.
        if (color != nil && [color isKindOfClass:[NSColor class]]) {
            [self setBackgroundColor:color];
        }
    }
}

@end
