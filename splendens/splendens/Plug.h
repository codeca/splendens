//
//  Plug.h
//  splendens
//
//  Created by Guilherme Souza on 10/17/13.
//  Copyright (c) 2013 Codeca. All rights reserved.

#import <Foundation/Foundation.h>

typedef enum {
	MSG_DEBUG = -2,
	MSG_PLAYER_DISCONNECTED = -1,
	MATCH_TYPE_UNKNOW = 0,
	MATCH_TYPE_SIMPLE = 1,
	MATCH_TYPE_FRIEND = 2,
	MSG_SIMPLE_MATCH = -100,
	MSG_SIMPLE_MATCH_PROGRESS = -101,
	MSG_SIMPLE_MATCH_DONE = -102,
	MSG_FRIEND_MATCH_START = -200,
	MSG_FRIEND_MATCH_JOIN = -201,
	MSG_FRIEND_MATCH_NOT_FOUND = -202,
	MSG_FRIEND_MATCH_PROGRESS = -203,
	MSG_FRIEND_MATCH_DONE = -204,
	MSG_FRIEND_MATCH_CANCELED = -205
} PlugMsgType;

@class Plug;

@protocol PlugDelegate <NSObject>

// Called whenever the server sends a message
- (void)plug:(Plug*)plug receivedMessage:(PlugMsgType)type data:(id)data;

// Called when the connection is open and ready
- (void)plugHasConnected:(Plug*)plug;

// Called when the connection has closed or could not connect
- (void)plug:(Plug*)plug hasClosedWithError:(BOOL)error;

@end

typedef enum {
	PLUGSTATE_CONNECTING,
	PLUGSTATE_OPEN,
	PLUGSTATE_CLOSED
} PlugState;

@interface Plug : NSObject <NSStreamDelegate>

@property (nonatomic) PlugState readyState;
@property (nonatomic, weak) id<PlugDelegate> delegate;

// Create a new Plug and start connecting
- (id)init;

// Send a given message to the server
// data is anything that can be transformed into JSON
- (void)sendMessage:(PlugMsgType)type data:(id)data;

// Close the given connection and prevent future messages to be processed
- (void)close;

@end
