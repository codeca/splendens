//
//  ViewController.m
//  splendens
//
//  Created by Guilherme Souza on 10/23/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"

@implementation GameViewController

- (void)loadGame:(id)game myId:(NSString*)myId plug:(Plug*)plug {
    // Configure the game view
    SKView* view = (SKView*)self.view;
    view.showsFPS = YES;
    
    GameScene* scene = [GameScene sceneWithSize:view.bounds.size];
    [scene loadGame:game myId:myId plug:plug];
	scene.viewController = self;
    [view presentScene:scene];
}

@end
