//
//  PowerButton.h
//  splendens
//
//  Created by Guilherme Souza on 11/18/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

@class PowerButton;

#import "TextButton.h"

@interface PowerButton : TextButton

// Indicate whether this power has already been used
@property (nonatomic) BOOL used;

- (void)setUsed:(BOOL)used;

@end
