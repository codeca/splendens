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
	// TODO
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"(%d, %d)", self.x, self.y);
}

@end
