//
//  MultiPlug.h
//
//  Created by Guilherme Souza on 10/17/13.

#import <Foundation/Foundation.h>

@class MultiPlug;

// External host to get the server local ip
// sitegui.com.br will work for free
#define MULTIPLUG_EXTERNAL_HOST @"http://sitegui.com.br/multiPlug"

// Port to connect to
#define MULTIPLUG_PORT 8081

// Show information about connections and matching in the console
#define MULTIPLUG_DEBUG YES

@protocol MultiPlugDelegate <NSObject>

@optional

// Called when the connection is open and ready for matching (MULTIPLUGSTATE_OPEN)
- (void)multiPlugConnected:(MultiPlug*)plug;

// Inform the match status
// current/max are values for the more progressed match
- (void)multiPlug:(MultiPlug*)plug matchStatus:(float)current max:(float)max;

// Called when a joinFriendMatch fails to find the match
- (void)multiPlugFriendMatchNotFound:(MultiPlug*)plug;

// Called when a friend match is canceled by the owner
- (void)multiPlugFriendMatchCanceled:(MultiPlug*)plug;

// Called when a match is successfully created
// data contains all the match data sent by the server
// By default, it only has one key "players": a NSArray in which all elements are
// NSDictionary with two keys:
// "data" (the custom value set at the beginning of the match) and
// "id" (a unique string to identify each player)
- (void)multiPlug:(MultiPlug*)plug matched:(NSDictionary*)data;

// Called whenever any player sends a message (in a game)
// type and data are the same sent by the original player
// playerId is the player id (as present in the players array in the initial match data)
- (void)multiPlug:(MultiPlug*)plug receivedMessage:(int)type data:(id)data player:(NSString*)playerId;

// Called whenever a player in the same game room disconnects
- (void)multiPlug:(MultiPlug*)plug playerDisconnected:(NSString*)player;

// Called when the connection has closed with error
- (void)multiPlugClosedWithError:(MultiPlug*)plug;

@end

typedef enum {
	MULTIPLUGSTATE_CONNECTING,
	MULTIPLUGSTATE_OPEN,
	MULTIPLUGSTATE_MATCHING,
	MULTIPLUGSTATE_INGAME,
	MULTIPLUGSTATE_CLOSED
} MultiPlugState;

@interface MultiPlug : NSObject <NSStreamDelegate>

@property (nonatomic) MultiPlugState state;
@property (nonatomic) NSString* myId;
@property (nonatomic, weak) id<MultiPlugDelegate> delegate;

// Return a new plug and start connecting
+ (MultiPlug*)multiPlug;

// Create a new plug and start connecting
- (id)init;

// Start a simple match
// player is any object to send to all player after the match (can be nil)
// wishes represent the desired number of players in a game
// Example of wishes: @[@2, @3] : accept a game with 2 or 3 players
- (void)startSimpleMatch:(id)playerData wishes:(NSArray*)wishes;

// Start a match with friends
// Return the key (5-char string) this player should tell his friends
- (NSString*)startFriendMatch:(id)playerData numPlayers:(int)num;

// Try to join a match created by a friend
- (void)joinFriendMatch:(id)playerData withKey:(NSString*)key;

// Send a given message to all players (in a game)
// type and data will be delivered to everybody's delegate
// data is anything that can be transformed into JSON
// don't use a negative type
- (void)sendMessage:(int)type data:(id)data;

// Close the given connection and prevent future messages to be processed
// If this player is in a friend match process created by himself, it will be canceled
- (void)close;

@end
