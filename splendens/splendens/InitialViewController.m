//
//  InitialViewController.m
//  splendens
//
//  Created by Guilherme Souza on 10/29/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "InitialViewController.h"
#import "GameViewController.h"
#import "DebugPlayer.h"
#import "Player.h"

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
@property (nonatomic) CGPoint outside;
@property (nonatomic) BOOL randomMatch;

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
	self.debugButton.hidden = !DEBUG_BUTTON;
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

- (IBAction)startDebug:(id)sender {
	DebugPlayer* temp = [[DebugPlayer alloc] init];
	temp.me = temp;
}

- (IBAction)showCredits:(id)sender {
	[self showView:self.credits];
}
- (IBAction)hideCredits:(id)sender {
	[self hideView:self.credits];
}

- (IBAction)challengeFriend:(id)sender {
	// Start the connection
	self.plug = [MultiPlug multiPlug];
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
	self.plug = [MultiPlug multiPlug];
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
	self.codeLabel.hidden = YES;
	
	NSDictionary* data = @{@"name": self.name, @"level": [NSNumber numberWithInt:Player.level]};
	
	if (self.randomMatch) {
		// Start a random match
		NSMutableArray* wishes = [NSMutableArray array];
		for (int i=0; i<3; i++) {
			UISwitch* view = self.playersSwitch[i];
			if (!view.on)
				continue;
			if (view.tag == ViewTagSwitch2) [wishes addObject:@2];
			else if (view.tag == ViewTagSwitch3) [wishes addObject:@3];
			else if (view.tag == ViewTagSwitch4) [wishes addObject:@4];
		}
		[self.plug startSimpleMatch:data wishes:wishes];
	} else {
		NSString* code = self.codeInput.text;
		if (code.length) {
			// Join a friend match
			[self.plug joinFriendMatch:data withKey:code];
		} else {
			// Start a friend match
			code = [self.plug startFriendMatch:data numPlayers:self.friendsSegment.selectedSegmentIndex+2];
			self.matchProgress.progress = 0;
			self.codeLabel.hidden = NO;
			self.codeLabel.text = [NSString stringWithFormat:@"Tell your friends this code: %@", code];
		}
	}
}

- (IBAction)cancelPrepation:(id)sender {
	[self.plug close];
	self.plug = nil;
	[self hideView:self.prepareMatchView];
	[self.nameInput resignFirstResponder];
	[self.codeInput resignFirstResponder];
}

- (IBAction)cancelWait:(id)sender {
	[self.plug close];
	self.plug = nil;
	[self hideView:self.waitMatchView];
	[self hideView:self.prepareMatchView];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
	GameViewController* destination = segue.destinationViewController;
	[destination loadGame:sender myId:self.plug.myId plug:self.plug];
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

- (void)multiPlugConnected:(MultiPlug*)plug {
	self.startButton.enabled = YES;
}

- (void)multiPlug:(MultiPlug*)plug matchStatus:(float)current max:(float)max {
	self.matchProgress.progress = current/max;
}

- (void)multiPlugFriendMatchNotFound:(MultiPlug*)plug {
	[[[UIAlertView alloc] initWithTitle:@"Error" message:@"Match not found" delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles:nil] show];
	[self cancelWait:nil];
}

- (void)multiPlugFriendMatchCanceled:(MultiPlug*)plug {
	[[[UIAlertView alloc] initWithTitle:@"Error" message:@"Match canceled by the creator" delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles:nil] show];
	[self cancelWait:nil];
}

- (void)multiPlug:(MultiPlug*)plug matched:(NSDictionary*)data {
	[self performSegueWithIdentifier:@"startGame" sender:data];
}

- (void)multiPlugClosedWithError:(MultiPlug*)plug {
	[self hideView:self.waitMatchView];
	[self hideView:self.prepareMatchView];
	self.startButton.enabled = NO;
	[self.nameInput resignFirstResponder];
	[self.codeInput resignFirstResponder];
	[[[UIAlertView alloc] initWithTitle:@"Error" message:@"Connection closed unexpectedly" delegate:nil cancelButtonTitle:@"Continue" otherButtonTitles:nil] show];
}

@end
