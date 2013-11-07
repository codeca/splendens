//
//  Sounds.h
//  splendens
//
//  Created by Rodolfo Bitu on 07/11/13.
//  Copyright (c) 2013 Codeca. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>

@interface Sounds : SKSpriteNode

@property NSMutableArray* musics;
@property NSMutableArray* sounds;
@property AVAudioPlayer* music;
@property AVAudioPlayer* sound;

-(void) addMusic: (NSURL*) url;
-(void) addSound: (NSURL*) url;


@end
