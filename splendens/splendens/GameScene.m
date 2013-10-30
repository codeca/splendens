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
	self.map = [[Map alloc] initWithDefinition:game myId:myId];
	[self addChild:self.map];
	
	self.plug = plug;
	plug.delegate = self;
	
	self.bottomPanel = [[BottomPainel alloc] init];
	[self addChild:self.bottomPanel];
	
	self.userTurn = YES;
}

- (void)setUserTurn:(BOOL)userTurn {
	_userTurn = userTurn;
	self.bottomPanel.nextTurnDisabled = !userTurn;
}

- (void)endMyTurn {
	NSMutableArray* actions = [NSMutableArray array];
	// TODO: store the actions
	NSDictionary* data = @{@"player": self.map.thisPlayer.playerId, @"actions":actions};
	[self.plug sendMessage:MSG_TURN_DATA data:data];
	
	self.userTurn = NO;
}

- (void)plug:(Plug*)plug hasClosedWithError:(BOOL)error {
	
}

- (void)plug:(Plug*)plug receivedMessage:(PlugMsgType)type data:(id)data {
	
}

- (void)plugHasConnected:(Plug*)plug {
	
}

@end
