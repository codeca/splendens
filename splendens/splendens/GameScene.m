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
	
	self.topPanel = [[TopPanel alloc] initWithGame:self];
	[self addChild:self.topPanel];
	
	self.turnActions = [NSMutableArray array];
	self.othersTurnActions = [NSMutableArray array];
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
	if (self.othersTurnActions.count == self.players.count-1)
		[self simulateTurn];
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

// Return the cell in the x and y position given by the dictionary
- (Cell*)cellForXY:(NSDictionary*)dic {
	int x = [dic[@"x"] integerValue];
	int y = [dic[@"y"] integerValue];
	return [self.map cellAtX:x y:y];
}

// Process all users actions in this turn
- (void)simulateTurn {
	for (NSDictionary* turnActions in self.othersTurnActions) {
		NSArray* actions = turnActions[@"actions"];
		
		// Process each turn action
		for (NSDictionary* action in actions) {
			TurnActionType type = [action[@"type"] integerValue];
			
			if (type == TurnActionSendTroop) {
				// Create the path array (each element is a cell)
				NSArray* path = action[@"path"];
				NSMutableArray* path2 = [NSMutableArray array];
				for (NSDictionary* cellDic in path)
					[path2 addObject:[self cellForXY:cellDic]];
				
				[self.map sendTroop:path2];
			} else {
				Cell* cell = [self cellForXY:action];
				if (type == TurnActionUpgrade)
					[cell upgrade];
				else if (type == TurnActionUpgradeToCity)
					[cell upgradeTo:CellTypeCity];
				else if (type == TurnActionUpgradeToTower)
					[cell upgradeTo:CellTypeTower];
				else
					[cell upgradeTo:CellTypeLab];
			}
		}
	}
	self.othersTurnActions = [NSMutableArray array];
	self.userTurn = YES;
	[self.topPanel update];
}

- (void)plug:(Plug*)plug hasClosedWithError:(BOOL)error {
	
}

- (void)plug:(Plug*)plug receivedMessage:(PlugMsgType)type data:(id)data {
	if (type == MSG_TURN_DATA) {
		[self.othersTurnActions addObject:data];
		if (self.othersTurnActions.count == self.players.count-1 && !self.userTurn)
			[self simulateTurn];
	}
}

- (void)plugHasConnected:(Plug*)plug {
	
}

@end
