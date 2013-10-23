//
//  Map.m
//  splendens
//
//  Created by Guilherme Souza on 10/23/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "Map.h"

@implementation Map

- (id)initWithDefinition:(NSString *)def {
	if (self = [super init]) {
		// Inflate the JSON
		NSError* error = nil;
		NSData* defData = [def dataUsingEncoding:NSUTF8StringEncoding];
		NSDictionary* obj = [NSJSONSerialization JSONObjectWithData:defData options:0 error:&error];
		
		// Check the result
		if (error)
			@throw error;
		
		// Extract the size
		self.width = [[obj objectForKey:@"width"] integerValue];
		self.height = [[obj objectForKey:@"height"] integerValue];
		
		// Extract all players
		NSArray* savedPlayers = [obj objectForKey:@"players"];
		NSMutableArray* players = [[NSMutableArray alloc] initWithCapacity:savedPlayers.count];
		for (NSDictionary* savedPlayer in savedPlayers) {
			Player* player = [[Player alloc] init];
			player.mana = [[savedPlayer objectForKey:@"mana"] integerValue];
			[players addObject:player];
		}
		self.players = players;
		
		// Create each cell
		NSMutableArray* cells = [[NSMutableArray alloc] initWithCapacity:self.width*self.height];
		for (int y=0; y<self.height; y++) {
			for (int x=0; x<self.width; x++) {
				Cell* cell = [[Cell alloc] initWithX:x y:y];
				[cells addObject:cell];
			}
		}
		self.cells = cells;
		
		// Update each cell to the saved type
		NSArray* savedCells = [obj objectForKey:@"cells"];
		for (NSDictionary* savedCell in savedCells) {
			int x = [[savedCell objectForKey:@"x"] integerValue];
			int y = [[savedCell objectForKey:@"y"] integerValue];
			Cell* cell = [self cellAtX:x y:y];
			cell.type = [[savedCell objectForKey:@"type"] integerValue];
			cell.population = [[savedCell objectForKey:@"population"] integerValue];
			cell.level = [[savedCell objectForKey:@"level"] integerValue];
			if (cell.type != CellTypeEmpty && cell.type != CellTypeWall)
				cell.owner = [players objectAtIndex:[[savedCell objectForKey:@"owner"] integerValue]];
		}
		
	}
	return self;
}

- (Cell*)cellAtX:(int)x y:(int)y {
	return [self.cells objectAtIndex:y*self.width+x];
}

@end
