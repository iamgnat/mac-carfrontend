/*
 * CarFrontEndAPI - CarFrontEndAPI.c - David Whittle (iamgnat@gmail.com)
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

#include "CarFrontEndAPI.h"

#pragma mark CarFrontEnd UI notifications
NSString    *CFENotificationChangeForegroundColor = @"CFENotificationChangeForegroundColor";
NSString    *CFENotificationChangeBackgroundColor = @"CFENotificationChangeForegroundColor";

#pragma mark CarFrontEnd Plugin Messaging

CFEMessage CFECreateMessage(NSString *name, BOOL activeOnly) {
    CFEMessage  msg;
    
    msg.name = [name retain];
    msg.activeOnly = activeOnly;
    return(msg);
}

void CFEDestroyMessage(CFEMessage msg) {
    [msg.name release];
}

BOOL CFEMessagesEqual(CFEMessage msg1, CFEMessage msg2) {
    return([msg1.name isEqualToString:msg2.name]);
}

#pragma mark CarFrontEnd Volume Messages
CFEMessage   CFEMessageVolumeMute =         {@"CFEMessageVolumeMute",       YES};
CFEMessage   CFEMessageVolumeSet =          {@"CFEMessageVolumeSet",        YES};
CFEMessage   CFEMessageVolumeChanged =      {@"CFEMessageVolumeChanged",    YES};

#pragma mark CarFrontEnd Menu Messages
CFEMessage   CFEMessageMenuShowView =       {@"CFEMessageMenuShowView",     YES};
CFEMessage   CFEMessageMenuHideApp =        {@"CFEMessageMenuHideApp",      YES};
CFEMessage   CFEMessageMenuQuitApp =        {@"CFEMessageMenuQuitApp",      YES};
CFEMessage   CFEMessageMenuSwapSide =       {@"CFEMessageMenuSwapSide",     YES};
CFEMessage   CFEMessageMenuSideSwapped =    {@"CFEMessageMenuSideSwapped",  YES};
