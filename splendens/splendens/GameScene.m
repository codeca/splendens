//
//  MyScene.m
//  splendens
//
//  Created by Guilherme Souza on 10/23/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "GameScene.h"

@implementation GameScene

- (void)loadGame:(id)game myId:(NSString*)myId plug:(Plug*)plug {
	// Create the players
	NSArray* gamePlayers = game[@"players"];
	
	int mana = [[game[@"map"] objectForKey:@"mana"] integerValue];
	NSMutableArray* players = [NSMutableArray array];
	NSArray* colors = @[[UIColor redColor], [UIColor greenColor], [UIColor blueColor], [UIColor whiteColor]];
	int me = 0;
	for (int i=0; i<gamePlayers.count; i++) {
		Player* player = [[Player alloc] init];
		NSString* playerId = gamePlayers[i][@"id"];
		player.mana = mana;
		player.color = colors[i];
		player.name = gamePlayers[i][@"name"];
		player.playerId = playerId;
		[players addObject:player];
		if ([playerId isEqualToString:myId])
			me = i;
	}
	self.players = players;
	self.thisPlayer = players[me];
	
	self.map = [[Map alloc] initWithDefinition:game[@"map"] myId:myId game:self];
	[self addChild:self.map];
	
	self.plug = plug;
	plug.delegate = self;
	
	self.bottomPanel = [[BottomPanel alloc] init];
	[self addChild:self.bottomPanel];
	
	self.turnActions = [NSMutableArray array];
	self.userTurn = YES;
}

- (void)setUserTurn:(BOOL)userTurn {
	_userTurn = userTurn;
	self.bottomPanel.nextTurnDisabled = !userTurn;
}

- (void)endMyTurn {
	[self.plug sendMessage:MSG_TURN_DATA data:@{@"player": self.thisPlayer.playerId, @"actions":self.turnActions}];
	self.turnActions = [NSMutableArray array];
	self.userTurn = NO;
}

- (void)sendUserTroop:(NSArray *)path {
	NSMutableArray* path2 = [NSMutableArray array];
	for (Cell* cell in path)
		[path2 addObject:@{@"x": [NSNumber numberWithInt:cell.x], @"y": [NSNumber numberWithInt:cell.y]}];
	NSDictionary* action = @{@"type": [NSNumber numberWithInt:TurnActionSendTroop], @"path": path2};
	[self.turnActions addObject:action];
	
	[self.map sendTroop:path];
}

- (void)upgradeCell:(Cell *)cell toType:(CellType)type {
	TurnActionType actionType;
	
	// Do the upgrade
	if (cell.type == CellTypeBasic) {
		[cell upgradeTo:type];
		if (type == CellTypeCity)
			actionType = TurnActionUpgradeToCity;
		else if (type == CellTypeTower)
			actionType = TurnActionUpgradeToTower;
		else
			actionType = TurnActionUpgradeToLab;
	} else {
		[cell upgrade];
		actionType = TurnActionUpgrade;
	}
	
	// Save the action
	NSDictionary* action = @{@"type": [NSNumber numberWithInt:actionType], @"x": [NSNumber numberWithInt:cell.x], @"y": [NSNumber numberWithInt:cell.y]};
	[self.turnActions addObject:action];
}

- (void)plug:(Plug*)plug hasClosedWithError:(BOOL)error {
	
}

- (void)plug:(Plug*)plug receivedMessage:(PlugMsgType)type data:(id)data {
	NSLog(@"received data, %d moves", ((NSArray*)data).count);
	NSLog(@"%@", data);
}

- (void)plugHasConnected:(Plug*)plug {
	
}

@end
