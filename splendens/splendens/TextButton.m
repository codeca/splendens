//
//  TextButton.m
//  splendens
//
//  Created by Guilherme Souza on 10/24/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "TextButton.h"

@implementation TextButton

- (id)initWithFontNamed:(NSString *)fontName text:(NSString *)text {
	if (self = [super initWithImageNamed:@"greenButton"]) {
		// Create the text label
		SKLabelNode* label = [SKLabelNode labelNodeWithFontNamed:fontName];
		label.text = text;
		label.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
		
		self.centerRect = CGRectMake(18./36, 18./36, 0./36, 0./36); // Not working, why?
		self.size = CGSizeMake(label.frame.size.width+30, label.frame.size.height+10);
		self.userInteractionEnabled = YES;
		[self addChild:label];
	}
	return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[self.delegate textButtonClicked:self];
}

@end
