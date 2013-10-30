//
//  MyScene.h
//  splendens
//

//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Map.h"
#import "Plug.h"
#import "BottomPainel.h"

// The main scene, for the game itself
@interface GameScene : SKScene <PlugDelegate>

@property (nonatomic) Plug* plug;
@property (nonatomic) Map* map;
@property (nonatomic) BottomPainel* bottomPanel;

// Indicate whether the game is ready and waiting for user movements
@property (nonatomic) BOOL userTurn;

// Store all the turn actions (like upgrades and movements)
// Each element is an instance of a concrete subclass of TurnAction
@property (nonatomic) NSMutableArray* turnActions;

// Create the game map and import the plug
- (void)loadGame:(id)game myId:(NSString*)myId plug:(Plug*)plug;

// Called when this player press the NextTurn button
// Send the user turn to other players
- (void)endMyTurn;

- (void)setUserTurn:(BOOL)userTurn;

- (void)plug:(Plug*)plug hasClosedWithError:(BOOL)error;

- (void)plug:(Plug*)plug receivedMessage:(PlugMsgType)type data:(id)data;

- (void)plugHasConnected:(Plug*)plug;

@end
