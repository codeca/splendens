//
//  MyScene.h
//  splendens
//

//  Copyright (c) 2013 Codeca. All rights reserved.
//

@class GameScene;

#import <SpriteKit/SpriteKit.h>
#import "Map.h"
#import "Plug.h"
#import "BottomPainel.h"
#import "Player.h"

typedef enum {
	TurnActionSendTroop,
	TurnActionUpgrade,
	TurnActionUpgradeToCity,
	TurnActionUpgradeToTower,
	TurnActionUpgradeToLab
} TurnActionType;

// The main scene, for the game itself
@interface GameScene : SKScene <PlugDelegate>

@property (nonatomic) Plug* plug;
@property (nonatomic) Map* map;
@property (nonatomic) NSArray* players;
@property (nonatomic) Player* thisPlayer;
@property (nonatomic) BottomPainel* bottomPanel;

// Indicate whether the game is ready and waiting for user movements
@property (nonatomic) BOOL userTurn;

// Store all the turn actions (like upgrades and movements)
// Each element is a NSDictionary with the fields described in the project wiki
@property (nonatomic) NSMutableArray* turnActions;

// Create the game map and import the plug
- (void)loadGame:(id)game myId:(NSString*)myId plug:(Plug*)plug;

// Called when this player press the NextTurn button
// Send the user turn to other players
- (void)endMyTurn;

// Send the user troop
// Save the action in turnActions and call sendTroop in the map
- (void)sendUserTroop:(NSArray*)path;

- (void)setUserTurn:(BOOL)userTurn;

- (void)plug:(Plug*)plug hasClosedWithError:(BOOL)error;

- (void)plug:(Plug*)plug receivedMessage:(PlugMsgType)type data:(id)data;

- (void)plugHasConnected:(Plug*)plug;

@end
