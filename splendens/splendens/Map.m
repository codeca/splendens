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
		self.size = [[obj objectForKey:@"size"] integerValue];
		
		// Extract all players
		NSArray* savedPlayers = [obj objectForKey:@"players"];
		NSMutableArray* players = [[NSMutableArray alloc] initWithCapacity:savedPlayers.count];
		NSArray* colors = @[[UIColor redColor], [UIColor greenColor], [UIColor blueColor], [UIColor whiteColor]];
		int i = 0;
		for (NSDictionary* savedPlayer in savedPlayers) {
			Player* player = [[Player alloc] init];
			player.mana = [[savedPlayer objectForKey:@"mana"] integerValue];
			player.color = colors[i++];
			[players addObject:player];
		}
		self.players = players;
		
		// Create root node
		self.position = CGPointMake((768-MAP_SIZE)/2, (1024-MAP_SIZE)/2);
		
		// Create each cell
		float cellSize = MAP_SIZE/self.size;
		NSMutableArray* cells = [[NSMutableArray alloc] initWithCapacity:self.size*self.size];
		for (int y=0; y<self.size; y++) {
			for (int x=0; x<self.size; x++) {
				Cell* cell = [[Cell alloc] initWithX:x y:y size:CGSizeMake(cellSize, cellSize)];
				cell.position = CGPointMake(x*cellSize+cellSize/2, y*cellSize+cellSize/2);
				[cells addObject:cell];
				[self addChild:cell];
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
			if (cell.type != CellTypeEmpty && cell.type != CellTypeWall) {
				id owner = [savedCell objectForKey:@"owner"];
				if (owner != [NSNull null])
					cell.owner = [players objectAtIndex:[owner integerValue]];
			}
		}
	}
	return self;
}

- (Cell*)cellAtX:(int)x y:(int)y {
	return [self.cells objectAtIndex:y*self.size+x];
}

- (Cell*)cellAtPixelX:(float)pX pixelY:(float)pY {
	int x = pX/(MAP_SIZE/self.size);
	int y = pY/(MAP_SIZE/self.size);
	return [self cellAtX:x y:y];
}

@end
