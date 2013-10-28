//
//  BottomPainel.h
//  splendens
//
//  Created by Rodolfo Bitu on 25/10/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "Cell.h"
#import "TextButton.h"

@interface BottomPainel : SKSpriteNode<TextButtonDelegate>

@property (nonatomic) SKNode* table;
@property (nonatomic) TextButton* upgradeButton;
@property (nonatomic) TextButton* nextTurn;

- (void) update: (Cell*)selectedCell;
- (void)textButtonClicked:(TextButton *)button;

@end
