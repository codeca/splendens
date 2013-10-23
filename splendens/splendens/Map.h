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

// Represent the whole map, with all centers and troops
@interface Map : NSObject

@property (nonatomic) int size;
@property (nonatomic) NSArray* cells;
@property (nonatomic) NSArray* players;
@property (nonatomic) SKNode* node;

- (id)initWithDefinition:(NSString*)def;

- (Cell*)cellAtX:(int)x y:(int)y;

- (void)updateSpriteForCell:(Cell*)cell;

@end
