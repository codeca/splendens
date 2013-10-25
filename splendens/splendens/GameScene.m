//
//  MyScene.m
//  splendens
//
//  Created by Guilherme Souza on 10/23/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "GameScene.h"
#import "UpgradeArrow.h"


@implementation GameScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {

    }
    return self;
}

- (void)didMoveToView:(SKView *)view {
	Map* map = [[Map alloc] initWithDefinition:self.gameStructure];
	[self addChild:map];
	
}

- (void)textButtonClicked:(TextButton*)button {
	NSLog(@"U clicked me!");
}

- (void)UpgradeArrowClicked:(TextButton*)button {
	NSLog(@"U clicked me2!");
}


-(void)update:(CFTimeInterval)currentTime {
	
}

@end
