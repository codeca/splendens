//
//  MyScene.m
//  splendens
//
//  Created by Guilherme Souza on 10/23/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "GameScene.h"
#import "BottomPainel.h"

@implementation GameScene

- (void)loadGame:(id)game myId:(NSString*)myId plug:(Plug*)plug {
	self.map = [[Map alloc] initWithDefinition:game myId:myId];
	[self addChild:self.map];
	
	self.plug = plug;
	plug.delegate = self;
	
	BottomPainel* bottomPainel = [[BottomPainel alloc] init];
	[self addChild:bottomPainel];
}

- (void)plug:(Plug*)plug hasClosedWithError:(BOOL)error {
	
}

- (void)plug:(Plug*)plug receivedMessage:(PlugMsgType)type data:(id)data {
	
}

- (void)plugHasConnected:(Plug*)plug {
	
}

@end
