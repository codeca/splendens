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

@property (weak, nonatomic) IBOutlet UIView *prepareMatchView;
@property (weak, nonatomic) IBOutlet UIView *waitMatchView;
@property (weak, nonatomic) IBOutlet UIButton *multiplayButton;
@property (weak, nonatomic) IBOutlet UITextField *nameInput;
@property (strong, nonatomic) IBOutletCollection(UISwitch) NSArray *playersSwitch;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIProgressView *matchProgress;
@property (nonatomic) Plug* plug;

- (void)startMultiplay;

- (void)plug:(Plug *)plug hasClosedWithError:(BOOL)error;

- (void)plug:(Plug *)plug receivedMessage:(PlugMsgType)type data:(id)data;

- (void)plugHasConnected:(Plug *)plug;

@end
