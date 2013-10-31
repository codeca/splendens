//
//  GameOverScene.h
//  splendens
//
//  Created by Guilherme Souza on 10/31/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Player.h"
#import "TextButton.h"
#import "InitialViewController.h"

@interface GameOverScene : SKScene<TextButtonDelegate>

// Store a reference to the view controller to dismiss the segue
@property (nonatomic, weak) UIViewController* viewController;

- (id)initWithSize:(CGSize)size winner:(Player*)winner thisPlayer:(Player*)thisPlayer;

@end
