//
//  MapCell.m
//  splendens
//
//  Created by Guilherme Souza on 10/23/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "Cell.h"

@implementation Cell

- (id)initWithX:(int)x y:(int)y {
	if (self = [super init]) {
		self.x = x;
		self.y = y;
		self.type = CellTypeEmpty;
	}
	return self;
}

@end
