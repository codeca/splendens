//
//  Player.h
//  splendens
//
//  Created by Guilherme Souza on 10/23/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

@class Player;

#import <Foundation/Foundation.h>
#import "GameScene.h"

@interface Player : NSObject

@property (nonatomic) int mana;
@property (nonatomic) int maxMana;
@property (nonatomic) NSString* name;
@property (nonatomic) NSString* playerId;
@property (nonatomic) UIColor* color;
@property (nonatomic) int totalPopulation;
@property (nonatomic) BOOL disconnected;
@property (nonatomic) BonusType bonus;
@property (nonatomic) int bonusTimeLeft;
@property (nonatomic, weak) GameScene* game;
@property (nonatomic) int level;

// Store all used powers by the current player in this turn
@property (nonatomic) NSMutableArray* usedPowers;

// Get the local player level
+ (int)level;

// Stats for level mechanics
+ (int)neededWins;
+ (int)currentWins;

// Update the stats because the local player won
// Return whether the player leveled-up
+ (BOOL)saveWin;

// Return the total number of powers the player can use
+ (int)numAvailablePowers;

- (void)setBonus:(BonusType)bonus;

@end
