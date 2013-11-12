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

// Save the next generated bonus drop
// It's created by addRandomBonus
// Applyed right at the beginning of the next turn
@property (nonatomic) NSDictionary* nextBonus;

@property (nonatomic) NSTimer* timer;

@end

@implementation GameScene

- (void)loadGame:(id)game myId:(NSString*)myId plug:(MultiPlug*)plug {
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
		player.game = self;
		[players addObject:player];
		if ([playerId isEqualToString:myId])
			me = i;
	}
	self.players = players;
	self.connectedPlayers = players.count;
	self.thisPlayer = players[me];
	
	self.map = [[Map alloc] initWithDefinition:game[@"map"] myId:myId game:self];
	self.map.game = self;
	self.map.zPosition = 1;
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
	self.usedPowers = [NSMutableArray array];
	self.userTurn = UserTurn;
	
	self.sounds = [[Sounds alloc]init];
	[self.sounds addMusic:@"sea.wav"];
	[self.sounds addSound:@"seagull.wav"];
	[self.sounds addSound:@"stonelake.aiff"];
	[self.sounds start];
	
	self.timer = [NSTimer scheduledTimerWithTimeInterval:SKIP_TURN_TIME target:self selector:@selector(endThisUserTurn) userInfo:nil repeats:NO];
}

- (void)setUserTurn:(UserTurnState) userTurn {
	_userTurn = userTurn;
	if (userTurn != UserTurn)
		self.bottomPanel.nextTurnDisabled = YES;
	else
		self.bottomPanel.nextTurnDisabled = NO;
}

// Add a random bonus to the strongest neutral cell in the map
- (void)addRandomBonus {
	// Find the strongest neutral cell
	Cell* target = nil;
	int maxStrength = 0;
	for (Cell* cell in self.map.cells) {
		if ([cell isCenter] && !cell.owner && cell.bonus == BonusNone) {
			int strength = cell.population*[Economy armorForType:cell.type level:cell.level];
			if (strength > maxStrength) {
				maxStrength = strength;
				target = cell;
			}
		}
	}
	
	if (target) {
		BonusType bonus = (BonusType)(arc4random_uniform(3)+1);
		NSDictionary* dic = @{@"type": [NSNumber numberWithInteger:TurnActionBonus],
							  @"x": [NSNumber numberWithInteger:target.x],
							  @"y": [NSNumber numberWithInteger:target.y],
							  @"bonus": [NSNumber numberWithInteger:bonus]};
		self.nextBonus = dic;
		[self.turnActions addObject:dic];
	}
}

// Called when the button "Next turn" is pressed
- (void)endMyTurn {
	[self.timer invalidate];
	self.timer = nil;
	
	[self endThisUserTurn];
}

// Called when the user finishs its turn (pressing next turn or turn timeout)
- (void)endThisUserTurn {
	// Try to add a random bonus if it's the first player
	BOOL firstPlayer = NO;
	for (Player* player in self.players)
		if (!player.disconnected) {
			firstPlayer = player==self.thisPlayer;
			break;
		}
	if (firstPlayer && arc4random_uniform(10) == 7)
		[self addRandomBonus];
	
	// Group all actions and send
	[self.plug sendMessage:MSG_TURN_DATA data:self.turnActions];
	
	// Set turn state to done
	self.turnActions = [NSMutableArray array];
	self.usedPowers = [NSMutableArray array];
	self.userTurn = UserWaitPlayers;
	[self.topPanel playerTurnReady:self.thisPlayer];
	
	if (self.othersTurnActions.count >= self.connectedPlayers-1)
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

- (void)applyPowers {
	self.usedPowers = [NSMutableArray array];
	[self checkVictory];
}

- (void)checkVictory {
	Player* winner = nil;
	
	// Avoid checking twice when in a 2-player game, one of them disconnect right after clicking next turn
	if (self.gameEnded)
		return;
	
	for (Player* player in self.players) {
		if (player.totalPopulation > 0 && !player.disconnected) {
			if (!winner)
				winner = player;
			else {
				// No winner yet
				winner = nil;
				break;
			}
		}
	}
	
	if (winner || !self.thisPlayer.totalPopulation) {
		[self.timer invalidate];
		self.timer = nil;
		[self.sounds stop];
		self.gameEnded = YES;
		[self.plug close];
		GameOverScene* nextScene = [[GameOverScene alloc] initWithSize:self.size winner:winner thisPlayer:self.thisPlayer];
		nextScene.viewController = self.viewController;
		[self.view presentScene:nextScene transition:[SKTransition doorwayWithDuration:1.5]];
	} else
		self.userTurn = UserTurn;
}

// Process all users actions in this turn
- (void)simulateTurn {
	// Reset the timer
	self.timer = [NSTimer scheduledTimerWithTimeInterval:SKIP_TURN_TIME target:self selector:@selector(endThisUserTurn) userInfo:nil repeats:NO];
	
	self.userTurn = UserWaitAnimation;
	for (NSDictionary* turnActions in self.othersTurnActions) {
		
		// Process each turn action
		for (NSDictionary* action in turnActions) {
			TurnActionType type = [action[@"type"] integerValue];
			
			if (type == TurnActionPower)
				continue;
			else if (type == TurnActionSendTroop) {
				// Create the path array (each element is a cell)
				NSArray* path = action[@"path"];
				NSMutableArray* path2 = [NSMutableArray array];
				for (NSDictionary* cellDic in path)
					[path2 addObject:[self cellForXY:cellDic]];
				
				[self.map sendTroop:path2];
			} else if (type == TurnActionBonus) {
				self.nextBonus = action;
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
	if (self.nextBonus) {
		int x = [self.nextBonus[@"x"] integerValue];
		int y = [self.nextBonus[@"y"] integerValue];
		BonusType bonus = (BonusType)[self.nextBonus[@"bonus"] integerValue];
		Cell* target = [self.map cellAtX:x y:y];
		target.bonus = bonus;
		self.nextBonus = nil;
	}
	[self.map processTurn];
}

- (Player*)playerById:(NSString*)playerId {
	for (Player* player in self.players)
		if ([player.playerId isEqualToString:playerId])
			return player;
	return nil;
}

- (void)multiPlug:(MultiPlug*)plug receivedMessage:(int)type data:(id)data player:(NSString*)playerId {
	if (type == MSG_TURN_DATA) {
		[self.othersTurnActions addObject:data];
		[self.topPanel playerTurnReady:[self playerById:playerId]];
		if (self.othersTurnActions.count >= self.connectedPlayers-1 && self.userTurn == UserWaitPlayers)
			[self simulateTurn];
	}
	
}

- (void)multiPlugClosedWithError:(MultiPlug*)plug {
	if (!self.gameEnded)
		// If the game has ended, it is normal to have the connection closed
		[self.viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)multiPlug:(MultiPlug*)plug playerDisconnected:(NSString*)player {
	Player* p = [self playerById:player];
	p.disconnected = YES;
	[self.topPanel playerDisconnection:p];
	self.connectedPlayers--;
	if (self.othersTurnActions.count >= self.connectedPlayers-1 && self.userTurn == UserWaitPlayers)
		[self simulateTurn];
}

@end
