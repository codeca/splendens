//
//  Economy.m
//  splendens
//
//  Created by Guilherme Souza on 10/24/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "Economy.h"

@implementation Economy

+ (int)productionForType:(CellType)type level:(int)level {
	if (type == CellTypeBasic) return 1;
	if (type == CellTypeCity && level == 1) return 2;
	if (type == CellTypeCity && level == 2) return 3;
	if (type == CellTypeCity && level == 3) return 5;
	if (type == CellTypeCity && level == 4) return 8;
	if (type == CellTypeLab && level == 1) return 1;
	if (type == CellTypeLab && level == 2) return 2;
	if (type == CellTypeLab && level == 3) return 3;
	if (type == CellTypeLab && level == 4) return 4;
	// "Production" for towers are attackSpeed*damage to make easier to show in the upgrade interface
	if (type == CellTypeTower) return [Economy attackSpeedForTowerLevel:level]*[Economy attackDamageForTowerLevel:level];
	return -1;
}

+ (int)maxPopulationForType:(CellType)type level:(int)level {
	if (type == CellTypeBasic) return 10;
	if (type == CellTypeCity && level == 1) return 30;
	if (type == CellTypeCity && level == 2) return 45;
	if (type == CellTypeCity && level == 3) return 60;
	if (type == CellTypeCity && level == 4) return 75;
	if (type == CellTypeTower && level == 1) return 10;
	if (type == CellTypeTower && level == 2) return 20;
	if (type == CellTypeTower && level == 3) return 30;
	if (type == CellTypeTower && level == 4) return 40;
	if (type == CellTypeLab && level == 1) return 20;
	if (type == CellTypeLab && level == 2) return 30;
	if (type == CellTypeLab && level == 3) return 40;
	if (type == CellTypeLab && level == 4) return 50;
	return -1;
}

+ (int)speedForType:(CellType)type level:(int)level {
	if (type == CellTypeBasic) return 1;
	if (type == CellTypeCity && level == 1) return 3;
	if (type == CellTypeCity && level == 2) return 3;
	if (type == CellTypeCity && level == 3) return 3;
	if (type == CellTypeCity && level == 4) return 3;
	if (type == CellTypeTower && level == 1) return 2;
	if (type == CellTypeTower && level == 2) return 2;
	if (type == CellTypeTower && level == 3) return 2;
	if (type == CellTypeTower && level == 4) return 2;
	if (type == CellTypeLab && level == 1) return 4;
	if (type == CellTypeLab && level == 2) return 5;
	if (type == CellTypeLab && level == 3) return 6;
	if (type == CellTypeLab && level == 4) return 7;
	return -1;
}

+ (int)armorForType:(CellType)type level:(int)level {
	if (type == CellTypeBasic) return 1;
	if (type == CellTypeCity && level == 1) return 1;
	if (type == CellTypeCity && level == 2) return 1;
	if (type == CellTypeCity && level == 3) return 1;
	if (type == CellTypeCity && level == 4) return 1;
	if (type == CellTypeTower && level == 1) return 2;
	if (type == CellTypeTower && level == 2) return 2;
	if (type == CellTypeTower && level == 3) return 3;
	if (type == CellTypeTower && level == 4) return 4;
	if (type == CellTypeLab && level == 1) return 1;
	if (type == CellTypeLab && level == 2) return 1;
	if (type == CellTypeLab && level == 3) return 1;
	if (type == CellTypeLab && level == 4) return 1;
	return -1;
}

+ (int)attackSpeedForTowerLevel:(int)level {
	if (level == 1) return 1;
	if (level == 2) return 1;
	if (level == 3) return 2;
	if (level == 4) return 2;
	return -1;
}

+ (int)attackDamageForTowerLevel:(int)level {
	if (level == 1) return 3;
	if (level == 2) return 3;
	if (level == 3) return 4;
	if (level == 4) return 4;
	return -1;
}

+ (int)attackRangeForTowerLevel:(int)level {
	if (level == 1) return 2;
	if (level == 2) return 3;
	if (level == 3) return 3;
	if (level == 4) return 4;
	return -1;
}

+ (int)bonusMaxManaForLabLevel:(int)level {
	if (level == 1) return 5;
	if (level == 2) return 10;
	if (level == 3) return 15;
	if (level == 4) return 20;
	return -1;
}

+ (int)upgradePopulationCostForType:(CellType)type level:(int)level {
	if (type == CellTypeCity && level == 1) return 5;
	if (type == CellTypeCity && level == 2) return 15;
	if (type == CellTypeCity && level == 3) return 25;
	if (type == CellTypeCity && level == 4) return 35;
	if (type == CellTypeTower && level == 1) return 10;
	if (type == CellTypeTower && level == 2) return 10;
	if (type == CellTypeTower && level == 3) return 20;
	if (type == CellTypeTower && level == 4) return 30;
	if (type == CellTypeLab && level == 1) return 10;
	if (type == CellTypeLab && level == 2) return 10;
	if (type == CellTypeLab && level == 3) return 20;
	if (type == CellTypeLab && level == 4) return 30;
	return -1;
}

+ (int)upgradeManaCostForType:(CellType)type level:(int)level {
	if (type == CellTypeCity && level == 1) return 0;
	if (type == CellTypeCity && level == 2) return 2;
	if (type == CellTypeCity && level == 3) return 4;
	if (type == CellTypeCity && level == 4) return 6;
	if (type == CellTypeTower && level == 1) return 0;
	if (type == CellTypeTower && level == 2) return 3;
	if (type == CellTypeTower && level == 3) return 6;
	if (type == CellTypeTower && level == 4) return 9;
	if (type == CellTypeLab && level == 1) return 0;
	if (type == CellTypeLab && level == 2) return 4;
	if (type == CellTypeLab && level == 3) return 8;
	if (type == CellTypeLab && level == 4) return 12;
	return -1;
}

@end
