//
//  Map.m
//  splendens
//
//  Created by Guilherme Souza on 10/23/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "Map.h"
#import "Troop.h"
#import "Economy.h"

@interface Map()

@property (nonatomic) NSMutableArray* troops;

@end

@implementation Map

- (id)initWithDefinition:(id)def {
	if (self = [super init]) {
		// Extract the size
		self.size = [[def objectForKey:@"size"] integerValue];
		self.name = @"map";
		
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
		self.thisPlayer = players[0];
		
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
			cell.level = [[savedCell objectForKey:@"level"] integerValue];
			cell.type = [[savedCell objectForKey:@"type"] integerValue];
			cell.population = [[savedCell objectForKey:@"population"] integerValue];
			if (cell.type != CellTypeEmpty && cell.type != CellTypeWall) {
				id owner = [savedCell objectForKey:@"owner"];
				if (owner != [NSNull null])
					cell.owner = [players objectAtIndex:[owner integerValue]];
			}
		}
		
		// Update all cells sprites
		for (Cell* cell in self.cells)
			[cell updateOverlay];
		
		self.troops = [NSMutableArray array];
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

#pragma mark - main turn logic

- (void)processTurn {
	// Produce population and mana
	for (Cell* cell in self.cells) {
		if (!cell.owner)
			continue;
		if (cell.type == CellTypeBasic || cell.type == CellTypeCity) {
			int maxPop = [Economy maxPopulationForType:cell.type level:cell.level];
			if (cell.population >= maxPop)
				cell.population -= (cell.population-maxPop+1)/2;
			else {
				int newPop = cell.population + [Economy productionForType:cell.type level:cell.level];
				newPop = newPop>maxPop ? maxPop : newPop;
				cell.population = newPop;
			}
		} else if (cell.type == CellTypeLab)
			cell.owner.mana += [Economy productionForType:cell.type level:cell.level];
	}
	
	// Move troops
	NSArray* deliveredTroops = [self moveTroops];
	
	// Tower attacks
	for (Cell* cell in self.cells)
		if (cell.type == CellTypeTower)
			[self processTowerAttack:cell];
	
	// Delivered troops
	[self processDeliveredTroops:deliveredTroops];
}

// Process the attacks made by the given tower
- (void)processTowerAttack:(Cell*)tower {
	// Get all attackable troops
	NSMutableArray* troops = [NSMutableArray array];
	for (Troop* troop in self.troops)
		if ([tower.cellsInRange containsObject:[troop currentCell]])
			[troops addObject:troop];
	
	// Order troops with this criteria
	[troops sortUsingComparator:^(Troop* a, Troop* b) {
		Cell* cellA = [a currentCell];
		Cell* cellB = [b currentCell];
		
		// Nearest
		int distA = abs(cellA.x-tower.x)+abs(cellA.y-tower.y);
		int distB = abs(cellB.x-tower.x)+abs(cellB.y-tower.y);
		if (distA < distB) return NSOrderedAscending;
		else if (distA > distB) return NSOrderedDescending;
		
		// Fastest
		if (a.speed > b.speed) return NSOrderedAscending;
		else if (a.speed < b.speed) return NSOrderedDescending;
		
		// Largest
		if (a.amount > b.amount) return NSOrderedAscending;
		else if (a.amount < b.amount) return NSOrderedDescending;
		
		// Farthest from origin
		if (a.pos > b.pos) return NSOrderedAscending;
		else if (a.pos < b.pos) return NSOrderedDescending;
		
		// Player with more mana
		if (a.owner.mana > b.owner.mana) return NSOrderedAscending;
		else if (a.owner.mana < b.owner.mana) return NSOrderedDescending;
		
		// Player order in the map.players array
		int iA = [self.players indexOfObject:a.owner];
		int iB = [self.players indexOfObject:b.owner];
		if (iA > iB) return NSOrderedAscending;
		else if (iA < iB) return NSOrderedDescending;
		return NSOrderedSame;
	}];
	
	// Attack troops
	int maxAttacks = [Economy attackSpeedForType:tower.type level:tower.level];
	for (int i=0; i<maxAttacks && i<troops.count; i++) {
		Troop* troop = troops[i];
		int damage = [Economy attackDamageForType:tower.type level:tower.level];
		if (damage >= troop.amount) {
			[self.troops removeObject:troop];
			[troop.node removeFromParent];
		} else {
			troop.amount -= damage;
			((SKLabelNode*)troop.node.children[0]).text = [NSString stringWithFormat:@"%d", troop.amount];
		}
	}
}

#pragma mark - troops

- (void)sendTroop:(NSArray *)path {
	Cell* firstCell = path[0];
	int amount = (firstCell.population+1)/2;
	firstCell.population -= amount;
	Troop* troop = [[Troop alloc] initWithPath:path amount:amount];
	[self.troops addObject:troop];
	[self addChild:troop.node];
}

// Move each troop and return all troops that got delivered in this turn
- (NSArray*)moveTroops {
	NSMutableArray* deliveredTroops = [NSMutableArray array];
	NSMutableArray* newTroops = [NSMutableArray array];
	
	// Process each troop, collect all delivered ones
	for (Troop* troop in self.troops) {
		NSMutableArray* animations = [[NSMutableArray alloc] initWithCapacity:troop.speed];
		
		for (int i=1; i<=troop.speed && troop.pos+i<troop.path.count-1; i++) {
			// Move for each cell
			Cell* cell = troop.path[troop.pos+i];
			SKAction* action = [SKAction moveTo:[cell randomPointNear:.25] duration:.25];
			[animations addObject:action];
		}
		
		troop.pos += troop.speed;
		
		if (troop.pos >= troop.path.count-1) {
			// Reached the final destinations
			Cell* cell = troop.path.lastObject;
			SKAction* lastMove = [SKAction moveTo:cell.position duration:.25];
			SKAction* vanish = [SKAction scaleTo:0 duration:.5];
			SKAction* remove = [SKAction removeFromParent];
			[animations addObject:[SKAction group:@[lastMove, vanish, remove]]];
			[deliveredTroops addObject:troop];
		} else
			[newTroops addObject:troop];
		
		[troop.node runAction:[SKAction sequence:animations]];
	}
	self.troops = newTroops;
	
	return deliveredTroops;
}

- (void)processDeliveredTroops:(NSArray*)troops {
	NSLog(@"delivered!");
}

@end
