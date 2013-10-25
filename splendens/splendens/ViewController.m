//
//  ViewController.m
//  splendens
//
//  Created by Guilherme Souza on 10/23/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "ViewController.h"
#import "GameScene.h"
#import "InitialScene.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Configure the game view
    SKView* skView = (SKView *)self.view;
    skView.showsFPS = YES;
    skView.showsNodeCount = YES;
    
    SKScene* scene = [InitialScene sceneWithSize:skView.bounds.size];
    [skView presentScene:scene];
}

@end
