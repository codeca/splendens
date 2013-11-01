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
@property (nonatomic) CGPoint outside;

@end

@implementation InitialViewController

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	self.matchProgress.progress = 0;
	self.startButton.enabled = NO;
	
	// Load default user name
	NSString* name = [[NSUserDefaults standardUserDefaults] stringForKey:@"name"];
	if (name.length)
		self.nameInput.text = name;
}

- (void)viewDidLayoutSubviews {
	[super viewDidLayoutSubviews];
	float height = MAX(self.prepareMatchView.bounds.size.height, self.waitMatchView.bounds.size.height);
	self.outside = CGPointMake(self.view.center.x, self.view.bounds.size.height+height);
	self.prepareMatchView.center = self.outside;
	self.waitMatchView.center = self.outside;
	self.multiplayButton.center = self.view.center;
}

- (void)startMultiplay {
	[self startMultiplay:nil];
}

- (IBAction)startMultiplay:(id)sender {
	// Start the connection
	self.plug = [Plug plug];
	self.plug.delegate = self;
	[self showPrepareMatch];
}

- (IBAction)startMatching:(id)sender {
	[self.nameInput resignFirstResponder];
	[self showWaitMatch];
	self.name = self.nameInput.text;
	[[NSUserDefaults standardUserDefaults] setObject:self.name forKey:@"name"];
	self.myId = [[NSUUID UUID] UUIDString];
	for (int i=0; i<3; i++) {
		UISwitch* view = self.playersSwitch[i];
		if (view.tag == 2) self.want2 = view.on;
		else if (view.tag == 3) self.want3 = view.on;
		else if (view.tag == 4) self.want4 = view.on;
	}
	NSDictionary* data = @{@"want2": [NSNumber numberWithBool:self.want2],
						   @"want3": [NSNumber numberWithBool:self.want3],
						   @"want4": [NSNumber numberWithBool:self.want4],
						   @"name": self.name,
						   @"id": self.myId};
	[self.plug sendMessage:MSG_SIMPLE_MATCH data:data];
}

- (IBAction)cancelPrepation:(id)sender {
	if (self.plug.readyState == PLUGSTATE_OPEN)
		[self.plug close];
	self.plug = nil;
	[self hidePrepareMatch];
	[self.nameInput resignFirstResponder];
}

- (IBAction)cancelWait:(id)sender {
	if (self.plug.readyState == PLUGSTATE_OPEN)
		[self.plug close];
	self.plug = nil;
	[self hideWaitMatch];
	[self hidePrepareMatch];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	GameViewController* destination = segue.destinationViewController;
	[destination loadGame:sender myId:self.myId plug:self.plug];
}

#pragma mark - animations
- (void)showPrepareMatch {
	[UIView animateWithDuration:1.5 delay:0 usingSpringWithDamping:.7 initialSpringVelocity:0 options:0 animations:^{
		self.prepareMatchView.center = self.view.center;
	} completion:nil];
}
- (void)hidePrepareMatch {
	[UIView animateWithDuration:1.5 delay:0 usingSpringWithDamping:.7 initialSpringVelocity:0 options:0 animations:^{
		self.prepareMatchView.center = self.outside;
	} completion:nil];
}
- (void)showWaitMatch {
	[UIView animateWithDuration:1.5 delay:0 usingSpringWithDamping:.7 initialSpringVelocity:0 options:0 animations:^{
		self.waitMatchView.center = self.view.center;
	} completion:nil];
}
- (void)hideWaitMatch {
	[UIView animateWithDuration:1.5 delay:0 usingSpringWithDamping:.7 initialSpringVelocity:0 options:0 animations:^{
		self.waitMatchView.center = self.outside;
	} completion:nil];
}

#pragma mark - plug delegate

- (void)plug:(Plug *)plug hasClosedWithError:(BOOL)error {
	self.plug = nil;
	[self hideWaitMatch];
	[self hidePrepareMatch];
	self.startButton.enabled = NO;
	[self.nameInput resignFirstResponder];
}

- (void)plug:(Plug *)plug receivedMessage:(PlugMsgType)type data:(id)data {
	if (type == MSG_SIMPLE_MATCH_PROGRESS) {
		int waitingFor2, waitingFor3, waitingFor4;
		float progress2, progress3, progress4, maxProgress;
		waitingFor2 = [data[@"waitingFor2"] integerValue];
		waitingFor3 = [data[@"waitingFor3"] integerValue];
		waitingFor4 = [data[@"waitingFor4"] integerValue];
		progress2 = self.want2 ? waitingFor2/2.0 : 0;
		progress3 = self.want3 ? waitingFor3/3.0 : 0;
		progress4 = self.want4 ? waitingFor4/4.0 : 0;
		maxProgress = progress2 > progress3 ? progress2 : progress3;
		maxProgress = progress4 > maxProgress ? progress4 : maxProgress;
		self.matchProgress.progress = maxProgress;
	} else if (type == MSG_SIMPLE_MATCH_DONE) {
		[self performSegueWithIdentifier:@"startGame" sender:data];
	}
}

- (void)plugHasConnected:(Plug *)plug {
	self.startButton.enabled = YES;
}

@end
