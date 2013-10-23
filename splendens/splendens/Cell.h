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

typedef enum {
	CellTypeEmpty,
	CellTypeWall,
	CellTypeBasic,
	CellTypeCity,
	CellTypeTower,
	CellTypeLab
} CellType;

@interface Cell : NSObject

@property (nonatomic) int x;
@property (nonatomic) int y;
@property (nonatomic) CellType type;
@property (nonatomic) int population;
@property (nonatomic) int level;
@property (nonatomic) Player* owner;
@property (nonatomic) SKSpriteNode* node;

- (id)initWithX:(int)x y:(int)y;

@end
