//
//  InitialViewController.h
//  splendens
//
//  Created by Guilherme Souza on 10/29/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>
#import "Plug.h"
#import "AnimatedBackgroundScene.h"

@interface InitialViewController : UIViewController<PlugDelegate>

@property (weak, nonatomic) IBOutlet UIView *prepareMatchView;
@property (weak, nonatomic) IBOutlet UIView *waitMatchView;
@property (weak, nonatomic) IBOutlet UITextField *nameInput;
@property (weak, nonatomic) IBOutlet UITextField *codeInput;
@property (strong, nonatomic) IBOutletCollection(UISwitch) NSArray *playersSwitch;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIProgressView *matchProgress;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *buttons;
@property (weak, nonatomic) IBOutlet UIView *credits;
@property (weak, nonatomic) IBOutlet UILabel *codeLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *friendsSegment;
@property (nonatomic) Plug* plug;


- (void)plug:(Plug *)plug hasClosedWithError:(BOOL)error;

- (void)plug:(Plug *)plug receivedMessage:(PlugMsgType)type data:(id)data;

- (void)plugHasConnected:(Plug *)plug;

@end
