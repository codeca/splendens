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
		for (NSDictionary* savedPlayer in savedPlayers) {
			Player* player = [[Player alloc] init];
			player.mana = [[savedPlayer objectForKey:@"mana"] integerValue];
			[players addObject:player];
		}
		self.players = players;
		
		// Create each cell
		NSMutableArray* cells = [[NSMutableArray alloc] initWithCapacity:self.size*self.size];
		for (int y=0; y<self.size; y++) {
			for (int x=0; x<self.size; x++) {
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
		
		// Create the node tree
		[self createNodeTree];
	}
	return self;
}

- (Cell*)cellAtX:(int)x y:(int)y {
	return [self.cells objectAtIndex:y*self.size+x];
}

- (void)createNodeTree {
	// Create the root node
	self.node = [SKNode node];
	self.node.position = CGPointMake((768-MAP_SIZE)/2, (1024-MAP_SIZE)/2);
	
	// Create each cell node
	for (Cell* cell in self.cells)
		[self updateSpriteForCell:cell];
}

- (void)updateSpriteForCell:(Cell*)cell {
	// Remove previous sprite
	if (cell.node)
		[cell.node removeFromParent];
	
	// Choose the right color
	UIColor* color;
	switch (cell.type) {
		case CellTypeEmpty: color = [UIColor clearColor]; break;
		case CellTypeWall: color = [UIColor whiteColor]; break;
		case CellTypeBasic: color = [UIColor grayColor]; break;
		case CellTypeCity: color = [UIColor greenColor]; break;
		case CellTypeTower: color = [UIColor redColor]; break;
		case CellTypeLab: color = [UIColor blueColor]; break;
	}
	
	// Create basic sprite
	float cellSize = MAP_SIZE/self.size;
	cell.node = [SKSpriteNode spriteNodeWithColor:color size:CGSizeMake(cellSize, cellSize)];
	cell.node.position = CGPointMake(cell.x*cellSize+cellSize/2, cell.y*cellSize+cellSize/2);
	[self.node addChild:cell.node];
	
	// Debug label
	SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:@"arial"];
	label.text = [NSString stringWithFormat:@"(%d, %d)", cell.x, cell.y];
	[cell.node addChild:label];
}

@end
