//
//  MapCell.m
//  splendens
//
//  Created by Guilherme Souza on 10/23/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "Cell.h"
#import "Map.h"
#import "PathFinder.h"
#import "Economy.h"

@interface Cell()

// Visual nodes
@property (nonatomic) SKSpriteNode* typeOverlay;
@property (nonatomic) SKCropNode* populationOverlay;
@property (nonatomic) SKSpriteNode* populationFull;
@property (nonatomic) SKSpriteNode* populationMask;
@property (nonatomic) SKLabelNode* populationLabel;
@property (nonatomic) SKSpriteNode* pathFocus;
@property (nonatomic) SKSpriteNode* selectedFocus;

@end

@implementation Cell

- (id)initWithX:(int)x y:(int)y size:(CGSize)size {
	if (self = [super initWithTexture:[Cell textureWithName:@"empty"] color:[UIColor clearColor] size:size]) {
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
		
		// PathFocus
		self.pathFocus = [SKSpriteNode spriteNodeWithTexture: [Cell textureWithName:@"path4"] size:size];
		self.pathFocus.colorBlendFactor = 1;
		self.pathFocus.hidden = YES;
		[self addChild:self.pathFocus];
		
		// selectedFocus
		self.selectedFocus = [SKSpriteNode spriteNodeWithTexture: [Cell textureWithName:@"path4"] size:size];
		self.selectedFocus.color = [UIColor greenColor];
		self.selectedFocus.colorBlendFactor = 1;
		self.selectedFocus.hidden = YES;
		[self addChild:self.selectedFocus];
		
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
		SKSpriteNode* star = [SKSpriteNode spriteNodeWithTexture:[Cell textureWithName:@"star"]];
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
		case CellTypeWall: self.typeOverlay.texture = [Cell textureWithName:@"wall"]; break;
		case CellTypeBasic: self.typeOverlay.texture = [Cell textureWithName:@"basic"]; break;
		case CellTypeCity: self.typeOverlay.texture = [Cell textureWithName:@"city"]; break;
		case CellTypeTower: self.typeOverlay.texture = [Cell textureWithName:@"tower"]; break;
		case CellTypeLab: self.typeOverlay.texture = [Cell textureWithName:@"lab"]; break;
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
		if (self.type == CellTypeBasic) self.populationFull.texture = [Cell textureWithName:@"basic2"];
		else if (self.type == CellTypeCity) self.populationFull.texture = [Cell textureWithName:@"city2"];
		else if (self.type == CellTypeTower) self.populationFull.texture = [Cell textureWithName:@"tower2"];
		else self.populationFull.texture = [Cell textureWithName:@"lab2"];
		self.populationOverlay.hidden = NO;
		self.populationFull.color = self.owner ? self.owner.color : [UIColor grayColor];
		int width = self.size.width;
		int height = self.size.height;
		int maxPop = [Economy maxPopulationForType:self.type level:self.level];
		self.populationMask.size = CGSizeMake(width, self.population*height/maxPop);
		
		// Label
		self.populationLabel.hidden = NO;
		self.populationLabel.text = [NSString stringWithFormat:@"%d", self.population];
	} else {
		self.populationOverlay.hidden = YES;
		self.populationLabel.hidden = YES;
	}
}

// Update the pathfocus texture to the best path sprite
- (void)updatePathFocusWithPreviousCell:(Cell*)prev nextCell:(Cell*)next {
	self.pathFocus.hidden = NO;
	
	// Check the relative position for each cell
	int prevPos, nextPos;
	if (prev) {
		if (prev.x == self.x)
			prevPos = prev.y>self.y ? 1 : 3;
		else
			prevPos = prev.x>self.x ? 0 : 2;
	}
	if (next) {
		if (next.x == self.x)
			nextPos = next.y>self.y ? 1 : 3;
		else
			nextPos = next.x>self.x ? 0 : 2;
	}
	
	if (!prev) {
		// Path start
		self.pathFocus.texture = [Cell textureWithName:@"path3"];
		self.pathFocus.zRotation = M_PI*(nextPos==0 ? 0 : (nextPos==1 ? .5 : (nextPos==2 ? 1 : 1.5)));
	} else if (!next) {
		// Path end
		self.pathFocus.texture = [Cell textureWithName:@"path3"];
		self.pathFocus.zRotation = M_PI*(prevPos==0 ? 0 : (prevPos==1 ? .5 : (prevPos==2 ? 1 : 1.5)));
	} else if ((prevPos==0 && nextPos==2) || (prevPos==2 && nextPos==0)) {
		// Horizontal path
		self.pathFocus.texture = [Cell textureWithName:@"path2I"];
		self.pathFocus.zRotation = 0;
	} else if ((prevPos==1 && nextPos==3) || (prevPos==3 && nextPos==1)) {
		// Vertical path
		self.pathFocus.texture = [Cell textureWithName:@"path2I"];
		self.pathFocus.zRotation = M_PI/2;
	} else if ((prevPos==0 && nextPos==1) || (prevPos==1 && nextPos==0)) {
		// Curved path
		self.pathFocus.texture = [Cell textureWithName:@"path2L"];
		self.pathFocus.zRotation = 0;
	} else if ((prevPos==1 && nextPos==2) || (prevPos==2 && nextPos==1)) {
		// Curved path
		self.pathFocus.texture = [Cell textureWithName:@"path2L"];
		self.pathFocus.zRotation = M_PI/2;
	} else if ((prevPos==2 && nextPos==3) || (prevPos==3 && nextPos==2)) {
		// Curved path
		self.pathFocus.texture = [Cell textureWithName:@"path2L"];
		self.pathFocus.zRotation = M_PI;
	} else if ((prevPos==3 && nextPos==0) || (prevPos==0 && nextPos==3)) {
		// Curved path
		self.pathFocus.texture = [Cell textureWithName:@"path2L"];
		self.pathFocus.zRotation = 3*M_PI/2;
	} else
		self.pathFocus.texture = [Cell textureWithName:@"path4"];
}

#pragma mark - cached textures

+ (SKTexture*)textureWithName:(NSString*)name {
	static NSMutableDictionary* cache = nil;
	
	// Initialize the cache if not done wet
	if (!cache)
		cache = [NSMutableDictionary dictionary];
	
	// Retrieve the texture
	SKTexture* texture = [cache objectForKey:name];
	if (!texture) {
		// Not found, load it and save it in the cache
		texture = [SKTexture textureWithImageNamed:name];
		[cache setObject:texture forKey:name];
	}
	return texture;
}

#pragma mark - touchs

// Check if the user dragged over another cell and dispatch draggedToCell:
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	UITouch *touch = [touches anyObject];
	Map* map = (Map*)self.parent;
	CGPoint location = [touch locationInNode:map];
	Cell* cell = [map cellAtPixelX:location.x pixelY:location.y];
	if (cell)
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
	else if (cell)
		[self stopedDragToCell:cell];
}

#pragma mark - interactivity

// Remove the last selection and select this cell (if possible)
- (void)cellClicked {
	Map* map = (Map*)self.parent;
	
	map.selected.selectedFocus.hidden = YES;
	
	if (self.type != CellTypeWall && self.type != CellTypeEmpty && map.selected != self) {
		map.selected = self;
		map.selected.selectedFocus.hidden = NO;
	} else
		map.selected = nil;
}

- (void)draggedToCell:(Cell*)cell {
	Map* map = (Map*)self.parent;
	map.selected.selectedFocus.hidden = YES;
	map.selected = nil;
	
	// Clear previous focused path
	for (Cell* i in map.lastPath)
		i.pathFocus.hidden = YES;
	map.lastPath = nil;
	
	// Paint the new path
	if (self.isCenter == YES) {
		map.lastPath = [PathFinder findPathwithStart:self andGoal:cell andMap:map];
		UIColor* color = [cell isCenter] ? [UIColor magentaColor] : [UIColor redColor];
		Cell* previous = nil;
		for (int i=0; i<map.lastPath.count; i++) {
			Cell* now = map.lastPath[i];
			Cell* next = i<map.lastPath.count-1 ? map.lastPath[i+1] : nil;
			now.pathFocus.color = color;
			[now updatePathFocusWithPreviousCell:previous nextCell:next];
			previous = now;
		}
	}
}

- (void)stopedDragToCell:(Cell*)cell {
	// TODO: Send troops if possible
	Map* map = (Map*)self.parent;
	
	// Clear the previous focused path
	for (Cell* i in map.lastPath)
		i.pathFocus.hidden = YES;
	map.lastPath = nil;
}

- (void) upgradeTo: (CellType)type{
	int popCost = [Economy upgradePopulationCostForType:type level:1];
	int manaCost = [Economy upgradeManaCostForType:type level:1];
	if (popCost>-1 && manaCost>-1){
		if (self.population >= popCost && ((Map*)self.parent).thisPlayer.mana >= manaCost){
			self.population -= popCost;
			((Map*)self.parent).thisPlayer.mana -= manaCost;
			self.type = type;
			self.level = 1;
		}
	}
}

- (void) upgrade{
	int popCost = [Economy upgradePopulationCostForType:self.type level:self.level];
	int manaCost = [Economy upgradeManaCostForType:self.type level:self.level];
	if (popCost>-1 && manaCost>-1){
		if (self.population >= popCost && ((Map*)self.parent).thisPlayer.mana >= manaCost){
			self.population -= popCost;
			((Map*)self.parent).thisPlayer.mana -= manaCost;
			self.level += 1;
		}
	}
	
}

- (BOOL) isCenter{
	if (self.type == CellTypeEmpty || self.type == CellTypeWall) return NO;
	return YES;
}

@end
