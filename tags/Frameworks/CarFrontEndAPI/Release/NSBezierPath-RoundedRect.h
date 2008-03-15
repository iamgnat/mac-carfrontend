/*
 * CarFrontEndAPI - NSBezierPath-RoundedRect.h - David Whittle (iamgnat@gmail.com)
 * 
 * The method defined by this Category was taken from an anonymous post
 * on CocoaDev at http://www.cocoadev.com/index.pl?RoundedRectangles and as
 * such the developers of CarFrontEnd make no claim to the copyright.
 *
 * As it was posted on a public website for the purpose of assisting other
 * developers, I have included the GPL v3 license notice as I believe it
 * is an acceptable license for the situation. If you feel otherwise or are the
 * original author of this code, please feel free to contact me and I will
 * include more appropriate license notice.
 *
 * If you are the unknown author, thank you.
 *
 * GPL v3 license notice:
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

@interface NSBezierPath (RoundedRect)

+ (NSBezierPath*) bezierPathWithRoundRectInRect: (NSRect) aRect
                                         radius: (float) radius;

@end
