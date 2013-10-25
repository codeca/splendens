//
//  Troop.h
//  splendens
//
//  Created by Guilherme Souza on 10/25/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Player.h"

@interface Troop : SKSpriteNode

@property (nonatomic) int speed;
@property (nonatomic) NSArray* path;
@property (nonatomic) int pos;
@property (nonatomic) Player* owner;
@property (nonatomic) int amount;

- (id)initWithPath:(NSArray*)path amount:(int)amount;

@end
