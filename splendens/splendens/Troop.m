//
//  Troop.m
//  splendens
//
//  Created by Guilherme Souza on 10/25/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "Troop.h"
#import "Economy.h"

@interface Troop()

@property (nonatomic) SKLabelNode* label;

@end

@implementation Troop

- (id)initWithPath:(NSArray *)path amount:(int)amount {
	if (self = [super init]) {
		Cell* firstCell = path[0];
		float size = 2*firstCell.size.width*sqrt(amount/(50*M_PI));
		
		// Create the node
		self.node = [SKSpriteNode spriteNodeWithImageNamed:@"troop"];
		self.node.size = CGSizeMake(size, size);
		self.node.xScale = self.node.yScale = 0;
		self.node.position = [firstCell randomPointNear: 1];
		[self.node runAction:[SKAction scaleTo:1 duration:.5]];
		
		self.path = path;
		self.speed = [Economy speedForCell:firstCell];
		self.pos = 0;
		self.owner = firstCell.owner;
		self.node.color = firstCell.owner.color;
		self.node.colorBlendFactor = 1;
		
		// Set amount label
		_amount = amount;
		self.newAmount = amount;
		self.label = [SKLabelNode labelNodeWithFontNamed:@"arial"];
		self.label.text = [NSString stringWithFormat:@"%d", amount];
		self.label.fontSize = size*2/3;
		self.label.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
		[self.node addChild:self.label];
	}
	return self;
}

- (Cell*)currentCell {
	return self.path[self.pos];
}

- (void)setAmount:(int)amount {
	_amount = amount;
	SKLabelNode* label = (SKLabelNode*)self.node.children[0];
	label.text = [NSString stringWithFormat:@"%d", amount];
	float size = 2*self.currentCell.size.width*sqrt(amount/(50*M_PI));
	[self.node runAction:[SKAction resizeToWidth:size height:size duration:.5]];
	self.label.fontSize = size*2/3;
}

@end
