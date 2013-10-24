//
//  PathFinder.h
//  splendens
//
//  Created by Rodolfo Bitu on 24/10/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Cell.h"
#import "Map.h"

@interface PathFinder : NSObject

+ (NSArray*) findPathwithStart: (Cell*)start andGoal: (Cell*)goal andMap: (Map*) map;

@end
