//
//  FakePlayer.h
//  splendens
//
//  Created by Guilherme Souza on 11/1/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

@class FakePlayer;

#import <Foundation/Foundation.h>
#import "Plug.h"

@interface FakePlayer : NSObject<PlugDelegate>

@property (nonatomic) Plug* plug;

- (id)init;

- (void)plug:(Plug *)plug hasClosedWithError:(BOOL)error;
- (void)plug:(Plug *)plug receivedMessage:(PlugMsgType)type data:(id)data;
- (void)plugHasConnected:(Plug *)plug;

@end
