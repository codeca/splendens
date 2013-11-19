//
//  Player.m
//  splendens
//
//  Created by Guilherme Souza on 10/23/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "Player.h"

@implementation Player

+ (int)level {
	return [[NSUserDefaults standardUserDefaults] integerForKey:@"level"];
}

+ (int)currentWins {
	return [[NSUserDefaults standardUserDefaults] integerForKey:@"wins"];
}

+ (int)neededWins {
	int level = Player.level;
	int step = 1, step2 = 1;
	
	for (int i=1; i<level; i++) {
		int temp = step;
		step = step+step2;
		step2 = temp;
	}
	
	return step;
}

+ (BOOL)saveWin {
	int wins = Player.currentWins+1;
	int needed = Player.neededWins;
	if (wins >= needed) {
		[[NSUserDefaults standardUserDefaults] setInteger:Player.level+1 forKey:@"level"];
		[[NSUserDefaults standardUserDefaults] setInteger:wins-needed forKey:@"wins"];
		return YES;
	} else {
		[[NSUserDefaults standardUserDefaults] setInteger:wins forKey:@"wins"];
		return NO;
	}
}

+ (int)numAvailablePowers {
	return MIN((Player.level+1)/2, 5);
}

- (void)setBonus:(BonusType)bonus {
	// Update all owned cells
	for (Cell* cell in self.game.map.cells)
		if (cell.owner == self)
			cell.bonus = bonus;
	_bonus = bonus;
}

@end
