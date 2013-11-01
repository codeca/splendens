//
//  Player.m
//  splendens
//
//  Created by Guilherme Souza on 10/23/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "Player.h"

@implementation Player

- (void)setBonus:(BonusType)bonus {
	// Update all owned cells
	for (Cell* cell in self.game.map.cells)
		if (cell.owner == self)
			cell.bonus = bonus;
	_bonus = bonus;
}

@end
