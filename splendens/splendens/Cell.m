//
//  MapCell.m
//  splendens
//
//  Created by Guilherme Souza on 10/23/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "Cell.h"

@implementation Cell

- (id)initWithX:(int)x y:(int)y {
	if (self = [super init]) {
		self.userInteractionEnabled = YES;
		_x = x;
		_y = y;
		self.type = CellTypeEmpty;
		
		// Debug label
		SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:@"arial"];
		label.text = [NSString stringWithFormat:@"(%d, %d)", x, y];
		label.fontSize = 16;
		[self addChild:label];
	}
	return self;
}

- (void)setType:(CellType)type {
	switch (type) {
		case CellTypeEmpty: self.color = [UIColor clearColor]; break;
		case CellTypeWall: self.color = [UIColor whiteColor]; break;
		case CellTypeBasic: self.color = [UIColor grayColor]; break;
		case CellTypeCity: self.color = [UIColor greenColor]; break;
		case CellTypeTower: self.color = [UIColor redColor]; break;
		case CellTypeLab: self.color = [UIColor blueColor]; break;
	}
}

- (void)setOwner:(Player *)owner {
	// TODO
}

- (void)setPopulation:(int)population {
	// TODO
}

- (void)setLevel:(int)level {
	// Remove all previous stars
	SKNode* node;
	while ((node = [self childNodeWithName:@"star"]))
		[node removeFromParent];
	
	// Put the right number of stars
	float iniX = -self.size.width/2;
	float iniY = -self.size.height/2;
	for (int i=0; i<level; i++) {
		SKSpriteNode* star = [SKSpriteNode spriteNodeWithImageNamed:@"star"];
		float w = star.size.width;
		float h = star.size.height;
		star.position = CGPointMake(iniX+w*i+w/2, iniY+h/2);
		[self addChild:star];
	}
	_level = level;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"(%d, %d)", self.x, self.y);
}

@end
