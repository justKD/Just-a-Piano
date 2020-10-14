//
//  NNKeyboard.h
//
//  Created by Cady Holmes.
//  Copyright (c) 2015 Cady Holmes.
//

#import <UIKit/UIKit.h>
#import "OBShapedButton.h"

@protocol NNKeyboardDelegate;
@interface NNKeyboard : UIControl <UIGestureRecognizerDelegate>
{
@protected
    //UIScrollView *keyboard;
    BOOL scrollable;
    int lowestNote;
}

@property (nonatomic, weak) id<NNKeyboardDelegate> delegate;

@property (nonatomic, strong) UIScrollView *keyboard;

@property (nonatomic) BOOL hidesNumbers;
@property (nonatomic) BOOL shouldDoCoolAnimation;
@property (nonatomic) float value;
@property (nonatomic) float borderSize;
@property (nonatomic) float roundness;
@property (nonatomic) float startupAnimationDuration;
@property (nonatomic) uint visibleKeys;
@property (nonatomic) uint octaves;
@property (nonatomic) uint touchesForScroll;
@property (nonatomic) uint lowestOctave;
//@property (nonatomic) UIControlEvents touchBehavior;
@property (nonatomic) UIColor *borderColor;
@property (nonatomic) UIColor *bgColor;
@property (nonatomic, strong) NSMutableArray *currentTouches;
@property (nonatomic, strong) NSMutableArray *currentButtons;
@property (nonatomic, strong) NSMutableArray *currentNotes;
@property (nonatomic, strong) NSMutableArray *currentLoc;

- (void)scrollTo:(float)octave withAnimation:(BOOL)animated;
- (void)drawKeyboard;
- (void)setNumberTouchesForScroll:(int)num;
- (void)setLocked:(BOOL)locked;

@end

@protocol NNKeyboardDelegate <NSObject>
- (void)keyboardTouchDownEvent:(NNKeyboard*)keyboard;
- (void)keyboardTouchUpEvent:(NNKeyboard*)keyboard;
- (void)keyboardTouchMovedEvent:(NNKeyboard*)keyboard;
@end


