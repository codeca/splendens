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
	[game.thisPlayer.usedPowers addObject:data];
	game.thisPlayer.mana -= [Economy manaCostForPower:type];
	[game.topPanel updateMaxMana];
}

+ (void)applyPower:(PowerType)type forPlayer:(Player*)player onCell:(Cell *)cell game:(GameScene *)game {
	if (player != game.thisPlayer)
		player.mana -= [Economy manaCostForPower:type];
	
	if (type == PowerInfect)
		[self applyInfectOnCell:cell];
	else if (type == PowerClearMap)
		[self applyClearMap:game.map];
	else if (type == PowerDowngrade)
		[self applyDowngradeOnCell:cell];
	else if (type == PowerNeutralize)
		[self applyNeutralizeOnCell:cell];
	else if (type == PowerConquer)
		[self applyConquerOnCell:cell byPlayer:player];
}

+ (void)applyInfectOnCell:(Cell*)cell {
	cell.population /= 2;
}

+ (void)applyClearMap:(Map*)map {
	for (Troop* troop in map.troops) {
		SKAction* grow = [SKAction scaleTo:1.5 duration:TOTAL_ATTACK_TIME/2];
		SKAction* fade = [SKAction fadeOutWithDuration:TOTAL_ATTACK_TIME/2];
		SKAction* pop = [SKAction group:@[grow, fade]];
		SKAction* remove = [SKAction removeFromParent];
		[troop.node runAction:[SKAction sequence:@[pop, remove]]];
	}
	map.troops = [NSMutableArray array];
}

+ (void)applyDowngradeOnCell:(Cell*)cell {
	if (cell.type != CellTypeBasic) {
		if (cell.level == 1)
			cell.type = CellTypeBasic;
		else
			cell.level--;
	}
}

+ (void)applyNeutralizeOnCell:(Cell*)cell {
	cell.owner = nil;
	cell.bonus = BonusNone;
}

+ (void)applyConquerOnCell:(Cell*)cell byPlayer:(Player*)player {
	cell.owner = player;
	cell.bonus = player.bonus;
}

@end
