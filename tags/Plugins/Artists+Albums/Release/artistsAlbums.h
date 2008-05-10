/*
 * CarFrontEnd - artistsAlbums.h - Alexander Bock (myself@alexander-bock.eu)
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

#import <Cocoa/Cocoa.h>
#import <CarFrontEndAPI/CarFrontEndAPI.h>


@interface ArtistsAlbums : NSObject <CarFrontEndProtocol> {
    id						owner;
    IBOutlet NSView			*ArtistsAlbumsView;
	IBOutlet NSScrollView	*list;
	IBOutlet NSButton		*btn;
	NSMutableDictionary		*music;
	int						level;
	int						selectedArtistIndex;
	int						selectedAlbumIndex;
	int						selectedSongIndex;
	NSString				*selectedArtist;
	NSString				*selectedAlbum;
	NSString				*selectedSong;

}

- (id) initWithPluginManager: (id) pluginManager;
- (NSString *) name;
- (void) initalize;
- (NSImage *) pluginButtonImage;
- (NSView *) contentViewForSize: (NSSize) size;
- (void) removePluginFromView;
- (int)numberOfRowsInTableView:(NSTableView *)tableView; 
- (id)tableView:(NSTableView *)tableView
      objectValueForTableColumn:(NSTableColumn *)tableColumn
      row:(int)row; 
- (IBAction)tableViewSelected:(id)sender;

@end
