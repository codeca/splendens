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
#import "BottomPanel.h"

@interface Map()

@property (nonatomic) NSMutableArray* troops;

@end

@implementation Map

- (id)initWithDefinition:(id)def myId:(NSString *)myId game:(GameScene*)game {
	if (self = [super init]) {
		// Extract the size
		self.size = [def[@"size"] integerValue];
		self.name = @"map";
		
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
		NSArray* savedCells = def[@"cells"];
		for (NSDictionary* savedCell in savedCells) {
			int x = [savedCell[@"x"] integerValue];
			int y = [savedCell[@"y"] integerValue];
			Cell* cell = [self cellAtX:x y:y];
			cell.level = [savedCell[@"level"] integerValue];
			cell.type = [savedCell[@"type"] integerValue];
			cell.population = [savedCell[@"population"] integerValue];
			if (cell.type != CellTypeEmpty && cell.type != CellTypeWall) {
				id owner = savedCell[@"owner"];
				if (owner != [NSNull null])
					cell.owner = [game.players objectAtIndex:[owner integerValue]];
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

- (void)setSelected:(Cell *)selected {
	GameScene* game = (GameScene*)self.parent;
	_selected = selected;
	[game.bottomPanel update];
}

#pragma mark - main turn logic

- (void)processTurn {
	// Produce population and mana
	for (Cell* cell in self.cells) {
		if (!cell.owner)
			continue;
			
		int maxPop = [Economy maxPopulationForType:cell.type level:cell.level];
		
		if (cell.population >= maxPop)
			// Overcrowded -> lose half of the exceeding population
			cell.population -= (cell.population-maxPop+1)/2;
		
		if (cell.type == CellTypeBasic || cell.type == CellTypeCity) {
			if (cell.population < maxPop) {
				int newPop = cell.population + [Economy productionForType:cell.type level:cell.level];
				cell.population = newPop>maxPop ? maxPop : newPop;
			}
		} else if (cell.type == CellTypeLab){
			int newMana = cell.owner.mana + [Economy productionForType:cell.type level:cell.level];
			if (cell.owner.maxMana > newMana)cell.owner.mana = newMana;
			else cell.owner.mana = cell.owner.maxMana;
		}
	}
	GameScene* game = (GameScene*)self.parent;
	[game.bottomPanel update];
	
	//update totalPopulation after process population creation
	[game.topPanel updateTotalPopulation];
	
	//update MaxMana after upgrades
	[game.topPanel updateTotalPopulation];
	
	// Move troops
	NSArray* deliveredTroops = [self moveTroops];
	
	// Wait for the movement animation
	[NSTimer scheduledTimerWithTimeInterval:TOTAL_MOV_TIME target:self selector:@selector(processTowerAttacksAndTroopsDelivery:) userInfo:deliveredTroops repeats:NO];
}

// Process all attacks after a while
// timer.userInfo carries all delivered troops in this turn
- (void)processTowerAttacksAndTroopsDelivery:(NSTimer*)timer {
	BOOL towersAttacked = NO;
	
	for (Cell* cell in self.cells)
		if (cell.type == CellTypeTower)
			if ([self processTowerAttack:cell])
				towersAttacked = YES;
	
	[self processDeliveredTroops:timer.userInfo];
	GameScene* game = (GameScene*)self.parent;
	
	if (towersAttacked) {
		// Wait for tower attacks animation to end
		[NSTimer scheduledTimerWithTimeInterval:TOTAL_ATTACK_TIME target:self selector:@selector(updateTroopsAmount) userInfo:nil repeats:NO];
		[NSTimer scheduledTimerWithTimeInterval:TOTAL_ATTACK_TIME target:game selector:@selector(checkVictory) userInfo:nil repeats:NO];
	} else
		[game checkVictory];
}

// Process the attacks made by the given tower
// Return whether any troop was attacked
- (BOOL)processTowerAttack:(Cell*)tower {
	// Get all attackable troops
	NSMutableArray* troops = [NSMutableArray array];
	for (Troop* troop in self.troops)
		if ([tower.cellsInRange containsObject:[troop currentCell]] && troop.owner != tower.owner)
			[troops addObject:troop];
	
	// Order troops with this criteria
	GameScene* game = (GameScene*)self.parent;
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
		int iA = [game.players indexOfObject:a.owner];
		int iB = [game.players indexOfObject:b.owner];
		if (iA > iB) return NSOrderedAscending;
		else if (iA < iB) return NSOrderedDescending;
		return NSOrderedSame;
	}];
	
	// Attack troops
	int maxAttacks = [Economy attackSpeedForTowerLevel:tower.level];
	for (int i=0; i<maxAttacks && i<troops.count; i++) {
		Troop* troop = troops[i];
		int damage = [Economy attackDamageForTowerLevel:tower.level];
		if (damage >= troop.newAmount) {
			// Troop destroyed
			troop.newAmount = 0;
			
			// Create the "pop" animation
			SKAction* wait = [SKAction waitForDuration:TOTAL_ATTACK_TIME];
			SKAction* grow = [SKAction scaleTo:1.5 duration:TOTAL_ATTACK_TIME/2];
			SKAction* fade = [SKAction fadeOutWithDuration:TOTAL_ATTACK_TIME/2];
			SKAction* pop = [SKAction group:@[grow, fade]];
			SKAction* remove = [SKAction removeFromParent];
			[troop.node runAction:[SKAction sequence:@[wait, pop, remove]]];
		} else
			troop.newAmount -= damage;
		
		// Create the bullet
		SKSpriteNode* bullet = [SKSpriteNode spriteNodeWithImageNamed:@"beta"];
		bullet.colorBlendFactor = 1;
		bullet.color = tower.owner ? tower.owner.color : [UIColor grayColor];
		bullet.xScale = bullet.yScale = 0;
		bullet.zRotation = atan2(troop.finalPosition.y-tower.position.y, troop.finalPosition.x-tower.position.x);
		bullet.position = tower.position;
		[self addChild:bullet];
		
		// Create the bullet animation
		SKAction* move = [SKAction moveTo:troop.finalPosition duration:TOTAL_ATTACK_TIME];
		SKAction* grow = [SKAction scaleTo:1 duration:TOTAL_ATTACK_TIME/3];
		SKAction* delay = [SKAction scaleTo:1 duration:TOTAL_ATTACK_TIME/3];
		SKAction* shrink = [SKAction scaleTo:0 duration:TOTAL_ATTACK_TIME/3];
		SKAction* remove = [SKAction removeFromParent];
		SKAction* shoot = [SKAction group:@[[SKAction sequence:@[grow, delay, shrink]], move]];
		[bullet runAction:[SKAction sequence:@[shoot, remove]]];
	}
	
	return troops.count ? YES : NO;
}

// Update all the displayed troop amount to the calculated amount
// Called after all tower attack animations end
- (void)updateTroopsAmount {
	NSMutableArray* newTroops = [NSMutableArray array];
	for (Troop* troop in self.troops) {
		if (troop.amount != troop.newAmount)
			troop.amount = troop.newAmount;
		if (troop.amount)
			[newTroops addObject:troop];
	}
	self.troops = newTroops;
}

#pragma mark - troops

- (void)sendTroop:(NSArray *)path {
	Cell* firstCell = path[0];
	int amount = (firstCell.population+1)/2;
	firstCell.population -= amount;
	Troop* troop = [[Troop alloc] initWithPath:path amount:amount];
	[self.troops addObject:troop];
	[self addChild:troop.node];
	
	//update totalPopulation after send troops
	GameScene* game = (GameScene*) self.parent;
	[game.topPanel updateTotalPopulation];
}

// Move each troop and return all troops that got delivered in this turn
- (NSArray*)moveTroops {
	// Divide current troops into two arrays (delivered and non-delivered)
	NSMutableArray* deliveredTroops = [NSMutableArray array];
	NSMutableArray* walkingTroops = [NSMutableArray array];
	
	// Process each troop, collect all delivered ones
	for (Troop* troop in self.troops) {
		NSMutableArray* animations = [[NSMutableArray alloc] initWithCapacity:troop.speed];
		BOOL willArrive = NO;
		int steps = troop.speed;
		if (troop.path.count-troop.pos-1 <= troop.speed) {
			// The troop will be delivered
			[deliveredTroops addObject:troop];
			willArrive = YES;
			steps = troop.path.count-troop.pos-1;
		} else {
			// The troop will just move
			[walkingTroops addObject:troop];
		}
		
		// Move to each cell in the path
		for (int i=1; i<=steps; i++) {
			Cell* cell = troop.path[troop.pos+i];
			
			if (i == steps) {
				troop.finalPosition = willArrive ? cell.position : [cell randomPointNear: 0.75];
				SKAction* lastMove = [SKAction moveTo:troop.finalPosition duration:TOTAL_MOV_TIME/steps];
				if (willArrive) {
					// Arrive animation
					SKAction* vanish = [SKAction scaleTo:0 duration:TOTAL_MOV_TIME/steps];
					[animations addObject:[SKAction group:@[lastMove, vanish]]];
					[animations addObject:[SKAction removeFromParent]];
				} else
					[animations addObject:lastMove];
			} else
				[animations addObject:[SKAction moveTo:[cell randomPointNear:0.5] duration:TOTAL_MOV_TIME/steps]];
		}
		
		if (!willArrive) troop.pos += steps;
		[troop.node runAction:[SKAction sequence:animations]];
	}
	self.troops = walkingTroops;
	
	return deliveredTroops;
}

- (void)processDeliveredTroops:(NSArray*)troops {
	// Order troops (criteria defined in the project wiki)
	GameScene* game = (GameScene*)self.parent;
	troops = [troops sortedArrayUsingComparator:^(Troop* a, Troop* b) {
		// Nearest
		float timeA = (float)(a.path.count-a.pos)/a.speed;
		float timeB = (float)(b.path.count-b.pos)/b.speed;
		if (timeA < timeB) return NSOrderedAscending;
		else if (timeA > timeB) return NSOrderedDescending;
		
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
		int iA = [game.players indexOfObject:a.owner];
		int iB = [game.players indexOfObject:b.owner];
		if (iA > iB) return NSOrderedAscending;
		else if (iA < iB) return NSOrderedDescending;
		
		return NSOrderedSame;
	}];
	
	// Process each troop in order
	for (Troop* troop in troops) {
		Cell* destiny = [troop.path lastObject];
		int destinyArmor = [Economy armorForType:destiny.type level:destiny.level];
		
		if (troop.owner == destiny.owner) {
			// Reinforcement
			destiny.population += troop.amount;
		} else if (troop.amount > destiny.population*destinyArmor){
			// Attack resulted in conquest
			destiny.population = troop.amount - destiny.population*destinyArmor;
			destiny.owner = troop.owner;
		} else {
			// Attack failed (just reduce the cell population)
			destiny.population -= troop.amount/destinyArmor;
		}
		
		if (self.selected == destiny) {
			// Update the info about the cell displayed in the interface

			BottomPanel* bottomPanel = (BottomPanel*)[[self scene] childNodeWithName:@"bottomPanel"];
			[bottomPanel update];
		}
	}
	
	//update totalPopulation after attacks
	[game.topPanel updateTotalPopulation];
	
	//update maxMana after attacks
	[game.topPanel updateMaxMana];
}


@end
