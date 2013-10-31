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
		SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:@"arial"];
		label.text = [NSString stringWithFormat:winner==thisPlayer ? @"You won, %@!" : @"You lost, %@ won", winner.name];
		[self addChild:label];
		
		TextButton* goBack = [[TextButton alloc] initWithText:@"Try again?"];
		goBack.delegate = self;
		[self addChild:goBack];
	}
	return self;
}

- (void)textButtonClicked:(TextButton *)button {
	[self.viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
