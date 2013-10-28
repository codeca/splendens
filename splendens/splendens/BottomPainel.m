//
//  BottomPainel.m
//  splendens
//
//  Created by Rodolfo Bitu on 25/10/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "BottomPainel.h"
#import "Map.h"
#import "UpgradeArrow.h"
#import "Economy.h"
#import "TextButton.h"

@interface BottomPainel()
@property TextButton* city;
@property TextButton* tower;
@property TextButton* lab;
@property TextButton* selected;
@end

@implementation BottomPainel

- (id)init{
	if (self = [super initWithColor:[UIColor grayColor] size:CGSizeMake(MAP_SIZE,116)]) {
		self.size = CGSizeMake(MAP_SIZE,115);
		self.position = CGPointMake(768/2, (1024-self.size.height-MAP_SIZE-25)/2);
		self.name = @"bottomPainel";
		self.table = [[SKNode alloc]init];
		[self addChild:self.table];
		
		self.nextTurn = [[TextButton alloc] initWithText:@"Next turn"];
		self.nextTurn.position = CGPointMake(self.size.width/2-100, 0);
		[self addChild:self.nextTurn];
		self.nextTurn.delegate = self;
		
		self.upgradeButton = [[TextButton alloc] initWithImage:@"beta"];
		self.upgradeButton.delegate = self;
		

	}
	return self;
}

- (void)textButtonClicked:(TextButton *)button {
	Map* map = (Map*)[[self scene] childNodeWithName:@"map"];
	Cell* cell = map.selected;
	if (button == self.upgradeButton){
		Map* map = (Map*)[[self scene] childNodeWithName:@"map"];
		Cell* cell = map.selected;
		if (self.selected == nil)[cell upgrade];
		else{
			if (self.selected == self.city)
				[cell upgradeTo: CellTypeCity];
			else if (self.selected == self.tower)
				[cell upgradeTo:CellTypeTower];
			else if (self.selected == self.lab)
				[cell upgradeTo:CellTypeLab];
			self.selected = nil;
		}
		[self update:cell];
		NSLog(@"Upgrade!!!!");
	}
	else if(button == self.nextTurn){
		Map* map = (Map*)[self.scene childNodeWithName:@"map"];
		[map processTurn];
		[self update:cell];
	}
	else if(button == self.city){
		NSLog(@"City");
		self.selected = self.city;
		[self update:cell];
	}
	else if(button == self.tower){
		NSLog(@"Tower");
		self.selected = self.tower;
		[self update:cell];
	}
	else if(button == self.tower){
		NSLog(@"Lab");
		self.selected = self.lab;
		[self update:cell];
	}
}

- (void) update: (Cell*)selectedCell{
	Map* map = (Map*)[[self scene] childNodeWithName: @"map"];
	[self.table removeAllChildren];
	[self.upgradeButton removeAllChildren];
	if (selectedCell == nil);
	else{
		int x = 76; // Width of each table cell
		int y = 40; // Height of each table cell
		int dy2 = 10; // Space between table cells
		int dy1 = (self.size.height-dy2-2*y)/2; // Table cells margin
		int fontSize = 28;
		self.upgradeButton.position = CGPointMake(2*x+dy1+2*dy2+self.upgradeButton.size.width/2-self.size.width/2, 0);

		CGSize size = CGSizeMake(x,y);
		SKSpriteNode* tableCell1 = [[SKSpriteNode alloc] initWithColor:[UIColor blueColor] size:size];
		SKSpriteNode* tableCell2 = [[SKSpriteNode alloc] initWithColor:[UIColor blueColor] size:size];
		SKSpriteNode* tableCell3 = [[SKSpriteNode alloc] initWithColor:[UIColor blueColor] size:size];
		SKSpriteNode* tableCell4 = [[SKSpriteNode alloc] initWithColor:[UIColor blueColor] size:size];
		[self.table addChild:tableCell1];
		[self.table addChild:tableCell2];
		[self.table addChild:tableCell3];
		[self.table addChild:tableCell4];
		tableCell1.size = size;
		tableCell2.size = size;
		tableCell3.size = size;
		tableCell4.size = size;
		tableCell1.position = CGPointMake(dy1+x/2-self.size.width/2, dy1+y+dy2+y/2-self.size.height/2);
		tableCell2.position = CGPointMake(dy1+x+dy2+x/2-self.size.width/2, dy1+y+dy2+y/2-self.size.height/2);
		tableCell3.position = CGPointMake(dy1+x/2-self.size.width/2, dy1+y/2-self.size.height/2);
		tableCell4.position = CGPointMake(dy1+x+dy2+x/2-self.size.width/2, dy1+y/2-self.size.height/2);
		
		int a = 2*x-3*y;
		int da = 2*y-x;
		size = CGSizeMake(a,a);
		SKSpriteNode* attributeCell1 = [SKSpriteNode spriteNodeWithColor:[UIColor yellowColor] size:size];
		attributeCell1.position = CGPointMake(da+a/2-x/2, da+a/2-y/2);
		SKSpriteNode* attributeCell2 = [SKSpriteNode spriteNodeWithColor:[UIColor yellowColor] size:size];
		attributeCell2.position = CGPointMake(da+a/2-x/2, da+a/2-y/2);
		SKSpriteNode* attributeCell3 = [SKSpriteNode spriteNodeWithColor:[UIColor yellowColor] size:size];
		attributeCell3.position = CGPointMake(da+a/2-x/2, da+a/2-y/2);
		SKSpriteNode* attributeCell4 = [SKSpriteNode spriteNodeWithColor:[UIColor yellowColor] size:size];
		attributeCell4.position = CGPointMake(da+a/2-x/2, da+a/2-y/2);
		[tableCell1 addChild:attributeCell1];
		[tableCell2 addChild:attributeCell2];
		[tableCell3 addChild:attributeCell3];
		[tableCell4 addChild:attributeCell4];
		
		
		
		SKLabelNode* infoCell1 = [[SKLabelNode alloc] initWithFontNamed:@"arial"];
		infoCell1.fontSize = fontSize;
		infoCell1.position = CGPointMake(2*da+a+a/2-x/2, da+a/2-y/2);
		infoCell1.text = [NSString stringWithFormat:@"%d",[Economy productionForType:selectedCell.type level:selectedCell.level]];
		infoCell1.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
		SKLabelNode* infoCell2 = [[SKLabelNode alloc] initWithFontNamed:@"arial"];
		infoCell2.fontSize = fontSize;
		infoCell2.position = CGPointMake(2*da+a+a/2-x/2, da+a/2-y/2);
		infoCell2.text = [NSString stringWithFormat:@"%d",[Economy armorForType:selectedCell.type level:selectedCell.level]];
		infoCell2.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
		SKLabelNode* infoCell3 = [[SKLabelNode alloc] initWithFontNamed:@"arial"];
		infoCell3.fontSize = fontSize;
		infoCell3.position = CGPointMake(2*da+a+a/2-x/2, da+a/2-y/2);
		infoCell3.text = [NSString stringWithFormat:@"%d",[Economy maxPopulationForType:selectedCell.type level:selectedCell.level]];
		infoCell3.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
		SKLabelNode* infoCell4 = [[SKLabelNode alloc] initWithFontNamed:@"arial"];
		infoCell4.fontSize = fontSize;
		infoCell4.position = CGPointMake(2*da+a+a/2-x/2, da+a/2-y/2);
		infoCell4.text = [NSString stringWithFormat:@"%d",[Economy speedForType:selectedCell.type level:selectedCell.level]];
		infoCell4.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
		
		[tableCell1 addChild:infoCell1];
		[tableCell2 addChild:infoCell2];
		[tableCell3 addChild:infoCell3];
		[tableCell4 addChild:infoCell4];
		
		if (selectedCell.owner == map.thisPlayer){
			SKLabelNode* popCost = [[SKLabelNode alloc] initWithFontNamed:@"Arial"];
			SKLabelNode* manaCost = [[SKLabelNode alloc] initWithFontNamed:@"Arial"];
			if (selectedCell.level<4){
				[self.table addChild: self.upgradeButton];
				NSString* temp;
				temp = [NSString stringWithFormat:@"%d",[Economy upgradePopulationCostForType:selectedCell.type level:selectedCell.level+1]];
				popCost.text = temp;
				popCost.fontSize = fontSize;
				popCost.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
				popCost.fontColor = [UIColor greenColor];
				if ([Economy upgradePopulationCostForType:selectedCell.type level:selectedCell.level+1] > selectedCell.population) popCost.fontColor = [UIColor redColor];
				[self.upgradeButton addChild:popCost];
				popCost.position = CGPointMake(0, self.upgradeButton.size.height/2+dy2+popCost.frame.size.height/2);
				if ([Economy upgradeManaCostForType:selectedCell.type level:selectedCell.level+1] > 0){
					temp = [NSString stringWithFormat:@"%d",[Economy upgradeManaCostForType:selectedCell.type level:selectedCell.level+1]];
					manaCost.text = temp;
					manaCost.fontSize = fontSize;
					manaCost.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
					manaCost.fontColor = [UIColor blueColor];
					if ([Economy upgradeManaCostForType:selectedCell.type level:selectedCell.level+1] > map.thisPlayer.mana) manaCost.fontColor = [UIColor redColor];
					[self.upgradeButton addChild:manaCost];
					manaCost.position = CGPointMake(0, - self.upgradeButton.size.height/2-dy2-manaCost.frame.size.height/2);
				}
			}
			if (selectedCell.type == CellTypeBasic){
				self.city = [[TextButton alloc] initWithImage:@"City"];
				self.tower = [[TextButton alloc] initWithImage:@"Tower"];
				self.lab = [[TextButton alloc] initWithImage:@"Lab"];
				if (self.selected == nil) self.selected = self.city;
				self.city.delegate = self;
				self.tower.delegate = self;
				self.lab.delegate = self;
				
				self.city.position = CGPointMake(dy1+self.city.size.width/2-self.size.width/2+dy2+2*x+dy2+self.upgradeButton.size.width+dy2, 0);
				self.tower.position = CGPointMake(dy1+self.tower.size.width/2+self.city.size.width-self.size.width/2+dy2+dy2+2*x+dy2+self.upgradeButton.size.width+dy2, 0);
				self.lab.position = CGPointMake(dy1+self.lab.size.width/2+self.tower.size.width+self.city.size.width-self.size.width/2+3*dy2+2*x+dy2+self.upgradeButton.size.width+dy2, 0);
				[self.table addChild:self.city];
				[self.table addChild:self.tower];
				[self.table addChild:self.lab];
				
				NSString* temp,*temp2;
				
				popCost.fontColor = [UIColor greenColor];
				manaCost.fontColor = [UIColor blueColor];
				
				if (self.selected == self.city){
					temp = [NSString stringWithFormat:@"%d",[Economy upgradePopulationCostForType:CellTypeCity level:1]];
					temp2 =[NSString stringWithFormat:@"%d",[Economy upgradePopulationCostForType:CellTypeCity level:1]];
					
					if ([Economy upgradePopulationCostForType:CellTypeCity level:1] > selectedCell.population) popCost.fontColor = [UIColor redColor];
					if ([Economy upgradeManaCostForType:CellTypeCity level:1] > map.thisPlayer.mana) manaCost.fontColor = [UIColor redColor];
					
				}
				else if (self.selected == self.tower){
					temp = [NSString stringWithFormat:@"%d",[Economy upgradePopulationCostForType:CellTypeTower level:1]];
					temp2 =[NSString stringWithFormat:@"%d",[Economy upgradePopulationCostForType:CellTypeTower level:1]];
					if ([Economy upgradePopulationCostForType:CellTypeTower level:1] > selectedCell.population) popCost.fontColor = [UIColor redColor];
					if ([Economy upgradeManaCostForType:CellTypeTower level:1] > map.thisPlayer.mana) manaCost.fontColor = [UIColor redColor];
				}
				else if (self.selected == self.city){
					temp = [NSString stringWithFormat:@"%d",[Economy upgradePopulationCostForType:CellTypeLab level:1]];
					temp2 =[NSString stringWithFormat:@"%d",[Economy upgradePopulationCostForType:CellTypeLab level:1]];
					if ([Economy upgradePopulationCostForType:CellTypeLab level:1] > selectedCell.population) popCost.fontColor = [UIColor redColor];
					if ([Economy upgradeManaCostForType:CellTypeLab level:1] > map.thisPlayer.mana) manaCost.fontColor = [UIColor redColor];
				}
				
				popCost.text = temp;
				manaCost.text = temp2;
				
			}
			else{
				self.selected = nil;
				if (selectedCell.level<4){
	
					CGSize size = CGSizeMake(x,y);
					SKSpriteNode* tableCell5 = [[SKSpriteNode alloc] initWithColor:[UIColor greenColor] size:size];
					SKSpriteNode* tableCell6 = [[SKSpriteNode alloc] initWithColor:[UIColor greenColor] size:size];
					SKSpriteNode* tableCell7 = [[SKSpriteNode alloc] initWithColor:[UIColor greenColor] size:size];
					SKSpriteNode* tableCell8 = [[SKSpriteNode alloc] initWithColor:[UIColor greenColor] size:size];
					[self.table addChild:tableCell5];
					[self.table addChild:tableCell6];
					[self.table addChild:tableCell7];
					[self.table addChild:tableCell8];
					tableCell5.size = size;
					tableCell6.size = size;
					tableCell7.size = size;
					tableCell8.size = size;
					tableCell5.position = CGPointMake(dy1+x/2-self.size.width/2+dy2+2*x+dy2+self.upgradeButton.size.width+dy2, dy1+y+dy2+y/2-self.size.height/2);
					tableCell6.position = CGPointMake(dy1+x+dy2+x/2-self.size.width/2+dy2+2*x+dy2+self.upgradeButton.size.width+dy2, dy1+y+dy2+y/2-self.size.height/2);
					tableCell7.position = CGPointMake(dy1+x/2-self.size.width/2+dy2+2*x+dy2+self.upgradeButton.size.width+dy2, dy1+y/2-self.size.height/2);
					tableCell8.position = CGPointMake(dy1+x+dy2+x/2-self.size.width/2+dy2+2*x+dy2+self.upgradeButton.size.width+dy2, dy1+y/2-self.size.height/2);
				
					size = CGSizeMake(a,a);
					SKSpriteNode* attributeCell5 = [SKSpriteNode spriteNodeWithColor:[UIColor yellowColor] size:size];
					attributeCell5.position = CGPointMake(da+a/2-x/2, da+a/2-y/2);
					SKSpriteNode* attributeCell6 = [SKSpriteNode spriteNodeWithColor:[UIColor yellowColor] size:size];
					attributeCell6.position = CGPointMake(da+a/2-x/2, da+a/2-y/2);
					SKSpriteNode* attributeCell7 = [SKSpriteNode spriteNodeWithColor:[UIColor yellowColor] size:size];
					attributeCell7.position = CGPointMake(da+a/2-x/2, da+a/2-y/2);
					SKSpriteNode* attributeCell8 = [SKSpriteNode spriteNodeWithColor:[UIColor yellowColor] size:size];
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
				
					[tableCell5 addChild:infoCell5];
					[tableCell6 addChild:infoCell6];
					[tableCell7 addChild:infoCell7];
					[tableCell8 addChild:infoCell8];
				}
			}
		}
		
	}
}


@end
