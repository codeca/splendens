//
//  Troop.h
//  splendens
//
//  Created by Guilherme Souza on 10/25/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Player.h"
#import "Cell.h"

@interface Troop : NSObject 

@property (nonatomic) int speed;
@property (nonatomic) NSArray* path;
@property (nonatomic) int pos;
@property (nonatomic) Player* owner;
@property (nonatomic) int amount;
@property (nonatomic) SKSpriteNode* node;

- (id)initWithPath:(NSArray*)path amount:(int)amount;

// Return the cell the troop is currently in
- (Cell*)currentCell;

@end
