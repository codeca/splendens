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
@property (nonatomic) int amount; // The current amount (displayed in the label)
@property (nonatomic) int newAmount; // The calculated final amount for this turn (decreases when attacked by towers)
@property (nonatomic) SKSpriteNode* node;

- (id)initWithPath:(NSArray*)path amount:(int)amount;

// Return the cell the troop is currently in
- (Cell*)currentCell;

// Set the amount and update the label
- (void)setAmount:(int)amount;

@end
