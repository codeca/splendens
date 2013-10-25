//
//  TextButton.h
//  splendens
//
//  Created by Guilherme Souza on 10/24/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class TextButton;

@protocol TextButtonDelegate <NSObject>

- (void)textButtonClicked:(TextButton*)button;

@end

@interface TextButton : SKSpriteNode

@property (nonatomic, weak) id<TextButtonDelegate> delegate;

- (id)initWithLabel:(SKLabelNode*)label;
- (id)initWithLabel:(SKLabelNode*)label size:(CGSize)size;

@end
