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

// Create the game scene from the given game structure (return from the server), player id and server connection
- (void)loadGame:(id)game myId:(NSString*)myId plug:(Plug*)plug;

@end
