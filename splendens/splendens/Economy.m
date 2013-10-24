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
	return -1;
}
+ (int)maxPopulationForType:(CellType)type level:(int)level {
	if (type == CellTypeBasic) return 10;
	if (type == CellTypeCity && level == 1) return 30;
	if (type == CellTypeCity && level == 2) return 45;
	if (type == CellTypeCity && level == 3) return 60;
	if (type == CellTypeCity && level == 4) return 75;
	if (type == CellTypeTower && level == 1) return 20;
	if (type == CellTypeTower && level == 2) return 30;
	if (type == CellTypeTower && level == 3) return 40;
	if (type == CellTypeTower && level == 4) return 50;
	if (type == CellTypeLab && level == 1) return 20;
	if (type == CellTypeLab && level == 2) return 30;
	if (type == CellTypeLab && level == 3) return 40;
	if (type == CellTypeLab && level == 4) return 50;
	return -1;
}
+ (int)speedForType:(CellType)type level:(int)level {
	return 0;
}
+ (int)armorForType:(CellType)type level:(int)level {
	return 0;
}
+ (int)attackSpeedForType:(CellType)type level:(int)level {
	return 0;
}
+ (int)attackDamageForType:(CellType)type level:(int)level {
	return 0;
}
+ (int)attackRangeForType:(CellType)type level:(int)level {
	return 0;
}
+ (int)bonusMaxManaForType:(CellType)type level:(int)level {
	return 0;
}
+ (int)upgradePopulationCostForType:(CellType)type level:(int)level {
	return 0;
}
+ (int)upgradePopulationForType:(CellType)type level:(int)level {
	return 0;
}

@end
