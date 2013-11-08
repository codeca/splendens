//
//  InitialViewController.m
//  splendens
//
//  Created by Guilherme Souza on 10/29/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "InitialViewController.h"
#import "GameViewController.h"

// Tag values for view in the storyboard
enum {
	ViewTagSwitch2 = 2,
	ViewTagSwitch3,
	ViewTagSwitch4,
	ViewTagRandomMatch,
	ViewTagFriendMatch
};

@interface InitialViewController ()

@property (nonatomic) NSString* name;
@property (nonatomic) NSString* myId;
@property (nonatomic) BOOL want2;
@property (nonatomic) BOOL want3;
@property (nonatomic) BOOL want4;
@property (nonatomic) CGPoint outside;
@property (nonatomic) BOOL randomMatch;
@property (nonatomic) BOOL expectPlugClose; // flag if the plug was asked to closed by the controller it self

@end

@implementation InitialViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	for (UIButton* button in self.buttons)
		[InitialViewController prepareButton:button];
	SKView* view = [[SKView alloc] initWithFrame:self.view.bounds];
	[self.view insertSubview:view atIndex:0];
    AnimatedBackgroundScene* scene = [AnimatedBackgroundScene sceneWithSize:view.bounds.size];
    [view presentScene:scene];
	
	
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
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
	self.credits.center = self.outside;
}

- (IBAction)showCredits:(id)sender {
	[self showView:self.credits];
}
- (IBAction)hideCredits:(id)sender {
	[self hideView:self.credits];
}

- (IBAction)challengeFriend:(id)sender {
	// Start the connection
	self.plug = [Plug plug];
	self.plug.delegate = self;
	
	// Show the view
	[self showView:self.prepareMatchView];
	[self.prepareMatchView viewWithTag:ViewTagRandomMatch].hidden = YES;
	[self.prepareMatchView viewWithTag:ViewTagFriendMatch].hidden = NO;
	self.randomMatch = NO;
	self.codeInput.text = @"";
}

- (IBAction)startMultiplay:(id)sender {
	// Start the connection
	self.plug = [Plug plug];
	self.plug.delegate = self;
	
	// Show the view
	[self showView:self.prepareMatchView];
	[self.prepareMatchView viewWithTag:ViewTagRandomMatch].hidden = NO;
	[self.prepareMatchView viewWithTag:ViewTagFriendMatch].hidden = YES;
	self.randomMatch = YES;
}

- (IBAction)startMatching:(id)sender {
	[self.nameInput resignFirstResponder];
	[self.codeInput resignFirstResponder];
	[self showView:self.waitMatchView];
	self.matchProgress.progress = 0;
	self.name = self.nameInput.text;
	[[NSUserDefaults standardUserDefaults] setObject:self.name forKey:@"name"];
	self.myId = [[NSUUID UUID] UUIDString];
	self.codeLabel.hidden = YES;
	
	if (self.randomMatch) {
		// Start a random match
		for (int i=0; i<3; i++) {
			UISwitch* view = self.playersSwitch[i];
			if (view.tag == ViewTagSwitch2) self.want2 = view.on;
			else if (view.tag == ViewTagSwitch3) self.want3 = view.on;
			else if (view.tag == ViewTagSwitch4) self.want4 = view.on;
		}
		NSDictionary* data = @{@"want2": [NSNumber numberWithBool:self.want2],
							   @"want3": [NSNumber numberWithBool:self.want3],
							   @"want4": [NSNumber numberWithBool:self.want4],
							   @"name": self.name,
							   @"id": self.myId};
		[self.plug sendMessage:MSG_SIMPLE_MATCH data:data];
	} else {
		NSString* code = self.codeInput.text;
		if (code.length) {
			// Join a friend match
			[self.plug sendMessage:MSG_FRIEND_MATCH_JOIN data:@{@"key": [self.codeInput.text uppercaseString],
																@"name": self.name,
																@"id": self.myId}];
		} else {
			// Start a friend match
			NSString* alphabet = @"ABCDEFGHJKMNPQRSTUVWXYZ23456789";
			NSMutableString* code = [NSMutableString string];
			for (int i=0; i<5; i++)
				[code appendString:[alphabet substringWithRange:NSMakeRange(arc4random_uniform(alphabet.length), 1)]];
			NSNumber* players = [NSNumber numberWithInt:self.friendsSegment.selectedSegmentIndex+2];
			
			[self.plug sendMessage:MSG_FRIEND_MATCH_START data:@{@"key": code,
																 @"players": players,
																 @"name": self.name,
																 @"id": self.myId}];
			self.matchProgress.progress = 1.0/[players floatValue];
			self.codeLabel.hidden = NO;
			self.codeLabel.text = [NSString stringWithFormat:@"Tell your friends this code: %@", code];
		}
	}
}

- (IBAction)cancelPrepation:(id)sender {
	if (self.plug.readyState == PLUGSTATE_OPEN) {
		self.expectPlugClose = YES;
		[self.plug close];
	}
	self.plug = nil;
	[self hideView:self.prepareMatchView];
	[self.nameInput resignFirstResponder];
	[self.codeInput resignFirstResponder];
}

- (IBAction)cancelWait:(id)sender {
	if (self.plug.readyState == PLUGSTATE_OPEN) {
		self.expectPlugClose = YES;
		[self.plug close];
	}
	self.plug = nil;
	[self hideView:self.waitMatchView];
	[self hideView:self.prepareMatchView];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	GameViewController* destination = segue.destinationViewController;
	[destination loadGame:sender myId:self.myId plug:self.plug];
}

+ (void)prepareButton:(UIButton*)button {
	static UIImage* buttonBackground;
	if (!buttonBackground)
			buttonBackground = [[UIImage imageNamed:@"greenButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(18, 18, 18, 18)];
	[button setBackgroundImage:buttonBackground forState:UIControlStateNormal];
	[button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
}

#pragma mark - animations
- (void)showView:(UIView*)view {
	[UIView animateWithDuration:1.5 delay:0 usingSpringWithDamping:.7 initialSpringVelocity:0 options:0 animations:^{
		view.center = self.view.center;
	} completion:nil];
}
- (void)hideView:(UIView*)view {
	[UIView animateWithDuration:1.5 delay:0 usingSpringWithDamping:.7 initialSpringVelocity:0 options:0 animations:^{
		view.center = self.outside;
	} completion:nil];
}

#pragma mark - plug delegate

- (void)plug:(Plug *)plug hasClosedWithError:(BOOL)error {
	[self hideView:self.waitMatchView];
	[self hideView:self.prepareMatchView];
	self.startButton.enabled = NO;
	[self.nameInput resignFirstResponder];
	[self.codeInput resignFirstResponder];
	if (!self.expectPlugClose) {
		[[[UIAlertView alloc] initWithTitle:@"Error" message:@"Connection closed unexpectedly" delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles:nil] show];
	}
	self.expectPlugClose = NO;
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
	} else if (type == MSG_FRIEND_MATCH_NOT_FOUND) {
		[[[UIAlertView alloc] initWithTitle:@"Error" message:@"Match not found" delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles:nil] show];
		[self cancelWait:nil];
	} else if (type == MSG_FRIEND_MATCH_PROGRESS) {
		float wanted, waiting;
		wanted = [data[@"wanted"] floatValue];
		waiting = [data[@"waiting"] floatValue];
		self.matchProgress.progress = waiting/wanted;
	} else if (type == MSG_FRIEND_MATCH_CANCELED) {
		[[[UIAlertView alloc] initWithTitle:@"Error" message:@"Match canceled by the creator" delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles:nil] show];
		[self cancelWait:nil];
	} else if (type == MSG_FRIEND_MATCH_DONE) {
		[self performSegueWithIdentifier:@"startGame" sender:data];
	}
}

- (void)plugHasConnected:(Plug *)plug {
	self.startButton.enabled = YES;
}

@end
