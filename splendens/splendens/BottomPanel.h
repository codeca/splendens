//
//  BottomPanel.h
//  splendens
//
//  Created by Rodolfo Bitu on 25/10/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

@class BottomPanel;

#import <SpriteKit/SpriteKit.h>
#import "Cell.h"
#import "TextButton.h"
#import "Powers.h"
#import "PowerButton.h"

@interface BottomPanel : SKSpriteNode<TextButtonDelegate>

@property (nonatomic) SKNode* table;
@property (nonatomic) TextButton* upgradeButton;
@property (nonatomic) TextButton* nextTurn;
@property (nonatomic) SKSpriteNode* powerBar;
@property (nonatomic) BOOL nextTurnDisabled;
@property (nonatomic) PowerType selectedPower;
@property (nonatomic) NSMutableArray* powers;
- (void)update;

- (void)textButtonClicked:(TextButton *)button;

- (void)setNextTurnDisabled:(BOOL)nextTurnDisabled;

// Remove all cooldowns and re-enable all powers to be used
// Called right before the powers are applyed
- (void)resetPowerBar;

// Tell the power bar the current power was used
- (void)usePower;

@end
