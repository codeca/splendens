//
//  Sounds.m
//  splendens
//
//  Created by Rodolfo Bitu on 07/11/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import "Sounds.h"

@implementation Sounds

- (id)init{
	self.musics = [[NSMutableArray alloc] init];
	self.sounds = [[NSMutableArray alloc] init];
	self.ratio = 60;
	return self;
}

- (void)addMusic: (NSString*) music{
	NSString * backgroundPath = [[NSBundle mainBundle] pathForResource:music ofType:nil];
	NSURL * pathURL = [[NSURL alloc] initFileURLWithPath:backgroundPath];
	[self.musics addObject:pathURL];
}

- (void)addSound: (NSString*) sound{
	NSString * backgroundPath = [[NSBundle mainBundle] pathForResource:sound ofType:nil];
	NSURL * pathURL = [[NSURL alloc] initFileURLWithPath:backgroundPath];
	[self.sounds addObject:pathURL];
}

- (void)start{
	int index;
	if (self.musics.count > 0){
		index = arc4random_uniform(self.musics.count);
		self.music = [[AVAudioPlayer alloc] initWithContentsOfURL:self.musics[index] error:nil];
		[self.music play];
	}
	
	self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(check) userInfo:nil repeats:YES];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
	if (player == self.music){
		int index;
		if (self.musics.count > 0){
			index = arc4random_uniform(self.musics.count);
			self.music = [[AVAudioPlayer alloc] initWithContentsOfURL:self.musics[index] error:nil];
			[self.music play];
		}
	}
}

- (void)check{
	if (self.sound == nil || self.sound.playing == NO){
		if (arc4random_uniform(self.ratio) == 0 && self.sounds.count > 0){
			int index;
			if (self.sounds.count > 0){
				index = arc4random_uniform(self.sounds.count);
				self.sound = [[AVAudioPlayer alloc]initWithContentsOfURL:self.sounds[index] error:nil];
				[self.sound play];
			}
		}
	}
	if (self.music == nil){
		int index;
		if (self.musics.count > 0){
			index = arc4random_uniform(self.musics.count);
			self.music = [[AVAudioPlayer alloc] initWithContentsOfURL:self.musics[index] error:nil];
			[self.music play];
		}
	}
	//NSString * backgroundPath = [[NSBundle mainBundle] pathForResource:@"sea" ofType:@"wav"];
	//NSURL * pathURL = [[NSURL alloc] initFileURLWithPath:backgroundPath];
	//self.music = [[AVAudioPlayer alloc] initWithContentsOfURL: pathURL error: nil];
	//self.music.numberOfLoops = -1;
	//[self.music play];
}

- (void)stop{
	if (self.music != nil){
		[self.music stop];
	}
	if (self.sound != nil){
		[self.sound stop];
	}
	[self.timer invalidate];
	
}


@end
