//
//  Sounds.h
//  splendens
//
//  Created by Rodolfo Bitu on 07/11/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>

@interface Sounds : SKSpriteNode<AVAudioPlayerDelegate>

//This class hold all musics and sounds you want to play in your application


//Array of URL for all musics you want to play
@property NSMutableArray* musics;

//Array of URL for all sounds you want to play
@property NSMutableArray* sounds;

//Music player
@property AVAudioPlayer* music;

//Sound Player
@property AVAudioPlayer* sound;

//Timer to control sounds
@property NSTimer* timer;

//Ratio to define how often a sound is played
@property int ratio;

//add a Music URL in musics from a string
- (void)addMusic: (NSString*) music;

//add a Sound URL in musics from a string
- (void)addSound: (NSString*) sound;

//Start playing music and sounds
- (void)start;

//Stop music, sounds and timer
- (void)stop;

@end
