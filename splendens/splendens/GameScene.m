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
	
	self.bottomPanel = [[BottomPainel alloc] init];
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
	self.userTurn = NO;
}

- (void)plug:(Plug*)plug hasClosedWithError:(BOOL)error {
	
}

- (void)plug:(Plug*)plug receivedMessage:(PlugMsgType)type data:(id)data {
	
}

- (void)plugHasConnected:(Plug*)plug {
	
}

@end
