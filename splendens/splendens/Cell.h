//
//  MapCell.h
//  splendens
//
//  Created by Guilherme Souza on 10/23/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "Player.h"

// Possible cell types
typedef enum {
	CellTypeEmpty,
	CellTypeWall,
	CellTypeBasic,
	CellTypeCity,
	CellTypeTower,
	CellTypeLab
} CellType;

@interface Cell : SKSpriteNode

@property (nonatomic, readonly) int x;
@property (nonatomic, readonly) int y;
@property (nonatomic) CellType type;
@property (nonatomic) int population; // not used for empty and wall cells
@property (nonatomic) int level; // not used for empty, wall and basic cells
@property (nonatomic) Player* owner; // not used for empty and wall cells. nil means abandoned cell


// Create a new empty cell with the given position
- (id)initWithX:(int)x y:(int)y size:(CGSize)size;
- (void) upgradeTo: (CellType)type;
- (void) upgrade;

// Cached textures
+ (SKTexture*)textureWithName:(NSString*)name;

// Return a random point near the center of this cell (used to place troops)
- (CGPoint)randomPointNear;

@end
