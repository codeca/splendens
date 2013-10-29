//
//  InitialViewController.h
//  splendens
//
//  Created by Guilherme Souza on 10/29/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Plug.h"

@interface InitialViewController : UIViewController<PlugDelegate>

@property (weak, nonatomic) IBOutlet UIButton *multiplayButton;
@property (weak, nonatomic) IBOutlet UITextField *nameInput;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (strong, nonatomic) IBOutletCollection(UISwitch) NSArray *playersSwitch;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIProgressView *matchProgress;
@property (nonatomic) Plug* plug;

- (void)plug:(Plug *)plug hasClosedWithError:(BOOL)error;

- (void)plug:(Plug *)plug receivedMessage:(PlugMsgType)type data:(id)data;

- (void)plugHasConnected:(Plug *)plug;

@end
