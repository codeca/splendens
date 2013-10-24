//
//  MapCell.m
//  splendens
//
//  Created by Guilherme Souza on 10/23/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "Cell.h"

@interface Cell()

@property (nonatomic) SKSpriteNode* typeOverlay;

@end

@implementation Cell

- (id)initWithX:(int)x y:(int)y {
	if (self = [super initWithTexture:self.class.emptyTexture]) {
		// Create subnode to render the cell type texture
		self.typeOverlay = [[SKSpriteNode alloc] init];
		self.typeOverlay.name = @"type";
		[self addChild:self.typeOverlay];
		
		self.userInteractionEnabled = YES;
		_x = x;
		_y = y;
		self.type = CellTypeEmpty;
	}
	return self;
}

- (void)setType:(CellType)type {
	self.typeOverlay.size = self.size;
	switch (type) {
		case CellTypeEmpty: self.typeOverlay.texture = nil; break;
		case CellTypeWall: self.typeOverlay.texture = self.class.wallTexture; break;
		case CellTypeBasic: self.typeOverlay.texture = self.class.basicTexture; break;
		case CellTypeCity: self.typeOverlay.texture = self.class.cityTexture; break;
		case CellTypeTower: self.typeOverlay.texture = self.class.towerTexture; break;
		case CellTypeLab: self.typeOverlay.texture = self.class.labTexture; break;
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

+ (SKTexture*)emptyTexture {
	static SKTexture* t = nil;
	if (!t)
		t = [SKTexture textureWithImageNamed:@"empty"];
	return t;
}
+ (SKTexture*)wallTexture {
	static SKTexture* t = nil;
	if (!t)
		t = [SKTexture textureWithImageNamed:@"wall4"];
	return t;
}
+ (SKTexture*)basicTexture {
	static SKTexture* t = nil;
	if (!t)
		t = [SKTexture textureWithImageNamed:@"basic"];
	return t;
}
+ (SKTexture*)cityTexture {
	static SKTexture* t = nil;
	if (!t)
		t = [SKTexture textureWithImageNamed:@"city"];
	return t;
}
+ (SKTexture*)towerTexture {
	static SKTexture* t = nil;
	if (!t)
		t = [SKTexture textureWithImageNamed:@"tower"];
	return t;
}
+ (SKTexture*)labTexture {
	static SKTexture* t = nil;
	if (!t)
		t = [SKTexture textureWithImageNamed:@"lab"];
	return t;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	NSLog(@"(%d, %d)", self.x, self.y);
}

@end
