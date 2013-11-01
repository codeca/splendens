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
#import "BottomPanel.h"
#import "GameScene.h"

@interface Cell()

// Visual nodes
@property (nonatomic) SKSpriteNode* typeOverlay;
@property (nonatomic) SKCropNode* populationOverlay;
@property (nonatomic) SKSpriteNode* populationFull;
@property (nonatomic) SKSpriteNode* populationMask;
@property (nonatomic) SKLabelNode* populationLabel;
@property (nonatomic) SKSpriteNode* pathFocus;
@property (nonatomic) SKSpriteNode* selectedFocus;
@property (nonatomic) SKSpriteNode* bonusNode; // A node to represent the cell bonus, child of map, but managed by the cell

@end

@implementation Cell

- (id)initWithX:(int)x y:(int)y size:(CGSize)size map:(Map*)map {
	if (self = [super initWithTexture:[Cell textureWithName:@"empty"] color:[UIColor clearColor] size:size]) {
		// Position this node in the map
		self.position = CGPointMake(x*size.width+size.width/2, y*size.height+size.height/2);
		[map addChild:self];
		
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
		self.selectedFocus.colorBlendFactor = 1;
		self.selectedFocus.hidden = YES;
		[self addChild:self.selectedFocus];
		
		// Bonus overlay (children of map)
		CGSize bonusSize = CGSizeMake(size.width/2, size.height/2);
		self.bonusNode = [SKSpriteNode spriteNodeWithColor:[UIColor redColor] size:bonusSize];
		self.bonusNode.position = CGPointMake(self.position.x, self.position.y+size.height/2);
		self.bonusNode.zPosition = 2;
		
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
	if (type == CellTypeCity || type == CellTypeTower || type == CellTypeLab)
		// Avoid recalculation of wall textures
		[self updateOverlay];
	_cellsInRange = nil;
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
	_cellsInRange = nil;
}

- (void)setBonus:(BonusType)bonus {
	// Remove previous bonus
	if (_bonus != BonusNone && bonus == BonusNone) {
		SKAction* fade = [SKAction fadeOutWithDuration:1];
		SKAction* shrink = [SKAction scaleTo:0 duration:1];
		SKAction* remove = [SKAction removeFromParent];
		[self.bonusNode runAction:[SKAction sequence:@[[SKAction group:@[fade, shrink]], remove]]];
	} else if (_bonus != BonusNone) {
		[self.bonusNode removeFromParent];
	}
	
	// Add new bonus
	if (bonus != BonusNone) {
		self.bonusNode.alpha = 0;
		NSString* name = bonus==BonusPopulation ? @"maxPopulation" : (bonus==BonusArmor ? @"armor" : @"speed");
		self.bonusNode.texture = [Cell textureWithName:name];
		[self.bonusNode setScale:0];
		[self.parent addChild:self.bonusNode];
		SKAction* grow = [SKAction scaleTo:2 duration:.5];
		SKAction* fadeIn = [SKAction fadeInWithDuration:.5];
		SKAction* scaleToNormal = [SKAction scaleTo:1 duration:.5];
		[self.bonusNode runAction:[SKAction sequence:@[[SKAction group:@[grow, fadeIn]], scaleToNormal]]];
	}
	
	_bonus = bonus;
	
	// Update the bottom panel if needed
	Map* map = (Map*)self.parent;
	if (map.selected == self)
		[map.game.bottomPanel update];
}

// Update the type overlay
- (void)updateOverlay {
	// Set size and texture overlay
	switch (self.type) {
		case CellTypeEmpty: self.typeOverlay.texture = nil; break;
		case CellTypeWall: [self updateTextureForWall]; break;
		case CellTypeBasic: self.typeOverlay.texture = [Cell textureWithName:@"basic"]; break;
		case CellTypeCity: self.typeOverlay.texture = [Cell textureWithName:@"city"]; break;
		case CellTypeTower: self.typeOverlay.texture = [Cell textureWithName:@"tower"]; break;
		case CellTypeLab: self.typeOverlay.texture = [Cell textureWithName:@"lab"]; break;
	}
	
	// Update player color
	if (self.owner) {
		self.typeOverlay.colorBlendFactor = .75;
		self.typeOverlay.color = self.owner.color;
		[self.typeOverlay setScale:self.population>=[Economy maxPopulationForType:self.type level:self.level] ? 1.2 : 1];
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

#pragma mark - internal methods

// Reconstruct the cellsInRange array
- (NSArray*)cellsInRange {
	if (_cellsInRange)
		return _cellsInRange;
	
	if (self.type != CellTypeTower)
		return nil;
	
	NSMutableArray* visited = [NSMutableArray array];
	NSMutableArray* currentLevel = [NSMutableArray array];
	[currentLevel addObject:self];
	Map* map = (Map*)self.parent;
	int dist = [Economy attackRangeForTowerLevel:self.level];
	int dx[] = {1, 0, -1, 0};
	int dy[] = {0, 1, 0, -1};
	
	// Start at the tower and expand up to max distance
	for (int i=0; i <= dist; i++) {
		NSMutableArray* newLevel = [NSMutableArray array];
		
		// Pick-up a cell in the range to expand one further
		for (Cell* cell in currentLevel) {
			[visited addObject:cell];
			for (int j=0; j<4; j++) {
				// Test each neighbour
				Cell* neighbour = [map cellAtX:cell.x+dx[j] y:cell.y+dy[j]];
				if (neighbour && neighbour.type == CellTypeEmpty && ![visited containsObject:neighbour])
					// A new empty and unvisited neighbour found
					[newLevel addObject:neighbour];
			}
		}
		
		currentLevel = newLevel;
	}
	
	// Save
	return _cellsInRange = visited;
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
	
	// Clear focused cells
	for (Cell* cell in map.cells)
		cell.selectedFocus.hidden = YES;
	
	// Show focus square
	if (self.type != CellTypeWall && self.type != CellTypeEmpty && map.selected != self) {
		map.selected = self;
		self.selectedFocus.color = [UIColor greenColor];
		self.selectedFocus.hidden = NO;
		
		// Show the range for a tower
		if (self.type == CellTypeTower) {
			for (Cell* cell in self.cellsInRange) {
				if (cell != self) {
					cell.selectedFocus.color = [UIColor yellowColor];
					cell.selectedFocus.hidden = NO;
				}
			}
		}
	} else
		map.selected = nil;
}

- (void)draggedToCell:(Cell*)cell {
	Map* map = (Map*)self.parent;
	GameScene* game = (GameScene*)map.parent;
	
	// Clear focused cells
	for (Cell* cell in map.cells)
		cell.selectedFocus.hidden = YES;
	map.selected = nil;
	
	// Clear previous focused path
	for (Cell* i in map.lastPath)
		i.pathFocus.hidden = YES;
	map.lastPath = nil;
	
	// Paint the new path
	if (self.isCenter && self.owner == game.thisPlayer && self.population) {
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
	GameScene* game = (GameScene*)map.parent;
	
	// Send troops if possible
	if (self.isCenter && self.owner == game.thisPlayer && self.population && game.userTurn && [cell isCenter])
		[game sendUserTroop:map.lastPath];
	
	// Clear the previous focused path
	for (Cell* i in map.lastPath)
		i.pathFocus.hidden = YES;
	map.lastPath = nil;
	
}

- (void) upgradeTo: (CellType)type{
	int popCost = [Economy upgradePopulationCostForType:type level:1];
	int manaCost = [Economy upgradeManaCostForType:type level:1];
	if (popCost>-1 && manaCost>-1){
		if (self.population >= popCost && ((GameScene*)self.parent.parent).thisPlayer.mana >= manaCost){
			self.population -= popCost;
			((GameScene*)self.parent.parent).thisPlayer.mana -= manaCost;
			self.type = type;
			self.level = 1;
		}
	}
}

- (void) upgrade{
	int popCost = [Economy upgradePopulationCostForType:self.type level:self.level+1];
	int manaCost = [Economy upgradeManaCostForType:self.type level:self.level+1];
	if (popCost>-1 && manaCost>-1){
		if (self.population >= popCost && self.owner.mana >= manaCost){
			self.population -= popCost;
			self.owner.mana -= manaCost;
			self.level += 1;
			
		}
	}
	
}

- (BOOL)isCenter {
	return self.type != CellTypeEmpty && self.type != CellTypeWall;
}

- (CGPoint)randomPointNear: (float) ratio {
	float x, y, a, r;
	x = self.position.x;
	y = self.position.y;
	r = self.size.height*ratio/2;
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

#pragma mark - wall logic
- (void)updateTextureForWall {
	Map* map = (Map*)self.parent;
	
	// Look for neighbours
	int neighbourhood = 0;
	if (self.x < map.size-1 && self.y > 0 && [map cellAtX:self.x+1 y:self.y-1].type == CellTypeWall)
		neighbourhood += 1;
	if (self.x > 0 && self.y > 0 && [map cellAtX:self.x-1 y:self.y-1].type == CellTypeWall)
		neighbourhood += 2;
	if (self.x > 0 && self.y < map.size-1 && [map cellAtX:self.x-1 y:self.y+1].type == CellTypeWall)
		neighbourhood += 4;
	if (self.x < map.size-1 && self.y < map.size-1 && [map cellAtX:self.x+1 y:self.y+1].type == CellTypeWall)
		neighbourhood += 8;
	if (self.y > 0 && [map cellAtX:self.x y:self.y-1].type == CellTypeWall)
		neighbourhood += 16;
	if (self.x > 0 && [map cellAtX:self.x-1 y:self.y].type == CellTypeWall)
		neighbourhood += 32;
	if (self.y < map.size-1 && [map cellAtX:self.x y:self.y+1].type == CellTypeWall)
		neighbourhood += 64;
	if (self.x < map.size-1 && [map cellAtX:self.x+1 y:self.y].type == CellTypeWall)
		neighbourhood += 128;
	
	// Pick the right image name and rotation
	int i;
	int masks[47] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 3, 3, 3, 3, 6, 6, 6, 6, 12, 12, 12, 12, 9, 9, 9, 9, 7, 7, 15, 11, 11, 14, 14, 15, 13, 13, 15, 15, 15, 15, 15};
	int values[47] = {255, 254, 253, 251, 247, 252, 250, 246, 249, 245, 243, 248, 244, 242, 241, 240, 239, 235, 231, 227, 223, 222, 215, 214, 191, 190, 189, 188, 127, 125, 123, 121, 199, 207, 175, 107, 111, 158, 159, 95, 61, 63, 143, 79, 47, 31, 15};
	NSArray* imageNames = @[@"wall0f-0", @"wall0e-0", @"wall0e-3", @"wall0e-2", @"wall0e-1", @"wall0c-0", @"wall0d-0", @"wall0c-1", @"wall0c-3", @"wall0d-1", @"wall0c-2", @"wall0b-0", @"wall0b-1", @"wall0b-2", @"wall0b-3", @"wall0a-0", @"wall1d-2", @"wall1b-2", @"wall1c-2", @"wall1a-2", @"wall1d-1", @"wall1c-1", @"wall1b-1", @"wall1a-1", @"wall1d-0", @"wall1b-0", @"wall1c-0", @"wall1a-0", @"wall1d-3", @"wall1b-3", @"wall1c-3", @"wall1a-3", @"wall2La-1", @"wall2Lb-1", @"wall2I-0", @"wall2La-2", @"wall2Lb-2", @"wall2La-0", @"wall2Lb-0", @"wall2I-1", @"wall2La-3", @"wall2Lb-3", @"wall3-0", @"wall3-1", @"wall3-2", @"wall3-3", @"wall4-0"];
	
	for (i=0; i<47; i++)
		if ((neighbourhood | masks[i]) == values[i]) {
			NSString* imageName = imageNames[i];
			self.typeOverlay.texture = [Cell textureWithName:imageName];
			return;
		}
}

@end
