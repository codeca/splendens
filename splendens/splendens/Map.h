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

#define MAP_SIZE 700.0

// Represent the whole map, with all cells and troops
@interface Map : SKNode

@property (nonatomic) int size;
@property (nonatomic) NSArray* cells;
@property (nonatomic) NSArray* players;
@property (nonatomic) Cell* selected;
@property (nonatomic) Player* thisPlayer;


// Create a new map from a JSON string (see the structure in the project wiki)
- (id)initWithDefinition:(NSString*)def;

// Return the cell at the given position
- (Cell*)cellAtX:(int)x y:(int)y;

// Return the cell at the given pixel position (relative to the map node)
- (Cell*)cellAtPixelX:(float)x pixelY:(float)y;

@end
