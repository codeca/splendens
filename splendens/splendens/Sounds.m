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
	return self;
}

- (void)addMusic: (NSURL*) url{
	[self.musics addObject:url];
}

- (void)addSound: (NSURL*) url{
	[self.sounds addObject:url];
}

- (void)start{
	//TO DO: pega uma musica
	[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(check) userInfo:nil repeats:NO];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
	if (player == self.music){
		//TO DO: pega musica nova
	}
}

- (void)check{
	if (self.sound.playing == NO){
		if (arc4random()%60 == 0 && self.sounds.count > 0){
			
			//TO DO: pega um som
		}
	}
	//NSString * backgroundPath = [[NSBundle mainBundle] pathForResource:@"sea" ofType:@"wav"];
	//NSURL * pathURL = [[NSURL alloc] initFileURLWithPath:backgroundPath];
	//self.music = [[AVAudioPlayer alloc] initWithContentsOfURL: pathURL error: nil];
	//self.music.numberOfLoops = -1;
	//[self.music play];
}


@end
