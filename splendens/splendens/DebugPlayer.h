//
//  DebugPlayer.h
//  splendens
//
//  Created by Guilherme Souza on 11/12/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MultiPlug.h"

@interface DebugPlayer : NSObject<MultiPlugDelegate>

@property (nonatomic) DebugPlayer* me;

@end
