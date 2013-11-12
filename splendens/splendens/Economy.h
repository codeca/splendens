//
//  Economy.h
//  splendens
//
//  Created by Guilherme Souza on 10/24/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

@class Economy;

#import <Foundation/Foundation.h>
#import "Cell.h"
#import "Powers.h"

@interface Economy : NSObject

// Static methods to return values for the game economy

+ (int)productionForType:(CellType)type level:(int)level;
+ (int)maxPopulationForType:(CellType)type level:(int)level;
+ (int)speedForType:(CellType)type level:(int)level;
+ (int)armorForType:(CellType)type level:(int)level;
+ (int)attackSpeedForTowerLevel:(int)level;
+ (int)attackDamageForTowerLevel:(int)level;
+ (int)attackRangeForTowerLevel:(int)level;
+ (int)bonusMaxManaForLabLevel:(int)level;
+ (int)upgradePopulationCostForType:(CellType)type level:(int)level;
+ (int)upgradeManaCostForType:(CellType)type level:(int)level;
+ (int)manaCostForPower:(PowerType)type;

// Return the value taking into account the owner bonus
+ (int)productionForCell:(Cell*)cell;
+ (int)armorForCell:(Cell*)cell;
+ (int)speedForCell:(Cell*)cell;

@end
