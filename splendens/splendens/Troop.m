//
//  Troop.m
//  splendens
//
//  Created by Guilherme Souza on 10/25/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "Troop.h"
#import "Economy.h"

@implementation Troop

- (id)initWithPath:(NSArray *)path amount:(int)amount {
	if (self = [super initWithImageNamed:@"troop"]) {
		Cell* cell = path[0];
		self.path = path;
		self.speed = [Economy speedForType:cell.type level:cell.level];
		self.pos = 0;
		self.owner = cell.owner;
		self.color = cell.owner.color;
		self.colorBlendFactor = 1;
		
		// Set amount label
		SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:@"arial"];
		label.text = [NSString stringWithFormat:@"%d", amount];
		label.fontSize = 16;
		label.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
		[self addChild:label];
	}
	return self;
}

@end
