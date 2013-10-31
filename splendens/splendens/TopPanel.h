//
//  TopPanel.h
//  splendens
//
//  Created by Rodolfo Bitu on 30/10/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

@class TopPanel;

#import <SpriteKit/SpriteKit.h>
#import "GameScene.h"

@interface TopPanel : SKSpriteNode

@property NSMutableArray* players;

- (id)initWithGame:(GameScene*)game;

- (void)updateMaxMana;

- (void) updateTotalPopulation;

- (void) playerTurnReady: (Player*) player;

- (void) playersTurnReset;

- (void) playerDisconnection: (Player*) player;

@end
