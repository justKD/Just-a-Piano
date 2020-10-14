//
//  NNPiano.m
//
//  Created by Cady Holmes on 10/20/15.
//  Copyright © 2015 Cady Holmes. All rights reserved.
//

#import "NNPiano.h"

@implementation NNPiano

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self makeSoundBankPlayer];
        [self makeKeys];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame andSoundBank:(NSString*)soundBank
{
    self = [super initWithFrame:frame];
    if (self) {
        [self makeSoundBankPlayer];
        [self setSoundBank:soundBank];
        [self makeKeys];
    }
    return self;
}

- (void)didMoveToSuperview {
    [self addSubview:self.keys];
}

- (void)redraw {
    [self.keys drawKeyboard];
}

- (void)makeKeys {
    self.keys = [[NNKeyboard alloc] initWithFrame:self.bounds];
    [self.keys addTarget:self action:@selector(handleKB:) forControlEvents:UIControlEventValueChanged];
    if (self.animate) {
        self.keys.shouldDoCoolAnimation = YES;
        self.keys.startupAnimationDuration = .4;
    } else {
       self.keys.shouldDoCoolAnimation = NO;
    }
    self.keys.lowestOctave = 1;
    self.keys.octaves = 9;
    self.keys.roundness = 0;
    self.keys.visibleKeys = 10;
    self.gain = 0.5;

    [self.keys setNumberTouchesForScroll:2];
}

- (void)scrollTo:(float)octave withAnimation:(BOOL)animated {
    [self.keys scrollTo:octave withAnimation:animated];
}

- (void)setLocked:(BOOL)locked {
    [self.keys setLocked:locked];
}

- (void)handleKB:(NNKeyboard *)sender {
    [self.soundBankPlayer noteOn:sender.value gain:self.gain];
}

- (void)setSoundBank:(NSString*)soundBankName {
     [self.soundBankPlayer setSoundBank:soundBankName];
}

- (void)makeSoundBankPlayer {
    self.soundBankPlayer = [[SoundBankPlayer alloc] init];
    //[self.soundBankPlayer setSoundBank:@"Piano"];
}

- (void)tearDown {
    [self.soundBankPlayer tearDown];
}

+ (void)stopAudioSession {
    [SoundBankPlayer stopAudio];
}

@end
