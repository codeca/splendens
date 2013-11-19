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
		if (winner)
			label.text = [NSString stringWithFormat:winner==thisPlayer ? @"You won, %@!" : @"You lose, %@ won", winner.name];
		else
			label.text = @"You lose";
		[self addChild:label];
		label.position = CGPointMake(x, y+60);
		
		// Control level progression
		if (winner == thisPlayer) {
			BOOL upgraded = [Player saveWin];
			int level = Player.level;
			int wins = Player.currentWins;
			int neededWins = Player.neededWins;
			SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:@"arial"];
			if (upgraded)
				label.text = [NSString stringWithFormat:@"Congratulations, now you've reached level %d!", level];
			else
				label.text = [NSString stringWithFormat:@"%d more wins to reach level %d", neededWins-wins, level+1];
			label.position = CGPointMake(x, y);
			[self addChild:label];
		}
		
		TextButton* goBack = [[TextButton alloc] initWithText:@"Try again?"];
		goBack.delegate = self;
		[self addChild:goBack];
		goBack.position = CGPointMake(x, y-60);
	}
	return self;
}

- (void)textButtonClicked:(TextButton *)button {
	[self.viewController dismissViewControllerAnimated:YES completion:nil];
}

@end
