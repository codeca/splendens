//
//  Map.h
//  splendens
//
//  Created by Guilherme Souza on 10/23/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Cell.h"
#import "Player.h"

// Represent the whole map, with all centers and troops
@interface Map : NSObject

@property (nonatomic) int width;
@property (nonatomic) int height;
@property (nonatomic) NSArray* cells;
@property (nonatomic) NSArray* players;

- (id)initWithDefinition:(NSString*)def;

- (Cell*)cellAtX:(int)x y:(int)y;

@end
