//
//  Powers.m
//  splendens
//
//  Created by Rodolfo Bitu on 12/11/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "Powers.h"
#import "Economy.h"

@implementation Powers

+ (void)planPower:(PowerType)type onCell:(Cell *)cell game:(GameScene*)game {
	NSDictionary* data = @{@"type": [NSNumber numberWithInt:TurnActionPower],
						   @"x": [NSNumber numberWithInt:cell.x],
						   @"y": [NSNumber numberWithInt:cell.y],
						   @"power": [NSNumber numberWithInt:type]};
	[game.turnActions addObject:data];
	//[game.usedPowers addObject:data];
	game.thisPlayer.mana -= [Economy manaCostForPower:type];
	[game.topPanel updateMaxMana];
	
	// TODO: apply feedback overlay
}

+ (void)applyPower:(PowerType)type onCell:(Cell *)cell game:(GameScene *)game {
	
}

@end
