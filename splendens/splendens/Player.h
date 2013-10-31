//
//  Player.h
//  splendens
//
//  Created by Guilherme Souza on 10/23/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Player : NSObject

@property (nonatomic) int mana;
@property (nonatomic) int maxMana;
@property (nonatomic) NSString* name;
@property (nonatomic) NSString* playerId;
@property (nonatomic) UIColor* color;
@property (nonatomic) int totalPopulation;
@property (nonatomic) BOOL disconnected;

@end
