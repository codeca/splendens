//
//  AppDelegate.m
//  splendens
//
//  Created by Guilherme Souza on 10/23/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch
	
	// Set the default value for this player level
	[[NSUserDefaults standardUserDefaults] registerDefaults:@{@"level": @1}];
	
    return YES;
}

@end
