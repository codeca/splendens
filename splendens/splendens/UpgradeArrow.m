//
//  UpgradeArrow.m
//  splendens
//
//  Created by Rodolfo Bitu on 24/10/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "UpgradeArrow.h"

@implementation UpgradeArrow

- (id) init: (int) a{
	if (self = [super initWithImageNamed:@"beta"]){
		self.size = CGSizeMake(a,a/2);
	}
	return self;
}



@end
