//
//  Map.m
//  splendens
//
//  Created by Guilherme Souza on 10/23/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "Map.h"

@implementation Map

- (id)initWithDefinition:(id)def {
	if (self = [super init]) {
		// Extract the size
		self.size = [[def objectForKey:@"size"] integerValue];
		
		// Extract all players
		int numPlayers = [[def objectForKey:@"players"] integerValue];
		int mana = [[def objectForKey:@"mana"] integerValue];
		NSMutableArray* players = [[NSMutableArray alloc] initWithCapacity:numPlayers];
		NSArray* colors = @[[UIColor redColor], [UIColor greenColor], [UIColor blueColor], [UIColor whiteColor]];
		for (int i=0; i<numPlayers; i++) {
			Player* player = [[Player alloc] init];
			player.mana = mana;
			player.color = colors[i];
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
		NSArray* savedCells = [def objectForKey:@"cells"];
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
	if (x<0 || y<0 || x>=self.size || y>=self.size) return nil;
	return [self.cells objectAtIndex:y*self.size+x];
}

- (Cell*)cellAtPixelX:(float)pX pixelY:(float)pY {
	int x = pX/(MAP_SIZE/self.size);
	int y = pY/(MAP_SIZE/self.size);
	return [self cellAtX:x y:y];
}

@end
