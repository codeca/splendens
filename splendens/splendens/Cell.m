//
//  MapCell.m
//  splendens
//
//  Created by Guilherme Souza on 10/23/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "Cell.h"
#import "Map.h"

@interface Cell()

// Visual nodes
@property (nonatomic) SKSpriteNode* typeOverlay;
@property (nonatomic) SKCropNode* populationOverlay;
@property (nonatomic) SKSpriteNode* populationFull;
@property (nonatomic) SKSpriteNode* populationMask;
@property (nonatomic) SKLabelNode* populationLabel;

@end

@implementation Cell

- (id)initWithX:(int)x y:(int)y size:(CGSize)size {
	if (self = [super initWithTexture:Cell.emptyTexture color:[UIColor clearColor] size:size]) {
		// Create subnode to render the cell type texture
		self.typeOverlay = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:size];
		[self addChild:self.typeOverlay];
		
		// Create subnodes to render the population level overlay
		self.populationOverlay = [[SKCropNode alloc] init];
		self.populationOverlay.hidden = YES;
		self.populationFull = [SKSpriteNode spriteNodeWithColor:[UIColor clearColor] size:size];
		self.populationFull.colorBlendFactor = 1;
		self.populationMask = [SKSpriteNode spriteNodeWithColor:[UIColor blackColor] size:size];
		self.populationMask.anchorPoint = CGPointMake(.5, 0);
		self.populationMask.position = CGPointMake(0, -size.height/2);
		self.populationOverlay.maskNode = self.populationMask;
		[self.populationOverlay addChild:self.populationFull];
		[self addChild:self.populationOverlay];
		
		// Population count label
		self.populationLabel = [SKLabelNode labelNodeWithFontNamed:@"arial"];
		self.populationLabel.hidden = YES;
		self.populationLabel.fontColor = [UIColor whiteColor];
		self.populationLabel.fontSize = self.size.height/3;
		self.populationLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
		[self addChild:self.populationLabel];
		
		self.userInteractionEnabled = YES;
		_x = x;
		_y = y;
		self.type = CellTypeEmpty;
	}
	return self;
}

#pragma mark - setters

- (void)setType:(CellType)type {
	_type = type;
	[self updateOverlay];
}

- (void)setOwner:(Player *)owner {
	_owner = owner;
	[self updateOverlay];
}

- (void)setPopulation:(int)population {
	_population = population;
	[self updateOverlay];
}

- (void)setLevel:(int)level {
	// Remove all previous stars
	SKNode* node;
	while ((node = [self childNodeWithName:@"star"]))
		[node removeFromParent];
	
	// Put the right number of stars
	float iniX = -self.size.width/2;
	float iniY = -self.size.height/2;
	for (int i=0; i<level-1; i++) {
		SKSpriteNode* star = [SKSpriteNode spriteNodeWithTexture:Cell.starTexture];
		float w = star.size.width;
		float h = star.size.height;
		star.position = CGPointMake(iniX+w*i+w/2, iniY+h/2);
		[self addChild:star];
	}
	_level = level;
	[self updateOverlay];
}

#pragma mark - internal methods

// Update the type overlay
- (void)updateOverlay {
	// Set size and texture overlay
	switch (self.type) {
		case CellTypeEmpty: self.typeOverlay.texture = nil; break;
		case CellTypeWall: self.typeOverlay.texture = Cell.wallTexture; break;
		case CellTypeBasic: self.typeOverlay.texture = Cell.basicTexture; break;
		case CellTypeCity: self.typeOverlay.texture = Cell.cityTexture; break;
		case CellTypeTower: self.typeOverlay.texture = Cell.towerTexture; break;
		case CellTypeLab: self.typeOverlay.texture = Cell.labTexture; break;
	}
	
	// Update player color
	if (self.owner) {
		self.typeOverlay.colorBlendFactor = .75;
		self.typeOverlay.color = self.owner.color;
	} else
		self.typeOverlay.colorBlendFactor = 0;
	
	// Update population mask and label
	if (self.type != CellTypeEmpty && self.type != CellTypeWall) {
		// Mask
		if (self.type == CellTypeBasic) self.populationFull.texture = Cell.basicFullTexture;
		else if (self.type == CellTypeCity) self.populationFull.texture = Cell.cityFullTexture;
		else if (self.type == CellTypeTower) self.populationFull.texture = Cell.towerFullTexture;
		else self.populationFull.texture = Cell.labFullTexture;
		self.populationOverlay.hidden = NO;
		self.populationFull.color = self.owner ? self.owner.color : [UIColor grayColor];
		int width = self.size.width;
		int height = self.size.height;
		self.populationMask.size = CGSizeMake(width, self.population*height/50);
		
		// Label
		self.populationLabel.hidden = NO;
		self.populationLabel.text = [NSString stringWithFormat:@"%d", self.population];
	} else {
		self.populationOverlay.hidden = YES;
		self.populationLabel.hidden = YES;
	}
}

#pragma mark - cached textures

+ (SKTexture*)emptyTexture {
	static SKTexture* t = nil;
	return t ? t : (t=[SKTexture textureWithImageNamed:@"empty"]);
}
+ (SKTexture*)wallTexture {
	static SKTexture* t = nil;
	return t ? t : (t=[SKTexture textureWithImageNamed:@"wall4"]);
}
+ (SKTexture*)basicTexture {
	static SKTexture* t = nil;
	return t ? t : (t=[SKTexture textureWithImageNamed:@"basic"]);
}
+ (SKTexture*)cityTexture {
	static SKTexture* t = nil;
	return t ? t : (t=[SKTexture textureWithImageNamed:@"city"]);
}
+ (SKTexture*)towerTexture {
	static SKTexture* t = nil;
	return t ? t : (t=[SKTexture textureWithImageNamed:@"tower"]);
}
+ (SKTexture*)labTexture {
	static SKTexture* t = nil;
	return t ? t : (t=[SKTexture textureWithImageNamed:@"lab"]);
}
+ (SKTexture*)starTexture {
	static SKTexture* t = nil;
	return t ? t : (t=[SKTexture textureWithImageNamed:@"star"]);
}
+ (SKTexture*)basicFullTexture {
	static SKTexture* t = nil;
	return t ? t : (t=[SKTexture textureWithImageNamed:@"basic2"]);
}
+ (SKTexture*)cityFullTexture {
	static SKTexture* t = nil;
	return t ? t : (t=[SKTexture textureWithImageNamed:@"city2"]);
}
+ (SKTexture*)towerFullTexture {
	static SKTexture* t = nil;
	return t ? t : (t=[SKTexture textureWithImageNamed:@"tower2"]);
}
+ (SKTexture*)labFullTexture {
	static SKTexture* t = nil;
	return t ? t : (t=[SKTexture textureWithImageNamed:@"lab2"]);
}

#pragma mark - touchs

// Check if the user dragged over another cell and dispatch draggedToCell:
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	UITouch *touch = [touches anyObject];
	Map* map = (Map*)self.parent;
	CGPoint location = [touch locationInNode:map];
	Cell* cell = [map cellAtPixelX:location.x pixelY:location.y];
	if (cell != self)
		[self draggedToCell:cell];
}

// Check for touch up inside event and dispatch cellClicked
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	Map* map = (Map*)self.parent;
	CGPoint location = [touch locationInNode:map];
	Cell* cell = [map cellAtPixelX:location.x pixelY:location.y];
	if (cell == self)
		[self cellClicked];
}

#pragma mark - interactivity

- (void)cellClicked {
	NSLog(@"Clicked at (%d, %d)", self.x, self.y);
}

- (void)draggedToCell:(Cell*)cell {
	NSLog(@"Dragged from (%d, %d) to (%d, %d)", cell.x, cell.y, self.x, self.y);
}

@end
