
//
//  MapCell.h
//  splendens
//
//  Created by Guilherme Souza on 10/23/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

@class Cell;

// Possible cell types
typedef enum {
	CellTypeEmpty,
	CellTypeWall,
	CellTypeBasic,
	CellTypeCity,
	CellTypeTower,
	CellTypeLab
} CellType;

// Possible neighbour cell relative position
typedef enum {
	CellPositionRight,
	CellPositionAbove,
	CellPositionLeft,
	CellPositionBellow,
} CellPosition;

#import <Foundation/Foundation.h>
#import <SpriteKit/SpriteKit.h>
#import "Player.h"
#import "GameScene.h"

@interface Cell : SKSpriteNode

@property (nonatomic, readonly) int x;
@property (nonatomic, readonly) int y;
@property (nonatomic) CellType type; // call updateOverlay to apply the change visually
@property (nonatomic) int population; // not used for empty and wall cells
@property (nonatomic) int level; // not used for empty, wall and basic cells
@property (nonatomic) Player* owner; // not used for empty and wall cells. nil means abandoned cell
@property (nonatomic) NSArray* cellsInRange; // Store all cells in the tower range (nil if the cell is not a range)
@property (nonatomic) BonusType bonus;

// Create a new empty cell with the given position
- (id)initWithX:(int)x y:(int)y size:(CGSize)size map:(Map*)map;

- (void) upgradeTo: (CellType)type;
- (void) upgrade;

- (void)setBonus:(BonusType)bonus;

// Hide the planned power overlay
// Called right before applying the powers
- (void)clearPowerOverlay;

// Force the texture update
- (void)updateOverlay;

// Cached textures
+ (SKTexture*)textureWithName:(NSString*)name;

// Return the relavite position beetween this cell and the given one
- (CellPosition)relativePositionToCell:(Cell*)cell;
- (float)relativeAngleToCell:(Cell*)cell;

// Return a random point near the center of this cell (used to place troops)
- (CGPoint)randomPointNear: (float) ratio;

// Return whether the cell is not empty nor a wall
- (BOOL)isCenter;

@end
