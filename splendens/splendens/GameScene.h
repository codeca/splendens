//
//  MyScene.h
//  splendens
//

//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Map.h"
#import "TextButton.h"
#import "Plug.h"

// The main scene, for the game itself
@interface GameScene : SKScene <TextButtonDelegate>

@property (nonatomic) id gameStructure;
@property (nonatomic) Plug* plug;
@property (nonatomic) NSString* myId;

@end
