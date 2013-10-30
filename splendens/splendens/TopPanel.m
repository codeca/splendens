//
//  TopPanel.m
//  splendens
//
//  Created by Rodolfo Bitu on 30/10/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "TopPanel.h"
#import "Map.h"
#import "Player.h"
#import "GameScene.h"


@implementation TopPanel


- (id) initWithGame:(GameScene *)game {
	if (self = [super initWithImageNamed:@"topPanel"]){
		self.position = CGPointMake(768/2, (1024+self.size.height+MAP_SIZE+25)/2);
		self.name = @"topPainel";
		
		
		int x,y,dx,by,dxx;
		dx = 10;
		x = (MAP_SIZE-3*dx)/2;
		y = 30;
		by = 115 - 4*dx - 2*y;
		dxx = 5;
		SKSpriteNode* populationBar;
		populationBar = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.5] size:CGSizeMake(MAP_SIZE-2*dx, by)];
		populationBar.position = CGPointMake(0, 115/2 - dx-by/2);
		
		
		for (Player* i in game.players) {
			int index = [game.players indexOfObject:i];
			
			SKSpriteNode *cell;
			SKLabelNode *name,*mana;
			
			
			cell = [SKSpriteNode spriteNodeWithColor:i.color size:CGSizeMake(x,y)];
			cell.position = CGPointMake(-x/2-dx/2 + ((int)index/2)*(x+dx), 115/2-dx*2-by-y/2 - index%2*(y+dx));
			cell.name = [NSString stringWithFormat:@"celula%d",index];
			[self addChild:cell];
			
			name  = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
			name.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
			name.text = i.name;
			name.position = CGPointMake(0, cell.size.height/2-dxx-name.frame.size.height/2);
			name.name = @"name";
			name.fontSize = 20;
			[cell addChild:name];
			
			mana = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
			mana.text = [NSString stringWithFormat:@"Mana %d/%d",i.mana,i.maxMana];
			mana.name = @"mana";
			mana.fontSize = 20;
			mana.position = CGPointMake(0, -cell.size.height/2+dxx+mana.frame.size.height/2);
			[cell addChild:mana];
		}
	}

	return self;
}

- (void) update{
	GameScene* gameScene = (GameScene*) self.parent;
	
	for (Player* i in gameScene.players){
		int index = [gameScene.players indexOfObject:i];
		
		SKSpriteNode *cell = (SKSpriteNode*)[self childNodeWithName:[NSString stringWithFormat:@"celula%d",index]];
		SKLabelNode *mana = (SKLabelNode*)[cell childNodeWithName:[NSString stringWithFormat:@"mana"]];
		mana.text = [NSString stringWithFormat:@"Mana %d/%d",i.mana,i.maxMana];
	}
	
}

@end
