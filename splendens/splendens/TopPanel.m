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
#import "Map.h"
#import "Economy.h"


@implementation TopPanel


- (id) initWithGame:(GameScene *)game {
	if (self = [super initWithImageNamed:@"topPanel"]){
		self.position = CGPointMake(768/2, (1024+self.size.height+MAP_SIZE+25)/2);
		self.name = @"topPanel";
		int x,y,dx1,dx2,by,dxx,dxbar;
		dx1 = 15;
		dx2 = 5;
		x = (MAP_SIZE-2*dx1-dx2)/2;
		y = 25;
		by = 115 - 2*dx1 - 2*dx2 - 2*y;
		dxbar = 5;
		
		SKSpriteNode* populationBar;
		populationBar = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1] size:CGSizeMake(MAP_SIZE-2*dx1, by)];
		populationBar.position = CGPointMake(0, 115/2 - dx1-by/2);
		populationBar.name = @"populationBar";
		[self addChild:populationBar];
		
		for (Player* i in game.players) {
			int index = [game.players indexOfObject:i];
			
			SKSpriteNode *cell;
			SKLabelNode *name,*mana;
			
			float red,green,blue,alpha;
			[i.color getRed:&red green:&green blue:&blue alpha:&alpha];
			UIColor* color = [UIColor colorWithRed:red green:green blue:blue alpha:0.75];
			
			cell = [SKSpriteNode spriteNodeWithColor:color size:CGSizeMake(x,y)];
			cell.position = CGPointMake(-x/2-dx2/2 + ((int)index/2)*(x+dx2), 115/2-dx1-dx2-by-y/2 - index%2*(y+dx2));
			cell.name = [NSString stringWithFormat:@"celula%d",index];
			[self addChild:cell];
			
			name  = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
			name.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
			name.text = i.name;
			name.name = @"name";
			name.fontSize = 20;
			[cell addChild:name];
			
			mana = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
			mana.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
			mana.text = [NSString stringWithFormat:@"Mana %d/%d",i.mana,i.maxMana];
			mana.name = @"mana";
			mana.fontSize = 20;
			[cell addChild:mana];

			if (name.frame.size.width+mana.frame.size.width+2>cell.frame.size.width) name.text = [i.name substringToIndex:17];
			dxx = (cell.size.width - mana.frame.size.width - name.frame.size.width)/3;
			name.position = CGPointMake(-cell.size.width/2+dxx+name.frame.size.width/2, 0);
			mana.position = CGPointMake(cell.size.width/2-dxx-mana.frame.size.width/2, 0);
		}
		
		for (Player* i in game.players){
			SKSpriteNode* bar;
			bar = [SKSpriteNode spriteNodeWithColor:i.color size:CGSizeMake(0, populationBar.size.height*5/7)];
			bar.anchorPoint = CGPointMake(0, 0.5);
			bar.name = [NSString stringWithFormat:@"bar%d",[game.players indexOfObject:i]];
			[populationBar addChild: bar];
		}
	}
	
	return self;
}

- (void) updateMaxMana{
	GameScene* game = (GameScene*) self.parent;
	Map* map = game.map;
	
	for (Player* i in game.players){
		i.maxMana = 10;
	}
	for (Cell* i in map.cells) {
		if (i.type == CellTypeLab && i.owner != nil){
			i.owner.maxMana += [Economy bonusMaxManaForLabLevel:i.level];
		}
	}
	
	for (Player* i in game.players){
		int index = [game.players indexOfObject:i];
		
		SKSpriteNode *cell = (SKSpriteNode*)[self childNodeWithName:[NSString stringWithFormat:@"celula%d",index]];
		SKLabelNode *mana = (SKLabelNode*)[cell childNodeWithName:[NSString stringWithFormat:@"mana"]];
		mana.text = [NSString stringWithFormat:@"Mana %d/%d",i.mana,i.maxMana];
	}
}

- (void) updateTotalPopulation{
	GameScene* game = (GameScene*)self.parent;
	Map* map = game.map;
	int totalPopulation = 0;
	
	for (Player* i in game.players){
		i.totalPopulation = 0;
	}
	for (Cell* i in map.cells) {
		if (i.owner != nil){
			i.owner.totalPopulation += i.population;
			totalPopulation += i.population;
		}
	}
	int	dxbar = 5;
	SKSpriteNode* populationBar = (SKSpriteNode*)[self childNodeWithName:@"populationBar"];
	for (Player* i in game.players){
		NSString* name = [NSString stringWithFormat:@"bar%d",[game.players indexOfObject:i]];
		NSString* lastName;
		if ([game.players indexOfObject:i] > 0){
			lastName = [NSString stringWithFormat:@"bar%d",[game.players indexOfObject:i]-1];
		}
		else lastName = nil;

		SKSpriteNode* bar = (SKSpriteNode*)[populationBar childNodeWithName:name];
		SKSpriteNode* lastBar;
		if (lastName == nil){
			[bar runAction: [SKAction moveToX:dxbar-populationBar.size.width/2 duration:0.5]];
			//bar.position = CGPointMake(dxbar-populationBar.size.width/2, 0);
		}
		else{
			lastBar = (SKSpriteNode*)[populationBar childNodeWithName:lastName];
			[bar runAction:[SKAction moveToX: lastBar.position.x+lastBar.size.width duration:0.5]];
			//bar.position = CGPointMake(lastBar.position.x+lastBar.size.width, 0);
		}
		[bar runAction: [SKAction resizeToWidth: (populationBar.size.width-2*dxbar)*i.totalPopulation/totalPopulation duration: 0.5]];
		
		//bar.size = CGSizeMake((populationBar.size.width-2*dxbar)*i.totalPopulation/totalPopulation, populationBar.size.height*5/7);
		
	}
	
	
}


@end
