//
//  PowerButton.m
//  splendens
//
//  Created by Guilherme Souza on 11/18/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "PowerButton.h"

@implementation PowerButton

- (id)initWithImage:(NSString *)image {
	if (self = [super initWithImage:image])
		self.color = [UIColor blackColor];
	return self;
}

- (void)setDisabled:(BOOL)disabled {
	if (_disabled != disabled){
		[self removeActionForKey:@"disabled"];
		[self runAction:[SKAction colorizeWithColorBlendFactor:disabled ? .25 : 0 duration:.5] withKey:@"disabled"];
		_disabled = disabled;
	}
}

@end
