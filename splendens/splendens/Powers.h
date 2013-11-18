//
//  Powers.h
//  splendens
//
//  Created by Rodolfo Bitu on 12/11/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

@class Powers;

typedef enum {
	PowerInfect,
	PowerDowngrade,
	PowerClearMap,
	PowerNeutralize,
	PowerConquer,
	PowerNone
} PowerType;

#import <Foundation/Foundation.h>
#import "Cell.h"
#import "GameScene.h"

@interface Powers : NSObject

// Plan to apply a power to a cell owned by the current player
// The action must be valid
// This method also create a visual feedback for the user
// The visual feedback is a node (addded as a child of map) named "powerOverlay"
+ (void)planPower:(PowerType)type onCell:(Cell*)cell game:(GameScene*)game;

// Apply a given power in the given cell (the action must be valid)
+ (void)applyPower:(PowerType)type forPlayer:(Player*)player onCell:(Cell*)cell game:(GameScene*)game;

+ (NSArray*)powerNames;

@end
