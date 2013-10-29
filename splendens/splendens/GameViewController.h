//
//  ViewController.h
//  splendens
//

//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "Plug.h"

@interface GameViewController : UIViewController

@property (nonatomic) id gameStructure;
@property (nonatomic) NSString* myId;
@property (nonatomic) Plug* plug;

@end
