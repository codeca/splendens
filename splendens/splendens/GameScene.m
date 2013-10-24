//
//  MyScene.m
//  splendens
//
//  Created by Guilherme Souza on 10/23/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "GameScene.h"

@implementation GameScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
		Map* map = [[Map alloc] initWithDefinition:@"{\"size\": 15, \"players\": [{\"mana\": 3}, {\"mana\": 14}, {\"mana\": 15}], \"cells\": [{\"x\": 0, \"y\": 1, \"type\": 1}, {\"x\": 2, \"y\": 3, \"type\": 2, \"owner\": 0, \"population\": 17}, {\"x\": 4, \"y\":5, \"type\": 5, \"owner\": 2, \"population\": 27, \"level\": 2}]}"];
		[self addChild:map];
		
		SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:@"arial"];
		label.text = @"A button, yep!";
		TextButton* bt = [[TextButton alloc] initWithTexture:[SKTexture textureWithImageNamed:@"wall4"] label:label];
		bt.position = CGPointMake(350, 512);
		bt.delegate = self;
		[self addChild:bt];
    }
    return self;
}

- (void)textButtonClicked:(TextButton*)button {
	NSLog(@"U clicked me!");
}

-(void)update:(CFTimeInterval)currentTime {
	
}

@end
