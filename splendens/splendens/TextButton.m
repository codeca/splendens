//
//  TextButton.m
//  splendens
//
//  Created by Guilherme Souza on 10/24/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "TextButton.h"

@implementation TextButton

- (id)initWithTexture:(SKTexture *)texture label:(SKLabelNode *)label {
	if (self = [super initWithTexture:texture]) {
		int width = label.frame.size.width;
		int height = label.frame.size.height;
		self.size = CGSizeMake(width+20, height+20);
		self.userInteractionEnabled = YES;
		[self addChild:label];
	}
	return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[self.delegate textButtonClicked:self];
}

@end
