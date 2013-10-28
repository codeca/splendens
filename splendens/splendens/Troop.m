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
	if (self = [super init]) {
		Cell* firstCell = path[0];
		float size = firstCell.size.width;
		
		// Create the node
		self.node = [SKSpriteNode spriteNodeWithImageNamed:@"troop"];
		self.node.size = CGSizeMake(size/2, size/2);
		self.node.xScale = self.node.yScale = 0;
		self.node.position = [firstCell randomPointNear:.5];
		[self.node runAction:[SKAction scaleTo:1 duration:.5]];
		
		self.path = path;
		self.speed = [Economy speedForType:firstCell.type level:firstCell.level];
		self.pos = 0;
		self.owner = firstCell.owner;
		self.node.color = firstCell.owner.color;
		self.node.colorBlendFactor = 1;
		
		// Set amount label
		self.amount = amount;
		SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:@"arial"];
		label.text = [NSString stringWithFormat:@"%d", amount];
		label.fontSize = 16;
		label.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
		[self.node addChild:label];
	}
	return self;
}

- (Cell*)currentCell {
	return self.path[self.pos];
}

@end
