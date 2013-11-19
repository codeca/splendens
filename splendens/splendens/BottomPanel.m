//
//  BottomPanel.m
//  splendens
//
//  Created by Rodolfo Bitu on 25/10/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "BottomPanel.h"
#import "Map.h"
#import "Economy.h"
#import "TextButton.h"
#import "GameScene.h"
#import "TopPanel.h"

@interface BottomPanel()

@property (nonatomic) BOOL powerBarHidden;

@property (nonatomic) TextButton* city;
@property (nonatomic) TextButton* tower;
@property (nonatomic) TextButton* lab;

// Store the selected option for basic cell uptade
// Possible values are self.city, self.tower, self.lab or nil
@property TextButton* selected;

@property NSMutableArray* powerAction;
@property NSMutableArray* animationsTextures;


@property (nonatomic) PowerButton* selectedPowerButton;

@end

@implementation BottomPanel

- (id)init{
	if (self = [super initWithImageNamed:@"bottomPanel"]) {
		self.selectedPower = PowerNone;
		self.powers = [[NSMutableArray alloc]init];
		self.position = CGPointMake(768/2, (1024-self.size.height-MAP_SIZE-25)/2);
		self.name = @"bottomPanel";
		self.table = [[SKNode alloc]init];
		[self addChild:self.table];
		
		int d = 20;
		self.nextTurn = [[TextButton alloc] initWithText:@"Next turn"];
		self.nextTurn.position = CGPointMake(self.size.width/2-self.nextTurn.size.width/2-d, 0);
		self.nextTurn.hidden = YES;
		self.nextTurn.userInteractionEnabled = NO;
		[self addChild:self.nextTurn];
		self.nextTurnDisabled = YES;
		self.nextTurn.delegate = self;
		
		
		float a = 5;
		int n = Player.numAvailablePowers;
		UIColor* powerBarBrown = [UIColor colorWithRed:.6 green:.4 blue:.2 alpha:0.5];
		self.powerBar = [SKSpriteNode spriteNodeWithColor:powerBarBrown size:CGSizeMake(a*(n+1)+64*n, 64+2*a)];
		float d2 = (self.size.width - self.nextTurn.size.width - self.powerBar.size.width - d)/2;
		self.powerBar.position = CGPointMake(-self.size.width/2+self.powerBar.size.width/2+d2, 0);
		[self addChild:self.powerBar];
		
		NSArray* powerImageName = [Powers powerNames];
		
		for (int i=0;i<n;i++){
			PowerButton* power;
			power = [[PowerButton alloc] initWithImage:powerImageName[i]];

			power.position = CGPointMake(-self.powerBar.size.width/2+(i+1)*a+i*power.size.width+power.size.width/2, 0);
			[self.powerBar addChild:power];
			power.name = [NSString stringWithFormat:@"power%d",i];
			power.delegate = self;
			[self.powers addObject:power];
		}
		
		
		
		self.upgradeButton = [[TextButton alloc] initWithImage:@"arrow"];
		self.upgradeButton.colorBlendFactor = 1;
		self.upgradeButton.delegate = self;
		
		self.powerAction = [[NSMutableArray alloc]init];
		self.animationsTextures = [[NSMutableArray alloc]init];

		for (NSString* power in @[@"infect",@"downgrade",@"clearMap",@"neutrilize",@"conquer"]){
			SKTextureAtlas* atlas;
			atlas = [SKTextureAtlas atlasNamed:power];
			NSArray* textureNames = atlas.textureNames;
			NSMutableArray* textures = [[NSMutableArray alloc] init];
			for (int i=0; i < textureNames.count/2; i++){
				NSString* name = [NSString stringWithFormat:@"%@%d@",power,i];
				SKTexture* texture;
				texture = [SKTexture textureWithImageNamed:name];
				[texture preloadWithCompletionHandler:^{
					NSLog(@"load em %@",name);
				}];
				[textures addObject:texture];
			}
			[self.animationsTextures addObject:textures];
			SKAction* animation = [SKAction animateWithTextures: textures timePerFrame:0.1 resize:YES restore:YES];
			SKAction* wait = [SKAction waitForDuration:1];
			NSArray* animationArray = @[animation,wait];
			SKAction* animationSequence = [SKAction sequence:animationArray];
			animationSequence = [SKAction repeatActionForever:animationSequence];
			[self.powerAction addObject:animationSequence];
		}
		
	}
	return self;
}

- (void) setNextTurnDisabled:(BOOL)nextTurnDisabled{
	self.nextTurn.hidden = nextTurnDisabled;
	self.nextTurn.userInteractionEnabled = !nextTurnDisabled;
	_nextTurnDisabled = nextTurnDisabled;
}

- (void)setSelectedPower:(PowerType)selectedPower{
	if (selectedPower == PowerNone){
		[self stopPowerAnimation];
		[self clearPowerBar];
		self.selectedPowerButton = nil;
	}
	
	if (selectedPower != PowerNone){
		if (_selectedPower != PowerNone) [self stopPowerAnimation];
		self.selectedPowerButton = self.powers[selectedPower];
		
		_selectedPower = selectedPower;
		[self animatePower];
	}
	
	_selectedPower = selectedPower;
}

- (void)usePower {
	self.selectedPowerButton.used = YES;
	self.selectedPower = PowerNone;
}

- (void)textButtonClicked:(TextButton *)button {
	GameScene* game = (GameScene*)self.scene;
	Cell* cell = game.map.selected;
	if (button == self.upgradeButton) {
		if (game.userTurn != UserTurn)
			return;
		
		if (self.selected == nil)
			[game upgradeCell:cell toType:cell.type];
		else {
			int temp = cell.level;
			if (self.selected == self.city)
				[game upgradeCell:cell toType:CellTypeCity];
			else if (self.selected == self.tower)
				[game upgradeCell:cell toType:CellTypeTower];
			else if (self.selected == self.lab)
				[game upgradeCell:cell toType:CellTypeLab];
			if (temp != cell.level) self.selected = nil;
		}
		if (self.selected == self.lab || cell.type == CellTypeLab){
			TopPanel* topPanel = (TopPanel*) [game childNodeWithName:@"topPanel"];
			[topPanel updateMaxMana];
		}
	}
	else if(button == self.nextTurn) {
		self.selectedPower = PowerNone;
		[game endMyTurn];
		
	} else if(button == self.city) {
		self.selected = self.city;
	} else if(button == self.tower) {
		self.selected = self.tower;
	} else if(button == self.lab) {
		self.selected = self.lab;
	}
	else{
		if ([self.powers containsObject:button] && game.userTurn == UserTurn) {
			PowerButton* pwBt = (PowerButton*)button;
			if (pwBt.used != YES){
				if([pwBt.name isEqualToString:@"power0"]){
					self.selectedPower = (self.selectedPower == PowerInfect) ? PowerNone : PowerInfect;
				} else if([pwBt.name isEqualToString:@"power1"]){
					self.selectedPower = (self.selectedPower == PowerDowngrade) ? PowerNone : PowerDowngrade;
				} else if([pwBt.name isEqualToString:@"power2"]){
					self.selectedPower = (self.selectedPower == PowerClearMap) ? PowerNone : PowerClearMap;
				} else if([pwBt.name isEqualToString:@"power3"]){
					self.selectedPower = (self.selectedPower == PowerNeutralize) ? PowerNone : PowerNeutralize;
				} else if([pwBt.name isEqualToString:@"power4"]){
					self.selectedPower = (self.selectedPower == PowerConquer) ? PowerNone : PowerConquer;
				}
			}
			else{
				self.selectedPower = PowerNone;
			}
		}
	}
	[self update];
	
}

- (void) clearPowerBar{
	// TODO: review this logic
	for (PowerButton* bt in self.powers)
		if (bt.used == NO);
			//bt.color = [UIColor magentaColor];
}

- (void)resetPowerBar {
	for (PowerButton* bt in self.powers)
		bt.used = NO;
	[self clearPowerBar];
}

+ (UIColor*) colorForPower: (PowerType) powerType{
	if (powerType == PowerNone) return nil;
	if (powerType == PowerInfect) return [UIColor greenColor];
	if (powerType == PowerClearMap) return [UIColor blackColor];
	if (powerType == PowerDowngrade) return [UIColor blueColor];
	if (powerType == PowerNeutralize) return [UIColor yellowColor];
	if (powerType == PowerConquer) return [UIColor redColor];
	return nil;
}

- (void)setPowerBarHidden:(BOOL)powerBarHidden{
	if (powerBarHidden == YES){
		self.powerBar.userInteractionEnabled = NO;
		self.powerBar.hidden = YES;
		PowerButton* power;
		for (power in self.powerBar.children){
			power.userInteractionEnabled = NO;
		}
	}
	else{
		self.powerBar.userInteractionEnabled = YES;
		self.powerBar.hidden = NO;
		PowerButton* power;
		for (power in self.powerBar.children){
			power.userInteractionEnabled = YES;
		}
	}
	_powerBarHidden = powerBarHidden;
}

- (void)animatePower{

	[self.selectedPowerButton runAction:self.powerAction[self.selectedPower]];
	 
}

- (void)stopPowerAnimation{
	[self.selectedPowerButton removeAllActions];
}

- (void)update {
	GameScene* game = (GameScene*)self.parent;
	Cell* selectedCell = game.map.selected;
	[self.table removeAllChildren];
	[self.upgradeButton removeAllChildren];
	if (selectedCell == nil){
		self.powerBarHidden = NO;
		if (self.selectedPower != PowerNone){
			
			
			

		}
	}
	else{
		self.powerBarHidden = YES;
		int x = 76; // Width of each table cell
		int y = 40; // Height of each table cell
		int dy2 = 10; // Space between table cells
		int dy1 = (self.size.height-dy2-2*y)/2; // Table cells margin
		int dx3 = 0;
		int fontSize = 28;
		self.upgradeButton.position = CGPointMake(2*x+dy1+2*dy2+self.upgradeButton.size.width/2-self.size.width/2, 0);
		SKSpriteNode* tableCell1 = [SKSpriteNode spriteNodeWithImageNamed:@"tableCell"];
		SKSpriteNode* tableCell2 = [SKSpriteNode spriteNodeWithImageNamed:@"tableCell"];
		SKSpriteNode* tableCell3 = [SKSpriteNode spriteNodeWithImageNamed:@"tableCell"];
		SKSpriteNode* tableCell4 = [SKSpriteNode spriteNodeWithImageNamed:@"tableCell"];
		[self.table addChild:tableCell1];
		[self.table addChild:tableCell2];
		[self.table addChild:tableCell3];
		[self.table addChild:tableCell4];
		tableCell1.position = CGPointMake(dy1+x/2-self.size.width/2, dy1+y+dy2+y/2-self.size.height/2);
		tableCell2.position = CGPointMake(dy1+x+dy2+x/2-self.size.width/2, dy1+y+dy2+y/2-self.size.height/2);
		tableCell3.position = CGPointMake(dy1+x/2-self.size.width/2, dy1+y/2-self.size.height/2);
		tableCell4.position = CGPointMake(dy1+x+dy2+x/2-self.size.width/2, dy1+y/2-self.size.height/2);
		
		int a = 2*x-3*y;
		int da = 2*y-x;
		
		NSString* image = selectedCell.type==CellTypeTower ? @"attack" : @"production";

		SKSpriteNode* attributeCell1 = [SKSpriteNode spriteNodeWithImageNamed:image];
		attributeCell1.position = CGPointMake(da+a/2-x/2, da+a/2-y/2);
		SKSpriteNode* attributeCell2 = [SKSpriteNode spriteNodeWithImageNamed:@"armor"];
		attributeCell2.position = CGPointMake(da+a/2-x/2, da+a/2-y/2);
		SKSpriteNode* attributeCell3 = [SKSpriteNode spriteNodeWithImageNamed:@"maxPopulation"];
		attributeCell3.position = CGPointMake(da+a/2-x/2, da+a/2-y/2);
		SKSpriteNode* attributeCell4 = [SKSpriteNode spriteNodeWithImageNamed:@"speed"];
		attributeCell4.position = CGPointMake(da+a/2-x/2, da+a/2-y/2);
		[tableCell1 addChild:attributeCell1];
		[tableCell2 addChild:attributeCell2];
		[tableCell3 addChild:attributeCell3];
		[tableCell4 addChild:attributeCell4];
		
		
		
		SKLabelNode* infoCell1 = [[SKLabelNode alloc] initWithFontNamed:@"arial"];
		infoCell1.fontSize = fontSize;
		infoCell1.position = CGPointMake(2*da+a+a/2-x/2, da+a/2-y/2);
		infoCell1.text = [NSString stringWithFormat:@"%d",[Economy productionForCell: selectedCell]];
		if (selectedCell.bonus == BonusPopulation && selectedCell.type == CellTypeCity) infoCell1.fontColor = [UIColor yellowColor];
		infoCell1.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
		SKLabelNode* infoCell2 = [[SKLabelNode alloc] initWithFontNamed:@"arial"];
		infoCell2.fontSize = fontSize;
		infoCell2.position = CGPointMake(2*da+a+a/2-x/2, da+a/2-y/2);
		infoCell2.text = [NSString stringWithFormat:@"%d",[Economy armorForCell:selectedCell]];
		if (selectedCell.bonus == BonusArmor) infoCell2.fontColor = [UIColor yellowColor];
		infoCell2.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
		SKLabelNode* infoCell3 = [[SKLabelNode alloc] initWithFontNamed:@"arial"];
		infoCell3.fontSize = fontSize;
		infoCell3.position = CGPointMake(2*da+a+a/2-x/2, da+a/2-y/2);
		infoCell3.text = [NSString stringWithFormat:@"%d",[Economy maxPopulationForType:selectedCell.type level:selectedCell.level]];
		infoCell3.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
		SKLabelNode* infoCell4 = [[SKLabelNode alloc] initWithFontNamed:@"arial"];
		infoCell4.fontSize = fontSize;
		infoCell4.position = CGPointMake(2*da+a+a/2-x/2, da+a/2-y/2);
		infoCell4.text = [NSString stringWithFormat:@"%d",[Economy speedForCell:selectedCell]];
		if (selectedCell.bonus == BonusSpeed) infoCell4.fontColor = [UIColor yellowColor];
		infoCell4.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
		
		[tableCell1 addChild:infoCell1];
		[tableCell2 addChild:infoCell2];
		[tableCell3 addChild:infoCell3];
		[tableCell4 addChild:infoCell4];
		
		if (selectedCell.owner == game.thisPlayer){
			SKLabelNode* popCost = [[SKLabelNode alloc] initWithFontNamed:@"Arial"];
			SKLabelNode* manaCost = [[SKLabelNode alloc] initWithFontNamed:@"Arial"];
			if (selectedCell.level<4){
				int popCostValue = [Economy upgradePopulationCostForType:selectedCell.type level:selectedCell.level+1];
				int manaCostValue = [Economy upgradeManaCostForType:selectedCell.type level:selectedCell.level+1];
				[self.table addChild: self.upgradeButton];
				NSString* temp;
				temp = [NSString stringWithFormat:@"%d",popCostValue];
				popCost.text = temp;
				popCost.fontSize = fontSize;
				popCost.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
				popCost.fontColor = [UIColor greenColor];
				
				if (popCostValue > selectedCell.population) popCost.fontColor = [UIColor redColor];
				[self.upgradeButton addChild:popCost];
				popCost.position = CGPointMake(0, self.upgradeButton.size.height/2+dy2+popCost.frame.size.height/2);
				if (manaCostValue > 0){
					temp = [NSString stringWithFormat:@"%d",manaCostValue];
					manaCost.text = temp;
					manaCost.fontSize = fontSize;
					manaCost.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
					manaCost.fontColor = [UIColor blueColor];
					if (manaCostValue > game.thisPlayer.mana) manaCost.fontColor = [UIColor redColor];
					[self.upgradeButton addChild:manaCost];
					manaCost.position = CGPointMake(0, - self.upgradeButton.size.height/2-dy2-manaCost.frame.size.height/2);
				}
				if (popCostValue <= selectedCell.population && (manaCostValue == -1 || manaCostValue <= game.thisPlayer.mana)) {
					self.upgradeButton.color = [UIColor colorWithRed:0 green:0.5 blue:0 alpha:1];
					self.upgradeButton.userInteractionEnabled = YES;
				}
				else {
					self.upgradeButton.color = [UIColor colorWithRed:0.5 green:0 blue:0 alpha:1];
					self.upgradeButton.userInteractionEnabled = NO;
				}
			}
			if (selectedCell.type == CellTypeBasic){
				
				if (self.city == nil){
					self.city = [[TextButton alloc] initWithImage:@"City"];
					self.city.xScale = self.city.yScale = 0.5;
					self.city.delegate = self;
					self.city.color = game.thisPlayer.color;
				}
				[self.table addChild:self.city];
				self.city.colorBlendFactor = 0;
				self.city.hidden = NO;
				
				if (self.tower == nil){
					self.tower = [[TextButton alloc] initWithImage:@"Tower"];
					self.tower.xScale = self.tower.yScale = 0.5;
					self.tower.delegate = self;
					self.tower.color = game.thisPlayer.color;
				}
				[self.table addChild:self.tower];
				self.tower.colorBlendFactor = 0;
				self.tower.hidden = NO;
				
				if (self.lab == nil){
					self.lab = [[TextButton alloc] initWithImage:@"Lab"];
					self.lab.xScale = self.lab.yScale = 0.5;
					self.lab.delegate = self;
					self.lab.color = game.thisPlayer.color;
				}
				[self.table addChild:self.lab];
				self.lab.colorBlendFactor = 0;
				self.lab.hidden = NO;
				
				self.city.position = CGPointMake(dy1+self.city.frame.size.width/2-self.size.width/2+dy2+2*x+dy2+self.upgradeButton.size.width+dy2, self.tower.frame.size.height/2 + dy2 -5 + self.city.frame.size.height/2);
				self.tower.position = CGPointMake(dy1+self.tower.frame.size.width/2-self.size.width/2+dy2+2*x+dy2+self.upgradeButton.size.width+dy2, 0);
				self.lab.position = CGPointMake(dy1+self.lab.frame.size.width/2-self.size.width/2+dy2+2*x+dy2+self.upgradeButton.size.width+dy2,  -self.tower.frame.size.height/2 - dy2 + 5 - self.lab.frame.size.height/2);
				
				
				dx3 = 2*dy2+self.city.frame.size.width;
				
				if (self.selected == nil) self.selected = self.city;
				
				if (self.selected == self.city){
					self.city.colorBlendFactor = 1;
				}
				else if (self.selected == self.tower){
					self.tower.colorBlendFactor = 1;
				}
				else if (self.selected == self.lab){
					self.lab.colorBlendFactor = 1;
				}
				
				
				NSString* temp,*temp2;
				
				popCost.fontColor = [UIColor greenColor];
				manaCost.fontColor = [UIColor blueColor];
				
				if (self.selected == self.city){
					temp = [NSString stringWithFormat:@"%d",[Economy upgradePopulationCostForType:CellTypeCity level:1]];
					temp2 =[NSString stringWithFormat:@"%d",[Economy upgradePopulationCostForType:CellTypeCity level:1]];
					
					if ([Economy upgradePopulationCostForType:CellTypeCity level:1] > selectedCell.population) popCost.fontColor = [UIColor redColor];
					if ([Economy upgradeManaCostForType:CellTypeCity level:1] > game.thisPlayer.mana) manaCost.fontColor = [UIColor redColor];
					
				}
				else if (self.selected == self.tower){
					temp = [NSString stringWithFormat:@"%d",[Economy upgradePopulationCostForType:CellTypeTower level:1]];
					temp2 =[NSString stringWithFormat:@"%d",[Economy upgradePopulationCostForType:CellTypeTower level:1]];
					if ([Economy upgradePopulationCostForType:CellTypeTower level:1] > selectedCell.population) popCost.fontColor = [UIColor redColor];
					if ([Economy upgradeManaCostForType:CellTypeTower level:1] > game.thisPlayer.mana) manaCost.fontColor = [UIColor redColor];
				}
				else if (self.selected == self.lab){
					temp = [NSString stringWithFormat:@"%d",[Economy upgradePopulationCostForType:CellTypeLab level:1]];
					temp2 =[NSString stringWithFormat:@"%d",[Economy upgradePopulationCostForType:CellTypeLab level:1]];
					if ([Economy upgradePopulationCostForType:CellTypeLab level:1] > selectedCell.population) popCost.fontColor = [UIColor redColor];
					if ([Economy upgradeManaCostForType:CellTypeLab level:1] > game.thisPlayer.mana) manaCost.fontColor = [UIColor redColor];
				}
				
				popCost.text = temp;
				manaCost.text = temp2;
				
			}
			else self.selected = nil;
			if (selectedCell.level<4) {
				SKSpriteNode* tableCell5 = [SKSpriteNode spriteNodeWithImageNamed:@"tableCell"];
				SKSpriteNode* tableCell6 = [SKSpriteNode spriteNodeWithImageNamed:@"tableCell"];
				SKSpriteNode* tableCell7 = [SKSpriteNode spriteNodeWithImageNamed:@"tableCell"];
				SKSpriteNode* tableCell8 = [SKSpriteNode spriteNodeWithImageNamed:@"tableCell"];
				[self.table addChild:tableCell5];
				[self.table addChild:tableCell6];
				[self.table addChild:tableCell7];
				[self.table addChild:tableCell8];
				tableCell5.position = CGPointMake(dx3+dy1+x/2-self.size.width/2+dy2+2*x+dy2+self.upgradeButton.size.width+dy2, dy1+y+dy2+y/2-self.size.height/2);
				tableCell6.position = CGPointMake(dx3+dy1+x+dy2+x/2-self.size.width/2+dy2+2*x+dy2+self.upgradeButton.size.width+dy2, dy1+y+dy2+y/2-self.size.height/2);
				tableCell7.position = CGPointMake(dx3+dy1+x/2-self.size.width/2+dy2+2*x+dy2+self.upgradeButton.size.width+dy2, dy1+y/2-self.size.height/2);
				tableCell8.position = CGPointMake(dx3+dy1+x+dy2+x/2-self.size.width/2+dy2+2*x+dy2+self.upgradeButton.size.width+dy2, dy1+y/2-self.size.height/2);
				
				image = selectedCell.type==CellTypeTower || self.selected==self.tower ? @"attack" : @"production";
				
				SKSpriteNode* attributeCell5 = [SKSpriteNode spriteNodeWithImageNamed:image];
				attributeCell5.position = CGPointMake(da+a/2-x/2, da+a/2-y/2);
				SKSpriteNode* attributeCell6 = [SKSpriteNode spriteNodeWithImageNamed:@"armor"];
				attributeCell6.position = CGPointMake(da+a/2-x/2, da+a/2-y/2);
				SKSpriteNode* attributeCell7 = [SKSpriteNode spriteNodeWithImageNamed:@"maxPopulation"];
				attributeCell7.position = CGPointMake(da+a/2-x/2, da+a/2-y/2);
				SKSpriteNode* attributeCell8 = [SKSpriteNode spriteNodeWithImageNamed:@"speed"];
				attributeCell8.position = CGPointMake(da+a/2-x/2, da+a/2-y/2);
				[tableCell5 addChild:attributeCell5];
				[tableCell6 addChild:attributeCell6];
				[tableCell7 addChild:attributeCell7];
				[tableCell8 addChild:attributeCell8];
				
				
				SKLabelNode* infoCell5 = [[SKLabelNode alloc] initWithFontNamed:@"arial"];
				infoCell5.fontSize = fontSize;
				infoCell5.position = CGPointMake(2*da+a+a/2-x/2, da+a/2-y/2);
				infoCell5.text = [NSString stringWithFormat:@"%d",[Economy productionForType:selectedCell.type level:selectedCell.level+1]];
				infoCell5.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
				SKLabelNode* infoCell6 = [[SKLabelNode alloc] initWithFontNamed:@"arial"];
				infoCell6.fontSize = fontSize;
				infoCell6.position = CGPointMake(2*da+a+a/2-x/2, da+a/2-y/2);
				infoCell6.text = [NSString stringWithFormat:@"%d",[Economy armorForType:selectedCell.type level:selectedCell.level+1]];
				infoCell6.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
				SKLabelNode* infoCell7 = [[SKLabelNode alloc] initWithFontNamed:@"arial"];
				infoCell7.fontSize = fontSize;
				infoCell7.position = CGPointMake(2*da+a+a/2-x/2, da+a/2-y/2);
				infoCell7.text = [NSString stringWithFormat:@"%d",[Economy maxPopulationForType:selectedCell.type level:selectedCell.level+1]];
				infoCell7.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
				SKLabelNode* infoCell8 = [[SKLabelNode alloc] initWithFontNamed:@"arial"];
				infoCell8.fontSize = fontSize;
				infoCell8.position = CGPointMake(2*da+a+a/2-x/2, da+a/2-y/2);
				infoCell8.text = [NSString stringWithFormat:@"%d",[Economy speedForType:selectedCell.type level:selectedCell.level+1]];
				infoCell8.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
				
				if (self.selected == self.city){
					infoCell5.text = [NSString stringWithFormat:@"%d",[Economy productionForType:CellTypeCity level:1]];
					infoCell6.text = [NSString stringWithFormat:@"%d",[Economy armorForType:CellTypeCity level:1]];
					infoCell7.text = [NSString stringWithFormat:@"%d",[Economy maxPopulationForType:CellTypeCity level:1]];
					infoCell8.text = [NSString stringWithFormat:@"%d",[Economy speedForType:CellTypeCity level:1]];
				}
				if (self.selected == self.tower){
					infoCell5.text = [NSString stringWithFormat:@"%d",[Economy productionForType:CellTypeTower level:1]];
					infoCell6.text = [NSString stringWithFormat:@"%d",[Economy armorForType:CellTypeTower level:1]];
					infoCell7.text = [NSString stringWithFormat:@"%d",[Economy maxPopulationForType:CellTypeTower level:1]];
					infoCell8.text = [NSString stringWithFormat:@"%d",[Economy speedForType:CellTypeTower level:1]];
				}
				
				if (self.selected == self.lab){
					infoCell5.text = [NSString stringWithFormat:@"%d",[Economy productionForType:CellTypeLab level:1]];
					infoCell6.text = [NSString stringWithFormat:@"%d",[Economy armorForType:CellTypeLab level:1]];
					infoCell7.text = [NSString stringWithFormat:@"%d",[Economy maxPopulationForType:CellTypeLab level:1]];
					infoCell8.text = [NSString stringWithFormat:@"%d",[Economy speedForType:CellTypeLab level:1]];
				}
				
				[tableCell5 addChild:infoCell5];
				[tableCell6 addChild:infoCell6];
				[tableCell7 addChild:infoCell7];
				[tableCell8 addChild:infoCell8];
			}
		}
	}
}


@end
