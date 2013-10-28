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
#import "BottomPainel.h"

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

/*
int dist = 3;
NSMutableArray* visited = [NSMutableArray array];
NSMutableArray* currentLevel = @[self];
Map* map = (Map*)self.parent;
int dx[] = {1, 0, 0, -1};
int dy[] = {0, 1, 0, -1};

// Start at the tower and expand up to max distance
for (int i=0; i <= dist; i++) {
	NSMutableArray* newLevel = [NSMutableArray array];
	
	// Pick-up a cell in the range to expand one further
	for (Cell* cell in currentLevel) {
		[visited addObject:cell];
		for (int j=0; j<3; j++) {
			// Test each neighbour
			Cell* neighbour = [map cellAtX:self.x+dx[j] y:self.y+dy[j]];
			if (neighbour && neighbour.type == CellTypeEmpty && ![visited containsObject:neighbour])
				// A new empty and unvisited neighbour found
				[newLevel addObject:neighbour];
		}
	}
	
	currentLevel = newLevel;
}
*/

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
	CellPosition prevPos, nextPos;
	if (prev)
		prevPos = [self relativePositionToCell:prev];
	if (next)
		nextPos = [self relativePositionToCell:next];
	
	if (!prev) {
		// Path start
		self.pathFocus.texture = [Cell textureWithName:@"path3"];
		self.pathFocus.zRotation = [self relativeAngleToCell:next];
	} else if (!next) {
		// Path end
		self.pathFocus.texture = [Cell textureWithName:@"path3"];
		self.pathFocus.zRotation = [self relativeAngleToCell:prev];
	} else if ((prevPos==CellPositionRight && nextPos==CellPositionLeft) || (prevPos==CellPositionLeft && nextPos==CellPositionRight)) {
		// Horizontal path
		self.pathFocus.texture = [Cell textureWithName:@"path2I"];
		self.pathFocus.zRotation = 0;
	} else if ((prevPos==CellPositionAbove && nextPos==CellPositionBellow) || (prevPos==CellPositionBellow && nextPos==CellPositionAbove)) {
		// Vertical path
		self.pathFocus.texture = [Cell textureWithName:@"path2I"];
		self.pathFocus.zRotation = M_PI/2;
	} else if ((prevPos==CellPositionRight && nextPos==CellPositionAbove) || (prevPos==CellPositionAbove && nextPos==CellPositionRight)) {
		// Curved path
		self.pathFocus.texture = [Cell textureWithName:@"path2L"];
		self.pathFocus.zRotation = 0;
	} else if ((prevPos==CellPositionAbove && nextPos==CellPositionLeft) || (prevPos==CellPositionLeft && nextPos==CellPositionAbove)) {
		// Curved path
		self.pathFocus.texture = [Cell textureWithName:@"path2L"];
		self.pathFocus.zRotation = M_PI/2;
	} else if ((prevPos==CellPositionLeft && nextPos==CellPositionBellow) || (prevPos==CellPositionBellow && nextPos==CellPositionLeft)) {
		// Curved path
		self.pathFocus.texture = [Cell textureWithName:@"path2L"];
		self.pathFocus.zRotation = M_PI;
	} else if ((prevPos==CellPositionBellow && nextPos==CellPositionRight) || (prevPos==CellPositionRight && nextPos==CellPositionBellow)) {
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
	BottomPainel* bottomPainel = (BottomPainel*)[[self scene] childNodeWithName: @"bottomPainel"];
	[bottomPainel update: map.selected];
	
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
	if (self.isCenter && self.owner == map.thisPlayer && self.population) {
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
	Map* map = (Map*)self.parent;
	
	// Send troops if possible
	if ([cell isCenter] && cell.population)
		[map sendTroop:map.lastPath];
	
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

- (BOOL)isCenter {
	return self.type != CellTypeEmpty && self.type != CellTypeWall;
}

- (CGPoint)randomPointNear {
	float x, y, a, r;
	x = self.position.x;
	y = self.position.y;
	r = self.size.height/2;
	a = arc4random_uniform(360)*M_PI/180;
	return CGPointMake(x+r*sin(a), y+r*cos(a));
}

- (CellPosition)relativePositionToCell:(Cell*)cell {
	if (cell.x == self.x)
		return cell.y>self.y ? CellPositionAbove : CellPositionBellow;
	else
		return cell.x>self.x ? CellPositionRight : CellPositionLeft;
}

- (float)relativeAngleToCell:(Cell*)cell {
	if (cell.x == self.x)
		return cell.y>self.y ? M_PI/2 : 3*M_PI/2;
	else
		return cell.x>self.x ? 0 : M_PI;
}

@end
