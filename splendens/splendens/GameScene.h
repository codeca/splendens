//
//  MyScene.h
//  splendens
//

//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Map.h"
#import "Plug.h"

// The main scene, for the game itself
@interface GameScene : SKScene <PlugDelegate>

@property (nonatomic) Plug* plug;
@property (nonatomic) Map* map;

- (void)loadGame:(id)game myId:(NSString*)myId plug:(Plug*)plug;

- (void)plug:(Plug*)plug hasClosedWithError:(BOOL)error;

- (void)plug:(Plug*)plug receivedMessage:(PlugMsgType)type data:(id)data;

- (void)plugHasConnected:(Plug*)plug;

@end
