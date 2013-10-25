//
//  InitialScene.h
//  splendens
//
//  Created by Guilherme Souza on 10/24/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "TextButton.h"
#import "Plug.h"

// The initial scene, to present the start game button
@interface InitialScene : SKScene<TextButtonDelegate, PlugDelegate>

@property (nonatomic) TextButton* multiplayerButton;
@property (nonatomic) TextButton* debugButton;
@property (nonatomic) Plug* plug;

@end