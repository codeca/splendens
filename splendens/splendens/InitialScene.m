//
//  InitialScene.m
//  splendens
//
//  Created by Guilherme Souza on 10/24/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "InitialScene.h"
#import "GameScene.h"

@implementation InitialScene

- (id)initWithSize:(CGSize)size {
	if (self = [super initWithSize:size]) {
		SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:@"arial"];
		label.text = @"Multiplayer";
		self.multiplayerButton = [[TextButton alloc] initWithLabel:label];
		self.multiplayerButton.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
		self.multiplayerButton.delegate = self;
		[self addChild:self.multiplayerButton];
	}
	return self;
}

- (void)textButtonClicked:(TextButton *)button {
	SKView* view = self.view;
	SKScene* scene = [GameScene sceneWithSize:view.bounds.size];
	[view presentScene:scene transition:[SKTransition pushWithDirection:SKTransitionDirectionLeft duration:.5]];
}

@end
