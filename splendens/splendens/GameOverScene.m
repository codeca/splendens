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
		float x = self.size.width/2;
		float y = self.size.height/2;
		SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:@"arial"];
		label.text = [NSString stringWithFormat:winner==thisPlayer ? @"You won, %@!" : @"You lose, %@ won", winner.name];
		[self addChild:label];
		label.position = CGPointMake(x, y+30);
		
		TextButton* goBack = [[TextButton alloc] initWithText:@"Try again?"];
		goBack.delegate = self;
		[self addChild:goBack];
		goBack.position = CGPointMake(x, y-30);
	}
	return self;
}

- (void)textButtonClicked:(TextButton *)button {
	InitialViewController* initialView = (InitialViewController*)self.viewController.presentingViewController;
	[self.viewController dismissViewControllerAnimated:YES completion:nil];
	[initialView startMultiplay];
}

@end
