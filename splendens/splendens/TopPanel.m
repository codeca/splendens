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
#import "PowerButton.h"


@implementation TopPanel


- (id) initWithGame:(GameScene *)game {
	if (self = [super initWithImageNamed:@"topPanel"]){
		self.position = CGPointMake(768/2, (1024+self.size.height+MAP_SIZE+25)/2);
		self.name = @"topPanel";
		int x,y,dx1,dx2,by,dxx;
		dx1 = 15;
		dx2 = 5;
		x = (MAP_SIZE-2*dx1-dx2)/2;
		y = 25;
		by = 115 - 2*dx1 - 2*dx2 - 2*y;
		
		SKSpriteNode* populationBar;
		populationBar = [SKSpriteNode spriteNodeWithColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1] size:CGSizeMake(MAP_SIZE-2*dx1, by)];
		populationBar.position = CGPointMake(0, 115/2 - dx1-by/2);
		populationBar.name = @"populationBar";
		[self addChild:populationBar];
		
		for (Player* i in game.players) {
			int index = [game.players indexOfObject:i];
			
			SKSpriteNode *cell;
			SKLabelNode *name,*mana;
			SKSpriteNode *ready;
			
			float red,green,blue,alpha;
			[i.color getRed:&red green:&green blue:&blue alpha:&alpha];
			UIColor* color = [UIColor colorWithRed:red green:green blue:blue alpha:0.75];
			
			cell = [SKSpriteNode spriteNodeWithColor:color size:CGSizeMake(x,y)];
			cell.position = CGPointMake(-x/2-dx2/2 + (index%2)*(x+dx2), 115/2-dx1-dx2-by-y/2 - (index/2)*(y+dx2));
			cell.name = [NSString stringWithFormat:@"celula%d",index];
			[self addChild:cell];
			
			name  = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
			name.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
			name.text = [NSString stringWithFormat:@"%@ (%d)", i.name, i.level];
			name.name = @"name";
			name.fontSize = 20;
			[cell addChild:name];
			
			mana = [SKLabelNode labelNodeWithFontNamed:@"Arial"];
			mana.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
			mana.text = [NSString stringWithFormat:@"Mana %d/%d",i.mana,i.maxMana];
			mana.name = @"mana";
			mana.fontSize = 20;
			[cell addChild:mana];
			
			ready = [SKSpriteNode spriteNodeWithImageNamed:@"check"];
			ready.name = @"ready";
			ready.alpha = 0;
			[cell addChild:ready];
			
			if (name.frame.size.width+mana.frame.size.width+ready.size.width>cell.frame.size.width) name.text = [i.name substringToIndex:17];
			dxx = (cell.size.width - mana.frame.size.width - name.frame.size.width - ready.size.width)/4;
			ready.position = CGPointMake(-cell.size.width/2+dxx+ready.size.width/2, 0);
			name.position = CGPointMake(-cell.size.width/2+2*dxx+ready.size.width+name.frame.size.width/2, 0);
			mana.position = CGPointMake(-cell.size.width/2+3*dxx+ready.size.width+name.frame.size.width+mana.frame.size.width/2, 0);
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
	BottomPanel* bottomPanel = game.bottomPanel;
	Player* thisPlayer = game.thisPlayer;
	
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
	PowerButton* power;
	if ([Player numAvailablePowers] >= 5 && thisPlayer.mana < [Economy manaCostForPower:PowerConquer]){
		power = bottomPanel.powers[PowerConquer];
		power.disabled = YES;
	}
	if ([Player numAvailablePowers] >= 4 && thisPlayer.mana < [Economy manaCostForPower:PowerNeutralize]){
		power = bottomPanel.powers[PowerNeutralize];
		power.disabled = YES;
	}
	if ([Player numAvailablePowers] >= 3 && thisPlayer.mana < [Economy manaCostForPower:PowerClearMap]){
		power = bottomPanel.powers[PowerClearMap];
		power.disabled = YES;
	}
	if ([Player numAvailablePowers] >= 2 && thisPlayer.mana < [Economy manaCostForPower:PowerDowngrade]){
		power = bottomPanel.powers[PowerDowngrade];
		power.disabled = YES;
	}
	if ([Player numAvailablePowers] >= 1 && thisPlayer.mana < [Economy manaCostForPower:PowerInfect]){
		power = bottomPanel.powers[PowerInfect];
		power.disabled = YES;
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
	for (Troop* troop in map.troops) {
		troop.owner.totalPopulation += troop.amount;
		totalPopulation += troop.amount;
	}
	int	dxbar = 5;
	int lastPosition = 0;
	int lastWidth = 0;
	SKSpriteNode* populationBar = (SKSpriteNode*)[self childNodeWithName:@"populationBar"];
	for (Player* i in game.players){
		NSString* name = [NSString stringWithFormat:@"bar%d",[game.players indexOfObject:i]];
		NSString* lastName;
		if ([game.players indexOfObject:i] > 0){
			lastName = [NSString stringWithFormat:@"bar%d",[game.players indexOfObject:i]-1];
		}
		else lastName = nil;

		SKSpriteNode* bar = (SKSpriteNode*)[populationBar childNodeWithName:name];
		if (lastName == nil){
			[bar runAction: [SKAction moveToX:dxbar-populationBar.size.width/2 duration:0.5]];
			//bar.position = CGPointMake(dxbar-populationBar.size.width/2, 0);
			lastPosition = dxbar - populationBar.size.width/2;
		}
		else{
			[bar runAction:[SKAction moveToX: lastPosition+lastWidth duration:0.5]];
			//bar.position = CGPointMake(lastBar.position.x+lastBar.size.width, 0);
			lastPosition = lastPosition + lastWidth;
		}
		[bar runAction: [SKAction resizeToWidth: (populationBar.size.width-2*dxbar)*i.totalPopulation/totalPopulation duration: 0.5]];
		lastWidth = (populationBar.size.width-2*dxbar)*i.totalPopulation/totalPopulation;
		
		//bar.size = CGSizeMake((populationBar.size.width-2*dxbar)*i.totalPopulation/totalPopulation, populationBar.size.height*5/7);
		
	}
	
	
}

- (void) playerDisconnection: (Player*) player{
	GameScene* game = (GameScene*)self.parent;
	int index = [game.players indexOfObject:player];
	NSString* name = [NSString stringWithFormat:@"celula%d",index];
	SKSpriteNode* cell = (SKSpriteNode*)[self childNodeWithName:name];

	[cell runAction: [SKAction colorizeWithColor:[UIColor colorWithRed:.5 green:.5 blue:.5 alpha:.75] colorBlendFactor:0 duration:0.5]];
}

- (void) playerTurnReady: (Player*) player{
	GameScene* game = (GameScene*)self.parent;
	int index = [game.players indexOfObject:player];
	NSString* name = [NSString stringWithFormat:@"celula%d",index];
	SKSpriteNode* cell = (SKSpriteNode*)[self childNodeWithName:name];
	SKNode* ready = [cell childNodeWithName:@"ready"];
	[ready removeAllActions];
	[ready runAction: [SKAction fadeInWithDuration:0.5]];
	if (player != game.thisPlayer)[ready runAction: [SKAction playSoundFileNamed:@"bell.wav" waitForCompletion:NO]];
}

- (void) playersTurnReset {
	GameScene* game = (GameScene*)self.parent;
	for (int i=0; i<game.players.count; i++) {
		
		NSString* name = [NSString stringWithFormat:@"celula%d", i];
		SKNode* cell = [self childNodeWithName:name];

		SKNode* ready = [cell childNodeWithName:@"ready"];
		[ready removeAllActions];
		[ready runAction: [SKAction fadeOutWithDuration:0.5]];
	}
}

@end
