//
//  MyScene.m
//  splendens
//
//  Created by Guilherme Souza on 10/23/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "GameScene.h"

@interface GameScene()

@property (nonatomic) BOOL gameEnded;

@end

@implementation GameScene

- (void)loadGame:(id)game myId:(NSString*)myId plug:(Plug*)plug {
	// Create the players
	NSArray* gamePlayers = game[@"players"];
	
	int mana = [[game[@"map"] objectForKey:@"mana"] integerValue];
	NSMutableArray* players = [NSMutableArray array];
	NSArray* colors = @[[UIColor redColor], [UIColor greenColor], [UIColor blueColor], [UIColor orangeColor]];
	int me = 0;
	for (int i=0; i<gamePlayers.count; i++) {
		Player* player = [[Player alloc] init];
		NSString* playerId = gamePlayers[i][@"id"];
		player.mana = mana;
		player.maxMana = 10;
		player.totalPopulation = 0;
		player.color = colors[i];
		player.name = gamePlayers[i][@"name"];
		player.playerId = playerId;
		[players addObject:player];
		if ([playerId isEqualToString:myId])
			me = i;
	}
	self.players = players;
	self.connectedPlayers = players.count;
	self.thisPlayer = players[me];
	
	self.map = [[Map alloc] initWithDefinition:game[@"map"] myId:myId game:self];
	[self addChild:self.map];
	
	self.plug = plug;
	plug.delegate = self;
	
	self.bottomPanel = [[BottomPanel alloc] init];
	[self addChild:self.bottomPanel];
	
	self.topPanel = [[TopPanel alloc] initWithGame:self];
	[self addChild:self.topPanel];
	
	//update maxMana and totalPopulation on load
	[self.topPanel updateMaxMana];
	[self.topPanel updateTotalPopulation];
	
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
	[self.topPanel playerTurnReady:self.thisPlayer];
	if (self.othersTurnActions.count == self.connectedPlayers-1)
		[self simulateTurn];
}

- (void)sendUserTroop:(NSArray *)path {
	NSMutableArray* path2 = [NSMutableArray array];
	for (Cell* cell in path)
		[path2 addObject:@{@"x": [NSNumber numberWithInt:cell.x], @"y": [NSNumber numberWithInt:cell.y]}];
	NSDictionary* action = @{@"type": [NSNumber numberWithInt:TurnActionSendTroop], @"path": path2};
	[self.turnActions addObject:action];
	
	[self.map sendTroop:path];
	
	//update total pop after sending troops
	[self.topPanel updateTotalPopulation];
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
	
	//update total pop after upgrading
	[self.topPanel updateTotalPopulation];
	
	//update Max Mana after upgrading
	[self.topPanel updateMaxMana];
}

// Return the cell in the x and y position given by the dictionary
- (Cell*)cellForXY:(NSDictionary*)dic {
	int x = [dic[@"x"] integerValue];
	int y = [dic[@"y"] integerValue];
	return [self.map cellAtX:x y:y];
}

- (void)checkVictory {
	Player* winner = nil;
	
	// Check if there is only 1 connected player with cells
	for (Cell* cell in self.map.cells) {
		if (cell.type != CellTypeEmpty && cell.type != CellTypeWall && cell.owner && !cell.owner.disconnected) {
			if (!winner)
				winner = cell.owner;
			else if (winner != cell.owner) {
				// No winner yet
				winner = nil;
				break;
			}
		}
	}
	
	if (winner || !self.thisPlayer.totalPopulation) {
		self.gameEnded = YES;
		[self.plug close];
		GameOverScene* nextScene = [[GameOverScene alloc] initWithSize:self.size winner:winner thisPlayer:self.thisPlayer];
		nextScene.viewController = self.viewController;
		[self.view presentScene:nextScene transition:[SKTransition doorwayWithDuration:1.5]];
	} else
		self.userTurn = YES;
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
	
	// Reset all player turnReady flags
	[self.topPanel playersTurnReset];
	
	[self.map processTurn];
}

- (void)plug:(Plug*)plug hasClosedWithError:(BOOL)error {
	if (!self.gameEnded)
		// If the game has ended, it is normal to have the connection closed
		[self.viewController dismissViewControllerAnimated:YES completion:nil];
}

- (Player*)playerById:(NSString*)playerId {
	for (Player* player in self.players)
		if ([player.playerId isEqualToString:playerId])
			return player;
	return nil;
}

- (void)plug:(Plug*)plug receivedMessage:(PlugMsgType)type data:(id)data {
	if (type == MSG_TURN_DATA) {
		[self.othersTurnActions addObject:data];
		[self.topPanel playerTurnReady:[self playerById:data[@"player"]]];
		if (self.othersTurnActions.count == self.connectedPlayers-1 && !self.userTurn)
			[self simulateTurn];
	} else if (type == MSG_PLAYER_DISCONNECTED) {
		Player* player = [self playerById:data];
		player.disconnected = YES;
		[self.topPanel playerDisconnection:player];
		self.connectedPlayers--;
	}
}

- (void)plugHasConnected:(Plug*)plug {
	
}

@end
