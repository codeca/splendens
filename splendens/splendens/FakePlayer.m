//
//  FakePlayer.m
//  splendens
//
//  Created by Guilherme Souza on 11/1/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "FakePlayer.h"

@implementation FakePlayer

- (id)init {
	if (self = [super init]) {
		self.plug = [[Plug alloc] init];
		self.plug.delegate = self;
	}
	return self;
}

- (void)plug:(Plug *)plug hasClosedWithError:(BOOL)error {
	
}
- (void)plug:(Plug *)plug receivedMessage:(PlugMsgType)type data:(id)data {
	
}
- (void)plugHasConnected:(Plug *)plug {
	NSDictionary* data = @{@"want2": [NSNumber numberWithBool:YES],
						   @"want3": [NSNumber numberWithBool:YES],
						   @"want4": [NSNumber numberWithBool:YES],
						   @"name": @"noob",
						   @"id": [[NSUUID UUID] UUIDString]};
	[plug sendMessage:MSG_SIMPLE_MATCH data:data];
	[NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(closePlug) userInfo:nil repeats:NO];
}
- (void)closePlug {
	[self.plug close];
}

@end
