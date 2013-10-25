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


@implementation BottomPainel

- (id)init{
	if (self = [super initWithColor:[UIColor grayColor] size:CGSizeMake(MAP_SIZE,116)]) {
		self.size = CGSizeMake(MAP_SIZE,115);
		self.position = CGPointMake(768/2, (1024-self.size.height-MAP_SIZE-25)/2);
		self.name = @"bottomPainel";
		self.table = [[SKNode alloc]init];
		[self addChild:self.table];
		
	}
	return self;
}

- (void) update: (Cell*)selectedCell{
	Map* map = (Map*)self.parent;
	if (selectedCell == nil) [self.table removeAllChildren];
	else{
		int x = 76;
		int y = 40;
		int dy2 = 10;
		int dy1 = (116-dy2-2*y)/2;
		
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
		infoCell1.position = CGPointMake(2*da+a+a/2-x/2, da+a/2-y/2);
		infoCell1.text = @"1";
		infoCell1.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
		SKLabelNode* infoCell2 = [[SKLabelNode alloc] initWithFontNamed:@"arial"];
		infoCell2.position = CGPointMake(2*da+a+a/2-x/2, da+a/2-y/2);
		infoCell2.text = @"1";
		infoCell2.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
		SKLabelNode* infoCell3 = [[SKLabelNode alloc] initWithFontNamed:@"arial"];
		infoCell3.position = CGPointMake(2*da+a+a/2-x/2, da+a/2-y/2);
		infoCell3.text = @"1";
		infoCell3.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
		SKLabelNode* infoCell4 = [[SKLabelNode alloc] initWithFontNamed:@"arial"];
		infoCell4.position = CGPointMake(2*da+a+a/2-x/2, da+a/2-y/2);
		infoCell4.text = @"1";
		infoCell4.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
		
		[tableCell1 addChild:infoCell1];
		[tableCell2 addChild:infoCell2];
		[tableCell3 addChild:infoCell3];
		[tableCell4 addChild:infoCell4];
		
		if (selectedCell.owner == map.thisPlayer){
			if (selectedCell.level<4){
				UpgradeArrow* upgradeArrow = [[UpgradeArrow alloc]init];
				upgradeArrow.position = CGPointMake(3*da+2*a-self.size.width/2, 0);
				[self.table addChild:upgradeArrow];
			}
			if (selectedCell.type == CellTypeBasic){
				//mostra opcoes
			}
			else{
				//mostra upgrade
			}
		}
		
	}
}

@end
