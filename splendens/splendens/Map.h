//
//  Map.h
//  splendens
//
//  Created by Guilherme Souza on 10/23/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "Cell.h"
#import "Player.h"
#import "Troop.h"

// The map size in points
#define MAP_SIZE 700.0

// The total animation time for troops movements
#define TOTAL_MOV_TIME 1.5

// The total animation time for tower attacks
#define TOTAL_ATTACK_TIME 1.5

// Represent the whole map, with all cells and troops
@interface Map : SKNode

@property (nonatomic) int size;
@property (nonatomic) NSArray* cells;
@property (nonatomic) NSArray* players;
@property (nonatomic) Cell* selected;
@property (nonatomic) Player* thisPlayer;
@property (nonatomic) NSArray* lastPath;


// Create a new map from a JSON string (see the structure in the project wiki)
- (id)initWithDefinition:(id)def;

// Return the cell at the given position
- (Cell*)cellAtX:(int)x y:(int)y;

// Return the cell at the given pixel position (relative to the map node)
- (Cell*)cellAtPixelX:(float)x pixelY:(float)y;

// Send a troop following the path
// The path must be valid (from a user cell and to another valid cell)
- (void)sendTroop:(NSArray*)path;

// Simulate each turn
- (void)processTurn;

@end
