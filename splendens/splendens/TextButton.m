//
//  TextButton.m
//  splendens
//
//  Created by Guilherme Souza on 10/24/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "TextButton.h"

@implementation TextButton

- (id)initWithLabel:(SKLabelNode *)label size:(CGSize)size {
	if (self = [super initWithImageNamed:@"greenButton"]) {
		self.centerRect = CGRectMake(18./36, 18./36, 0./36, 0./36);
		self.size = size;
		self.userInteractionEnabled = YES;
		[self addChild:label];
	}
	return self;
}

- (id)initWithLabel:(SKLabelNode *)label {
	label.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
	return [self initWithLabel:label size:CGSizeMake(label.frame.size.width+50, label.frame.size.height+20)];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[self.delegate textButtonClicked:self];
}

@end
