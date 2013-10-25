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
		int x = CGRectGetMidX(self.frame);
		int y = CGRectGetMidY(self.frame);
		
		// Add the multiplayer button
		self.multiplayerButton = [[TextButton alloc] initWithFontNamed:@"arial" text:@"Multiplayer"];
		self.multiplayerButton.position = CGPointMake(x, y+30);
		self.multiplayerButton.delegate = self;
		[self addChild:self.multiplayerButton];
		
		// Add the debug button
		self.debugButton = [[TextButton alloc] initWithFontNamed:@"arial" text:@"Debug"];
		self.debugButton.position = CGPointMake(x, y-30);
		self.debugButton.delegate = self;
		[self addChild:self.debugButton];
	}
	return self;
}

- (void)textButtonClicked:(TextButton *)button {
	if (button == self.multiplayerButton) {
		// TODO
	} else {
		SKView* view = self.view;
		SKScene* scene = [GameScene sceneWithSize:view.bounds.size];
		[view presentScene:scene transition:[SKTransition pushWithDirection:SKTransitionDirectionLeft duration:.5]];
	}
}

@end
