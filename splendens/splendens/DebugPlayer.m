//
//  DebugPlayer.m
//  splendens
//
//  Created by Guilherme Souza on 11/12/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "DebugPlayer.h"

@interface DebugPlayer()

@property (nonatomic) MultiPlug* plug;

@end

@implementation DebugPlayer

- (id)init {
	if (self = [super init]) {
		self.me = self;
		self.plug = [[MultiPlug alloc] init];
		self.plug.delegate = self;
	}
	return self;
}

- (void)multiPlugConnected:(MultiPlug*)plug {
	[self.plug startSimpleMatch:@{@"name": @"quiter", @"level": @1} wishes:@[@2, @3, @4]];
}

- (void)multiPlug:(MultiPlug*)plug matched:(NSDictionary*)data {
	[self.plug close];
	self.me = nil;
}

@end
