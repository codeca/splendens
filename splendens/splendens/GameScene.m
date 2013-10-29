//
//  MyScene.m
//  splendens
//
//  Created by Guilherme Souza on 10/23/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "GameScene.h"
#import "UpgradeArrow.h"
#import "BottomPainel.h"

@implementation GameScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {

    }
    return self;
}

- (void)didMoveToView:(SKView *)view {
	Map* map = [[Map alloc] initWithDefinition:self.gameStructure myId:self.myId];
	BottomPainel* bottomPainel = [[BottomPainel alloc]init];
	[self addChild:map];
	[self addChild:bottomPainel];
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
