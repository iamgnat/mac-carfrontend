/*
 * CarFrontEnd - artistsAlbums.m - Alexander Bock (myself@alexander-bock.eu)
 * Copyright (C) 2008  Alexander Bock (myself@alexander-bock.eu)
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

#import "artistsAlbums.h"

static ArtistsAlbums *sharedSP = nil;

@implementation ArtistsAlbums

- (id) init {
    return([self initWithPluginManager:nil]);
}

- (id) initWithPluginManager: (id) pluginManager {
    if (sharedSP != nil) {
        [self release];
        return(sharedSP);
    }
    
    [super init];
    owner = [pluginManager retain];
    
    // Setup for a single instance.
    sharedSP = self;
    
    return(self);
}

- (NSString *) name {
    return(@"Artists&Albums");
}

- (void) initalize {
    // No-op for this example.
    //  Should generate the button image here rather than on demand.
}

- (NSImage *) pluginButtonImage {
        NSMutableDictionary *attributes = [NSMutableDictionary dictionary];
    
    [attributes setObject:[NSFont fontWithName:@"Helvetica" size:26]
                   forKey:NSFontAttributeName];
        [attributes setObject:[NSColor whiteColor]
                   forKey:NSForegroundColorAttributeName];
    
    NSSize          size = [[self name] sizeWithAttributes:attributes];
    NSImage         *image = [[[NSImage alloc] initWithSize:size] autorelease];
    
    [image lockFocus];
    [[self name] drawAtPoint:NSZeroPoint withAttributes:attributes];
    [image unlockFocus];
    
    return(image);
}

- (NSView *) contentViewForSize: (NSSize) size {
    // We are ignoring the size value, but it is there incase you have differnt
    //  views based on the size that CarFrontEnd sends you.
    if (ArtistsAlbumsView == nil) {
        [NSBundle loadNibNamed:@"aaview" owner:self];
    }
	return(ArtistsAlbumsView);
}

- (void) removePluginFromView {
}

- (IBAction)tableViewSelected:(id)sender{
    int row = [sender selectedRow];
    //NSLog(@"the user just clicked on row %d", row);	
	if ((level == 1 || level == 2) && (row == 0)) { // back button
		level--;	
		[sender reloadData];
		if (level == 0)
			[sender scrollRowToVisible:selectedArtistIndex];
		else if (level == 1)			
			[sender scrollRowToVisible:(selectedAlbumIndex + 2)];
		return;
	}
	if (row == 1 && level != 0) { // play all button
		if (level == 1) {		// play all from this artist	
			NSDictionary *error = nil;
			NSAppleScript *createPlaylist;
			createPlaylist = [[NSAppleScript alloc] initWithSource:@"tell application \"iTunes\"\nif exists (playlist \"Artists&Albums\") then\ndelete playlist \"Artists&Albums\"\nend if\nset aaPlaylist to make new playlist with properties {name:\"Artists&Albums\"}\nend tell"];
			
			if (![createPlaylist executeAndReturnError:&error]) {
				NSLog(@"aa: createplaylist: %@",
					[error objectForKey:@"NSAppleScriptErrorMessage"]);
			}
			NSDictionary *albums = [music objectForKey:selectedArtist];
			int i;
			for (id k in albums) {
				NSMutableDictionary *songs = [[NSMutableDictionary alloc] init];
				[songs setDictionary:[[music objectForKey:selectedArtist] objectForKey:k]];
				for (i = 0; i <= [songs count]; i++) {
					NSAppleScript *addSongs;
					addSongs = [[NSAppleScript alloc]
						initWithSource:[NSString 
							stringWithFormat:@"tell application \"iTunes\"\nduplicate (every track of library playlist 1 whose (artist is \"%@\" and album is \"%@\" and name is \"%@\")) to playlist \"Artists&Albums\"\nend tell",
							selectedArtist, k, [songs objectForKey:[[NSNumber numberWithInt:(i)] stringValue]]]];
					if (![addSongs executeAndReturnError:&error]) {
						NSLog(@"aa: addSongs: %@",
							[error objectForKey:@"NSAppleScriptErrorMessage"]);
					}		
					//NSLog([NSString stringWithFormat:@"tell application \"iTunes\"\nduplicate (every track of library playlist 1 whose (artist is \"%@\" and album is \"%@\" and name is \"%@\")) to playlist \"Artists&Albums\"\nend tell", selectedArtist, k, [songs objectForKey:[[NSNumber numberWithInt:(i)] stringValue]]]);	
				}
			}
			NSAppleScript *playScript;
			playScript = [[NSAppleScript alloc] initWithSource:@"tell application \"iTunes\" to play playlist \"Artists&Albums\""];
			[playScript executeAndReturnError:nil];
			
		} else if (level == 2) { // play all from this album
			NSDictionary *error = nil;
			NSAppleScript *createPlaylist;
			createPlaylist = [[NSAppleScript alloc] initWithSource:@"tell application \"iTunes\"\nif exists (playlist \"Artists&Albums\") then\ndelete playlist \"Artists&Albums\"\nend if\nset aaPlaylist to make new playlist with properties {name:\"Artists&Albums\"}\nend tell"];
			
			if (![createPlaylist executeAndReturnError:&error]) {
				NSLog(@"aa: createplaylist: %@",
					[error objectForKey:@"NSAppleScriptErrorMessage"]);
			}
			int i;

			NSMutableDictionary *songs = [[NSMutableDictionary alloc] init];
			[songs setDictionary:[[music objectForKey:selectedArtist] objectForKey:selectedAlbum]];
			for (i = 0; i <= [songs count]; i++) {
				NSAppleScript *addSongs;
				addSongs = [[NSAppleScript alloc]
					initWithSource:[NSString 
						stringWithFormat:@"tell application \"iTunes\"\nduplicate (every track of library playlist 1 whose (artist is \"%@\" and album is \"%@\" and name is \"%@\")) to playlist \"Artists&Albums\"\nend tell",
						selectedArtist, selectedAlbum, [songs objectForKey:[[NSNumber numberWithInt:(i)] stringValue]]]];
				if (![addSongs executeAndReturnError:&error]) {
					NSLog(@"aa: addSongs: %@",
						[error objectForKey:@"NSAppleScriptErrorMessage"]);
				}		
				//NSLog([NSString stringWithFormat:@"tell application \"iTunes\"\nduplicate (every track of library playlist 1 whose (artist is \"%@\" and album is \"%@\" and name is \"%@\")) to playlist \"Artists&Albums\"\nend tell", selectedArtist, selectedAlbum, [songs objectForKey:[[NSNumber numberWithInt:(i)] stringValue]]]);	
			}			
			NSAppleScript *playScript;
			playScript = [[NSAppleScript alloc] initWithSource:@"tell application \"iTunes\" to play playlist \"Artists&Albums\""];
			[playScript executeAndReturnError:nil];
		}
		return;
	}
	if (level == 0) {
		NSMutableArray *artists = [[NSMutableArray alloc] init];
		[artists addObjectsFromArray:[music allKeys]];
		[artists sortUsingSelector: @selector( caseInsensitiveCompare: )];
		//NSLog(@"k = %@", [artists objectAtIndex:row]);
		selectedArtist = [artists objectAtIndex:row];
		selectedArtistIndex = row;
		level = 1;
		[sender reloadData];
	} else if (level == 1) {
		NSMutableArray *albums = [[NSMutableArray alloc] init];
		[albums addObjectsFromArray:[[music objectForKey:selectedArtist] allKeys]];
		[albums sortUsingSelector: @selector( caseInsensitiveCompare: )];
		//NSLog(@"k = %@", [artists objectAtIndex:row]);
		selectedAlbum = [albums objectAtIndex:(row - 2)];
		selectedAlbumIndex = row - 2;	
		level = 2;
		[sender reloadData];		
	} else if (level == 2) { //play all from this album, but start with this song
		NSDictionary *error = nil;
		NSAppleScript *createPlaylist;
		createPlaylist = [[NSAppleScript alloc] initWithSource:@"tell application \"iTunes\"\nif exists (playlist \"Artists&Albums\") then\ndelete playlist \"Artists&Albums\"\nend if\nset aaPlaylist to make new playlist with properties {name:\"Artists&Albums\"}\nend tell"];
		
		if (![createPlaylist executeAndReturnError:&error]) {
			NSLog(@"aa: createplaylist: %@",
				[error objectForKey:@"NSAppleScriptErrorMessage"]);
		}
		int i;
		NSMutableDictionary *songs = [[NSMutableDictionary alloc] init];
		[songs setDictionary:[[music objectForKey:selectedArtist] objectForKey:selectedAlbum]];
		for (i = 0; i <= [songs count]; i++) {
			NSAppleScript *addSongs;
			addSongs = [[NSAppleScript alloc]
				initWithSource:[NSString 
					stringWithFormat:@"tell application \"iTunes\"\nduplicate (every track of library playlist 1 whose (artist is \"%@\" and album is \"%@\" and name is \"%@\")) to playlist \"Artists&Albums\"\nend tell",
					selectedArtist, selectedAlbum, [songs objectForKey:[[NSNumber numberWithInt:(i)] stringValue]]]];
			if (![addSongs executeAndReturnError:&error]) {
				NSLog(@"aa: addSongs: %@",
					[error objectForKey:@"NSAppleScriptErrorMessage"]);
			}		
			//NSLog([NSString stringWithFormat:@"tell application \"iTunes\"\nduplicate (every track of library playlist 1 whose (artist is \"%@\" and album is \"%@\" and name is \"%@\")) to playlist \"Artists&Albums\"\nend tell", selectedArtist, selectedAlbum, [songs objectForKey:[[NSNumber numberWithInt:(i)] stringValue]]]);	
		}			
		NSAppleScript *playScript;
		playScript = [[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:@"tell application \"iTunes\" to play (some track of user playlist \"Artists&Albums\" whose name is \"%@\")", 
			[songs objectForKey:[[NSNumber numberWithInt:(row - 1)] stringValue] ]]];
		[playScript executeAndReturnError:nil];
	}
}

- (int)numberOfRowsInTableView:(NSTableView *)tableView {
	
	if (level == nil) 
		level = 0;

    if (level == 0) {
		//NSLog(@"getting ");
		if (music != nil)
			return [music count];
			
		NSDictionary    *its = [NSDictionary dictionaryWithContentsOfFile:[@"~/Music/iTunes/iTunes Music Library.xml" stringByExpandingTildeInPath]];
		//NSLog(@"Class = %@", [its class]);
		//NSLog(@"desc = %@", its);
		NSDictionary *tracks = (NSDictionary *)[its objectForKey: @"Tracks"];
		NSDictionary *track;
		music = [NSMutableDictionary new];
		id key; 
		NSString *artist;
		NSString *album;
		NSString *title;
		NSString *tracknumber;
		int hours;
		int minutes;
		int seconds;
		for (key in tracks) {
			track = [tracks objectForKey:key];
			/*for (id k in track){
				NSLog(@"key: %@ (%d), value: %@ (%d)", k, k, [track objectForKey:k], [track objectForKey:k]);
			}*/
			artist = [track objectForKey:@"Artist"];
			if (artist == nil) 
				artist = @"(No Artist)";
			
			album = [track objectForKey:@"Album"];
			if (album == nil) 
				album = @"(No Album)";
		
			title = [track objectForKey:@"Name"];
			if (title == nil) 
				title = @"(No Title)";
		
			hours = (int)[[track objectForKey:@"Total Time"] integerValue]/1000/3600;
			minutes = (int)([[track objectForKey:@"Total Time"] integerValue]/1000 
					- 3600*hours)/60;
			seconds = (int)([[track objectForKey:@"Total Time"] integerValue]/1000 
					- 3600*hours - 60*minutes);
			tracknumber = [[track objectForKey:@"Track Number"] stringValue];
			//NSLog(@"zeit: %i %i %i", hours, minutes, seconds); 
			NSMutableDictionary *mdArtist = [NSMutableDictionary new];
			NSMutableDictionary *mdAlbum = [NSMutableDictionary new];
			if ([music objectForKey:artist] != nil) {
				[mdArtist setDictionary:[music objectForKey:artist]];
			}
			if ([mdArtist objectForKey:album] != nil) {
				[mdAlbum setDictionary:[mdArtist objectForKey:album]];
			}
			if (tracknumber == nil) {
				//NSLog(@"no album number for %@ %@ (%@)", artist, title, [NSNumber numberWithUnsignedInteger:[mdAlbum count]]);
				if ([mdAlbum count] > 0) {
					//NSLog(@"setting number %@ for %@ %@", [NSNumber numberWithUnsignedInteger:[mdAlbum count]], artist, title);
					tracknumber = [[NSNumber numberWithUnsignedInteger:([mdAlbum count] + 1)] stringValue];
				} else {
					//NSLog(@"setting number 1 for %@ %@", artist, title);
					tracknumber = @"1";
				}
			}
			[mdAlbum setValue:title forKey:tracknumber];
			[mdArtist setObject:mdAlbum forKey:album];
			[music setObject:mdArtist forKey:artist];
			
		}	
		return [music count];
	} else if (level == 1) {
		return [[music objectForKey:selectedArtist] count] + 2;
	} else if (level == 2) {
		return [[[music objectForKey:selectedArtist] objectForKey:selectedAlbum] count] + 2;
	} else
		return 0;
}

- (id)tableView:(NSTableView *)tableView
      objectValueForTableColumn:(NSTableColumn *)tableColumn
      row:(int)row {
	if (level == 0) {
		NSMutableArray *artists = [[NSMutableArray alloc] init];
		[artists addObjectsFromArray:[music allKeys]];
		[artists sortUsingSelector: @selector( caseInsensitiveCompare: )];
		//NSLog(@"k = %@", [artists objectAtIndex:row]);
		return [artists objectAtIndex:row];
	} else if (level == 1) {
		if (row == 0) 
			return @"<- back";
		if (row == 1) 
			return @"Play all";
		NSMutableArray *albums = [[NSMutableArray alloc] init];
		[albums addObjectsFromArray:[[music objectForKey:selectedArtist] allKeys]];
		[albums sortUsingSelector: @selector( caseInsensitiveCompare: )];
		//NSLog(@"k = %@", [artists objectAtIndex:row]);
		return [albums objectAtIndex:(row - 2)];	
	} else if (level == 2) {
		if (row == 0) 
			return @"<- back";
		if (row == 1) 
			return @"Play all";
		NSMutableDictionary *songs = [[NSMutableDictionary alloc] init];
		[songs setDictionary:[[music objectForKey:selectedArtist] objectForKey:selectedAlbum]];
		//[songs sortUsingSelector: @selector( caseInsensitiveCompare: )];
		//NSLog(@"k = %@", [artists objectAtIndex:row]);
		return [songs objectForKey:[[NSNumber numberWithInt:(row - 1)] stringValue] ];	
	} else
		return @"N/A";
}


@end
