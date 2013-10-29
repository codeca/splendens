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

- (void)viewDidLoad {
    [super viewDidLoad];

    // Configure the game view
    SKView* skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    GameScene* scene = [GameScene sceneWithSize:skView.bounds.size];
	scene.gameStructure = self.gameStructure;
	scene.myId = self.myId;
    [skView presentScene:scene];
}

@end
