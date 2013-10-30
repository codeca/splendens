//
//  TopPainel.m
//  splendens
//
//  Created by Rodolfo Bitu on 30/10/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "TopPainel.h"
#import "Map.h"
#import "Player.h"
#import "GameScene.h"


@implementation TopPainel


- (id) init{
	if (self = [super initWithImageNamed:@"topPanel"]){
		self.position = CGPointMake(768/2, (1024+MAP_SIZE+25)/2);
		//self.size = (MAP_SIZE,155);
		self.name = @"topPainel";
		GameScene* gameScene = (GameScene*) self.parent;
		int dx = 10;
		for (Player* i in gameScene.players) {
			int index = [gameScene.players indexOfObject:i];
			SKSpriteNode* cell;
			SKLabelNode *name,*mana;
			
			cell = [SKSpriteNode spriteNodeWithColor:i.color size:CGSizeMake((MAP_SIZE-3*dx)/2,40)];
			
			
			name  = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
			name.text = i.name;
			
			mana = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
			mana.text = [NSString stringWithFormat:@"%d/%d",i.mana,i.maxMana];
			
			
			
		}
	}

	return self;
}

- (void) update{
	
	
}

@end
