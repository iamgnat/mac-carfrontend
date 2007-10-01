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
#import "CarFrontEndTextField.h"
#import "CarFrontEndAPI.h"

#define SCROLL_TIMER_INTERVAL   0.2
static NSTimer          *ScrollTimer = nil;
static NSMutableArray   *ScrollTimerEvents = nil;
static NSColor          *defaultForegroundColor = nil;
static NSColor          *defaultBackgroundColor = nil;
static NSString         *defaultFontName = nil;
static float            defaultFontSize = 27.0;

#pragma mark private declarations
@interface CarFrontEndTextField (private)

- (void) updateStringValue;
- (void) timerEvent: (NSTimer *) timer;
- (void) addToScrollTimerWithDelay: (float) delay;
- (void) removeScrollTimer;
- (void) handleNotifications: (NSNotification *) note;

@end

@implementation CarFrontEndTextField

- (id) init {
    self = [super init];
    
    inInit = YES;
    currPos = 0;
    [self setForegroundColor:[CarFrontEndTextField defaultForegroundColor]];
    [self setBackgroundColor:[CarFrontEndTextField defaultBackgroundColor]];
    [self setFontName:[CarFrontEndTextField defaultFontName]];
    [self setFontSize:[CarFrontEndTextField defaultFontSize]];
    [self setStringValue:[NSString string]];
    
    NSNotificationCenter    *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(handleNotifications:)
               name:NSApplicationDidBecomeActiveNotification object:nil];
    [nc addObserver:self selector:@selector(handleNotifications:)
               name:NSApplicationDidResignActiveNotification object:nil];
    [nc addObserver:self selector:@selector(handleNotifications:)
               name:CFENotificationChangeForegroundColor object:nil];
    [nc addObserver:self selector:@selector(handleNotifications:)
               name:CFENotificationChangeBackgroundColor object:nil];
    
    inInit = NO;
    
    [self updateStringValue];
    return(self);
}

#pragma mark NSCoding methods
- (id) initWithCoder: (NSCoder *) coder {
    if (self = [super initWithCoder:coder]) {
        inInit = YES;
        currPos = 0;
        [self setStringValue:[super stringValue]];
        
        fontName = [[coder decodeObjectForKey:@"CFETextFieldFontName"] retain];
        foregroundColor = [[coder decodeObjectForKey:@"CFETextFieldForegroundColor"]
                           retain];
        backgroundColor = [[coder decodeObjectForKey:@"CFETextFieldBackgroundColor"]
                           retain];
        NSNumber    *size = [[coder decodeObjectForKey:@"CFETextFieldFontSize"]
                             retain];
        
        if (fontName == nil) {
            [self setFontName:[CarFrontEndTextField defaultFontName]];
        }
        if (foregroundColor == nil) {
            [self setForegroundColor:[CarFrontEndTextField defaultForegroundColor]];
        }
        if (backgroundColor == nil) {
            [self setBackgroundColor:[CarFrontEndTextField defaultBackgroundColor]];
        }
        if (size == nil) {
            [self setFontSize:[CarFrontEndTextField defaultFontSize]];
        } else {
            [self setFontSize:[size floatValue]];
        }
        
        NSNotificationCenter    *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(handleNotifications:)
                   name:NSApplicationDidBecomeActiveNotification object:nil];
        [nc addObserver:self selector:@selector(handleNotifications:)
                   name:NSApplicationDidResignActiveNotification object:nil];
    }
    inInit = NO;
    [self updateStringValue];
    
    return(self);
}

- (void) encodeWithCoder: (NSCoder *) coder {
    [super encodeWithCoder:coder];
    
    [coder encodeObject:fontName forKey:@"CFETextFieldFontName"];
    [coder encodeObject:foregroundColor forKey:@"CFETextFieldForegroundColor"];
    [coder encodeObject:backgroundColor forKey:@"CFETextFieldBackgroundColor"];
    [coder encodeObject:[NSNumber numberWithFloat:fontSize]
                 forKey:@"CFETextFieldFontSize"];
}


#pragma mark NSButton override methods
- (void) dealloc {
    NSNotificationCenter    *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
    
    if (fullTitle != nil) [fullTitle release];
    if (fontName != nil) [fontName release];
    if (foregroundColor != nil) [foregroundColor release];
    if (backgroundColor != nil) [backgroundColor release];
    [super dealloc];
}

- (void) setAttributedString: (NSAttributedString *) value {
    [self setStringValue:[value string]];
}

- (NSAttributedString *) attributedString {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    [attributes setObject:[NSFont fontWithName:fontName size:fontSize]
                   forKey:NSFontAttributeName];
    [attributes setObject:foregroundColor forKey:NSForegroundColorAttributeName];
    [attributes setObject:backgroundColor forKey:NSBackgroundColorAttributeName];
    
    NSAttributedString  *string = [[[NSAttributedString alloc]
                                    initWithString:fullTitle
                                    attributes:attributes]
                                   autorelease];
    return(string);
}

- (void) setStringValue: (NSString *) value {
    if ([super isEditable]) {
        [super setStringValue:value];
    } else {
        if (fullTitle != nil) [fullTitle release];
        fullTitle = [value retain];
        currPos = 0;
        [self updateStringValue];
    }
}

- (NSString *) stringValue {
    if ([super isEditable]) {
        return([super stringValue]);
    } else {
        return(fullTitle);
    }
}

#pragma mark CarFrontEndTextField methods
- (NSColor *) foregroundColor {return(foregroundColor);}

- (void) setForegroundColor: (NSColor *) color {
    [color retain];
    [foregroundColor release];
    foregroundColor = color;
    [self updateStringValue];
}

- (NSColor *) backgroundColor {return(backgroundColor);}

- (void) setBackgroundColor: (NSColor *) color {
    [color retain];
    [backgroundColor release];
    backgroundColor = color;
    [self updateStringValue];
}

- (NSString *) fontName {
    return(fontName);
}

- (void) setFontName: (NSString *) name {
    [fontName release];
    fontName = [name retain];
    [self updateStringValue];
}

- (float) fontSize{
    return(fontSize);
}

- (void) setFontSize: (float) size {
    fontSize = size;
    [self updateStringValue];
}

- (BOOL) scrolling {
    return(scrolling);
}

- (void) setScrolling: (BOOL) value {
    scrolling = value;
}

- (BOOL) scrollOnlyInFrame {
    return(scrollOnlyInFrame);
}

- (void) setScrollOnlyInFrame: (BOOL) value {
    scrollOnlyInFrame = value;
}

- (BOOL) endWithEllipsis {
    return(endWithEllipsis);
}

- (void) setEndWithEllipsis: (BOOL) value {
    endWithEllipsis = value;
}

#pragma mark CarFrontEndTextField class methods
+ (NSColor *) defaultForegroundColor {
    if (defaultForegroundColor == nil) {
        defaultForegroundColor = [[NSColor whiteColor] retain];
    }
    return(defaultForegroundColor);
}

+ (void) setDefaultForegroundColor: (NSColor *) color {
    // NSColor is immutable so we don't need to copy it.
    [defaultForegroundColor release];
    defaultForegroundColor = [color retain];
}

+ (NSColor *) defaultBackgroundColor {
    if (defaultBackgroundColor == nil) {
        defaultBackgroundColor = [[NSColor blackColor] retain];
    }
    return(defaultBackgroundColor);
}

+ (void) setDefaultBackgroundColor: (NSColor *) color {
    // NSColor is immutable so we don't need to copy it.
    [defaultBackgroundColor release];
    defaultBackgroundColor = [color retain];
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

@end

@implementation CarFrontEndTextField (private)

- (void) updateStringValue {
    if ([super isEditable]) return;
    if (inInit) return;
    
    NSMutableDictionary *attrs = [NSMutableDictionary dictionary];
    [attrs setObject:[NSFont fontWithName:fontName size:fontSize]
              forKey:NSFontAttributeName];
    [attrs setObject:foregroundColor forKey:NSForegroundColorAttributeName];
    [attrs setObject:backgroundColor forKey:NSBackgroundColorAttributeName];
    
    NSString    *string = nil;
    NSSize      size = [self frame].size;
    
    size.width -= 5;
    
    if (currPos == 0) {
        string = [fullTitle stringForSize:size
                           withAttributes:attrs
                                     from:currPos];
    } else {
        string = [fullTitle stringForSize:size
                           withAttributes:attrs
                                     from:currPos];
        if ([fullTitle hasSuffix:string]) {
            currPos = -1;
        }
    }
    
    currPos++;
    [super setAttributedStringValue:[[[NSAttributedString alloc]
                                      initWithString:string attributes:attrs]
                                     autorelease]];
    if (![string isEqualToString:fullTitle]) {
        float   timeInt = 0.5;
        
        if (currPos < 2) {
            // Pause at the begining or end of the string.
            timeInt = 1.5;
        }
        [self addToScrollTimerWithDelay:timeInt];
    }
}

- (void) timerEvent: (NSTimer *) timer {
    if (ScrollTimer == nil || timer != ScrollTimer) return;
    
    if (ScrollTimerEvents == nil || [ScrollTimerEvents count] == 0) {
        if (ScrollTimerEvents != nil) {
            [ScrollTimerEvents release];
            ScrollTimerEvents = nil;
        }
        [ScrollTimer invalidate];
        [ScrollTimer release];
        ScrollTimer = nil;
        [self release]; // We retained ourself, time to let go.
        return;
    }
    
    NSArray *copy = [ScrollTimerEvents copy];
    
    int i = 0;
    for (i = 0 ; i < [copy count] ; i++) {
        NSMutableDictionary     *info = [copy objectAtIndex:i];
        CarFrontEndTextField    *inst = [info objectForKey:@"instance"];
        NSNumber            *num = [info objectForKey:@"delay"];
        float               time = [num floatValue] - SCROLL_TIMER_INTERVAL;
        
        if ([inst window] == nil || ![[inst window] isVisible]) {
            [inst removeScrollTimer];
            continue;
        }
        
        if (time > SCROLL_TIMER_INTERVAL) {
            // Not time to fire yet.
            [info setObject:[NSNumber numberWithFloat:time]
                     forKey:@"delay"];
            continue;
        }
        
        // Fire and forget.
        [inst removeScrollTimer];
        [inst updateStringValue];
    }
}

- (void) addToScrollTimerWithDelay: (float) delay {
    if ([self window] == nil || ![[self window] isVisible]) return;
    
    NSNumber            *num = [NSNumber numberWithFloat:delay];
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    
    [info setObject:num forKey:@"delay"];
    [info setObject:self forKey:@"instance"];
    
    if (ScrollTimerEvents == nil) {
        ScrollTimerEvents = [[NSMutableArray array] retain];
    }
    [self removeScrollTimer]; // Make sure only one event is going to fire.
    [ScrollTimerEvents addObject:info];
    
    if (ScrollTimer == nil) {
        [self retain];  // Since we are claiming ownership of the timer, we
                        //  don't want to go away ;)
        ScrollTimer = [[NSTimer scheduledTimerWithTimeInterval:SCROLL_TIMER_INTERVAL
                                                        target:self
                                                      selector:@selector(timerEvent:)
                                                      userInfo:nil
                                                       repeats:YES] retain];
    }
}

- (void) removeScrollTimer {
    if (ScrollTimerEvents == nil || [ScrollTimerEvents count] == 0) return;
    int     i = 0;
    for (i = 0 ; i < [ScrollTimerEvents count] ; i++) {
        if ([[ScrollTimerEvents objectAtIndex:i] objectForKey:@"instance"] == self) {
            [ScrollTimerEvents removeObjectAtIndex:i];
        }
    }
}

- (void) handleNotifications: (NSNotification *) note {
    NSString                *name = [note name];
    
    if ([name isEqualToString:NSApplicationDidBecomeActiveNotification]) {
        currPos = 0;
        [self updateStringValue];
    } else if ([name isEqualToString:NSApplicationDidResignActiveNotification]) {
        [self removeScrollTimer];
    } else if ([name isEqualToString:CFENotificationChangeForegroundColor]) {
        id  color = [note object];
        
        // Make sure they gave us something and it is a color.
        if (color != nil && [color isKindOfClass:[NSColor class]]) {
            [self setForegroundColor:color];
        }
    } else if ([name isEqualToString:CFENotificationChangeBackgroundColor]) {
        id  color = [note object];
        
        // Make sure they gave us something and it is a color.
        if (color != nil && [color isKindOfClass:[NSColor class]]) {
            [self setBackgroundColor:color];
        }
    }
}


// NSView override so we know when the field *should* be visible.
- (void) viewDidMoveToWindow {
    if ([self window] != nil) {
        currPos = 0;
        [self updateStringValue];
    } else {
        [self removeScrollTimer];
    }
}

@end

