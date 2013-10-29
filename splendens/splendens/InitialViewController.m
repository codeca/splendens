//
//  InitialViewController.m
//  splendens
//
//  Created by Guilherme Souza on 10/29/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "InitialViewController.h"
#import "GameViewController.h"

@interface InitialViewController ()

@property (nonatomic) NSString* name;
@property (nonatomic) NSString* myId;
@property (nonatomic) BOOL want2;
@property (nonatomic) BOOL want3;
@property (nonatomic) BOOL want4;
@property (nonatomic) BOOL debug;

@end

@implementation InitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	self.matchProgress.progress = 0;
	self.nameInput.text = @"sitegui";
	NSLog(@"Press multiplayer");
}

- (IBAction)startMultiplay:(id)sender {
	// Start the connection
	self.plug = [Plug plug];
	self.plug.delegate = self;
}

- (IBAction)continueMatching:(id)sender {
	self.name = self.nameInput.text;
	self.myId = [[NSUUID UUID] UUIDString];
	NSLog(@"Choose number of players and press start");
}

- (IBAction)startMatching:(id)sender {
	self.want2 = ((UISwitch*)self.playersSwitch[0]).on;
	self.want3 = ((UISwitch*)self.playersSwitch[1]).on;
	self.want4 = ((UISwitch*)self.playersSwitch[2]).on;
	NSDictionary* data = @{@"want2": [NSNumber numberWithBool:self.want2],
						   @"want3": [NSNumber numberWithBool:self.want3],
						   @"want4": [NSNumber numberWithBool:self.want4],
						   @"name": self.name,
						   @"id": self.myId};
	[self.plug sendMessage:MSG_SIMPLE_MATCH data:data];
	NSLog(@"Wait");
}

- (IBAction)startDebug:(id)sender {
	self.debug = YES;
	if (!self.plug) {
		self.plug = [Plug plug];
		self.plug.delegate = self;
	}
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	GameViewController* destination = segue.destinationViewController;
	destination.gameStructure = sender;
	destination.myId = self.myId;
	destination.plug = self.plug;
}

- (void)plug:(Plug *)plug hasClosedWithError:(BOOL)error {
	NSLog(@"Server runned away :(");
	self.plug = nil;
}

- (void)plug:(Plug *)plug receivedMessage:(PlugMsgType)type data:(id)data {
	if (type == MSG_SIMPLE_MATCH_PROGRESS) {
		int waitingFor2, waitingFor3, waitingFor4;
		float progress2, progress3, progress4, maxProgress;
		waitingFor2 = [data[@"waitingFor2"] integerValue];
		waitingFor3 = [data[@"waitingFor2"] integerValue];
		waitingFor4 = [data[@"waitingFor2"] integerValue];
		progress2 = self.want2 ? waitingFor2/2.0 : 0;
		progress3 = self.want3 ? waitingFor3/3.0 : 0;
		progress4 = self.want4 ? waitingFor4/4.0 : 0;
		maxProgress = progress2 > progress3 ? progress2 : progress3;
		maxProgress = progress4 > maxProgress ? progress4 : maxProgress;
		self.matchProgress.progress = maxProgress;
	} else if (type == MSG_SIMPLE_MATCH_DONE) {
		[self performSegueWithIdentifier:@"startGame" sender:data];
	} else if (type == MSG_DEBUG) {
		NSMutableArray* players = [NSMutableArray array];
		int numPlayers = [data[@"players"] integerValue];
		self.myId = [[NSUUID UUID] UUIDString];
		for (int i=0; i<numPlayers; i++)
			[players addObject:@{@"name": @"sitegui", @"id": i ? [[NSUUID UUID] UUIDString] : self.myId}];
		NSDictionary* data2 = @{@"map": data, @"players": players};
		[self performSegueWithIdentifier:@"startGame" sender:data2];
	}
}

- (void)plugHasConnected:(Plug *)plug {
	NSLog(@"Input your name and press continue");
	
	if (self.debug)
		[self.plug sendMessage:MSG_DEBUG data:[NSNull null]];
}

@end
