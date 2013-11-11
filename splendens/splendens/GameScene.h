//
//  MyScene.h
//  splendens
//

//  Copyright (c) 2013 Codeca. All rights reserved.
//

@class GameScene;

#define SKIP_TURN_TIME 60

typedef enum {
	TurnActionSendTroop,
	TurnActionUpgrade,
	TurnActionUpgradeToCity,
	TurnActionUpgradeToTower,
	TurnActionUpgradeToLab,
	TurnActionBonus
} TurnActionType;

// Possible cell bonus
typedef enum {
	BonusNone = 0,
	BonusPopulation,
	BonusArmor,
	BonusSpeed
} BonusType;

#define MSG_TURN_DATA 0

typedef enum{
	UserWaitPlayers = 0,
	UserWaitAnimation,
	UserTurn
} UserTurnState;

#import <SpriteKit/SpriteKit.h>
#import "Map.h"
#import "MultiPlug.h"
#import "BottomPanel.h"
#import "Player.h"
#import "TopPanel.h"
#import "GameOverScene.h"
#import "Economy.h"
#import "Sounds.h"

// The main scene, for the game itself
@interface GameScene : SKScene <MultiPlugDelegate>

@property (nonatomic) MultiPlug* plug;
@property (nonatomic) Map* map;
@property (nonatomic) NSArray* players;
@property (nonatomic) Player* thisPlayer;
@property (nonatomic) int connectedPlayers;
@property (nonatomic) BottomPanel* bottomPanel;
@property (nonatomic) TopPanel* topPanel;

// Indicate whether the game is ready and waiting for user movements
@property (nonatomic) UserTurnState userTurn;

// Store a reference to the view controller to dismiss the segue
@property (nonatomic, weak) UIViewController* viewController;

// Store all the turn actions (like upgrades and movements)
// Each element is a NSDictionary with the fields described in the project wiki
@property (nonatomic) NSMutableArray* turnActions;

// Store all received user turn actions
// Each element is a NSDictionary returned by the server
@property (nonatomic) NSMutableArray* othersTurnActions;

@property Sounds* sounds;

// Create the game map and import the plug
- (void)loadGame:(id)game myId:(NSString*)myId plug:(MultiPlug*)plug;

// Called when this player press the NextTurn button
// Send the user turn to other players
- (void)endMyTurn;

// Send the user troop
// The action MUST be valid
// Save the action in turnActions and call sendTroop in the map
- (void)sendUserTroop:(NSArray*)path;

// Upgrade the given user cell to given type (ignore if the cell is not a basic cell)
// The action MUST be valid
// Save the action in turnActiond and call upgrade in the cell
- (void)upgradeCell:(Cell*)cell toType:(CellType)type;

// Check if someone won the game
// If it does, go to game over scene
- (void)checkVictory;

- (void)setUserTurn:(UserTurnState)userTurn;

- (void)multiPlug:(MultiPlug*)plug receivedMessage:(int)type data:(id)data player:(NSString*)playerId;

- (void)multiPlugClosedWithError:(MultiPlug*)plug;

- (void)multiPlug:(MultiPlug*)plug playerDisconnected:(NSString*)player;

@end
