//
//  GameOverScene.m
//  splendens
//
//  Created by Guilherme Souza on 10/31/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "GameOverScene.h"

@implementation GameOverScene

- (id)initWithSize:(CGSize)size winner:(Player*)winner thisPlayer:(Player*)thisPlayer {
	if (self = [super initWithSize:size]) {
		CGPoint middle = CGPointMake(self.size.width/2, self.size.height/2);
		SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:@"arial"];
		label.text = [NSString stringWithFormat:winner==thisPlayer ? @"You won, %@!" : @"You lost, %@ won", winner.name];
		[self addChild:label];
		label.position = middle;
		
		TextButton* goBack = [[TextButton alloc] initWithText:@"Try again?"];
		goBack.delegate = self;
		[self addChild:goBack];
		goBack.position = middle;
	}
	return self;
}

- (void)textButtonClicked:(TextButton *)button {
	[self.viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
