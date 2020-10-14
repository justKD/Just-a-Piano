//
//  NNPiano.h
//
//  Created by Cady Holmes on 10/20/15.
//  Copyright © 2015 Cady Holmes. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NNKeyboard.h"
#import "SoundBankPlayer.h"

@interface NNPiano : UIView {
//    NNKeyboard *kb;
//    SoundBankPlayer *soundBankPlayer;
}

@property (nonatomic) BOOL animate;
@property (nonatomic) NNKeyboard *keys;
@property (nonatomic) SoundBankPlayer *soundBankPlayer;
@property (nonatomic) float gain;

- (instancetype)initWithFrame:(CGRect)frame andSoundBank:(NSString*)soundBank;
- (void)redraw;
- (void)setLocked:(BOOL)locked;
- (void)scrollTo:(float)octave withAnimation:(BOOL)animated;
- (void)setSoundBank:(NSString*)soundBankName;


- (void)tearDown;
+ (void)stopAudioSession;

@end
