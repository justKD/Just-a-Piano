//
//  NNKeyboard.m
//
//  Created by Cady Holmes.
//  Copyright (c) 2015 Cady Holmes.
//

#import "NNKeyboard.h"

@implementation NNKeyboard {
    int tag;
    NSMutableArray *allTheKeys;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setDefaults];
    }
    return self;
}

- (void)setDefaults {
    
    CGRect keyboardRect = self.bounds;
    self.backgroundColor = [UIColor clearColor];
    
    self.octaves = 9;
    self.lowestOctave = 2;
    self.visibleKeys = keyboardRect.size.width/37.5;
    
    self.borderSize = 2;
    self.roundness = 0;
    self.borderColor =[UIColor blackColor];
    self.bgColor = [UIColor grayColor];
    self.hidesNumbers = NO;
    
    self.touchesForScroll = 1;
//    self.touchBehavior = UIControlEventTouchDown;
    self.startupAnimationDuration = 3;
    self.shouldDoCoolAnimation = YES;
    
    self.currentTouches = [[NSMutableArray alloc] init];
    self.currentButtons = [[NSMutableArray alloc] init];
    self.currentNotes = [[NSMutableArray alloc] init];
    self.currentLoc = [[NSMutableArray alloc] init];
    
    self.multipleTouchEnabled = YES;
}

- (void)didMoveToSuperview {
    [self drawKeyboard];
}
//- (void)drawRect:(CGRect)rect {
//    [self drawKeyboard];
//}

- (void)setNumberTouchesForScroll:(int)num {
    if (num < 1) {
        self.touchesForScroll = 100;
    } else  {
        self.touchesForScroll = num;
    }
    
    for (UIGestureRecognizer *gestureRecognizer in self.keyboard.gestureRecognizers) {
        if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
            UIPanGestureRecognizer *panGR = (UIPanGestureRecognizer *) gestureRecognizer;
            panGR.minimumNumberOfTouches = self.touchesForScroll;
            panGR.maximumNumberOfTouches = self.touchesForScroll;
        }
    }
}

- (void)drawKeyboard {
    BOOL animate;
    if (!self.keyboard) {
        animate = YES;
    } else {
        [self.keyboard removeFromSuperview];
        animate = NO;
    }
    
    CGRect keyboardRect = self.bounds;
    
    CGFloat keyboardHeight = keyboardRect.size.height;
    CGFloat keyboardWidth = keyboardRect.size.width;
    
    CGFloat keyboardYOrigin = keyboardRect.origin.y;
    CGFloat keyboardXOrigin = keyboardRect.origin.x;
    
    CGFloat whiteKeyWidth = keyboardWidth/self.visibleKeys;
    CGFloat blackKeyWidth = keyboardWidth*(.56/self.visibleKeys);
    CGFloat blackKeyHeight = keyboardHeight *.58;
    
    CGFloat blackKeyOffset = 0.3/self.visibleKeys;
    
    lowestNote = self.lowestOctave*12;
    //self.layer.borderWidth = 0;
    //self.layer.cornerRadius = self.roundess;
    //self.layer.borderColor = self.color.CGColor;
    //self.layer.backgroundColor = [UIColor clearColor].CGColor;
    
    UIImage *left = [UIImage imageNamed:@"leftKey.png"];
    UIImage *center = [UIImage imageNamed:@"centerKey.png"];
    UIImage *right = [UIImage imageNamed:@"rightKey.png"];
    UIImage *black = [UIImage imageNamed:@"blackKey.png"];
    
    // Make two arrays of the entire keyboard (white keys and black keys separately).
    // These arrays hold the correct button image for white keys, and the correct X-position modifier for black keys.
    // This is due to it being a non-symmetrical layout, so the arrays of white and black keys are also non-symmetrical.
    // Also make corresponding arrays of midi note values to use as tags.
    //
    
    // White key array
    NSArray *cde = [[NSArray alloc] initWithObjects:left, center, right, nil];
    NSArray *fgab = [[NSArray alloc] initWithObjects:left, center, center, right, nil];
    NSMutableArray *keyboardWhiteButtonArray = [[NSMutableArray alloc] init];
    
    for (int i = 1; i < ((2*self.octaves)+1); i++) {
        if (i % 2 == 0) {
            [keyboardWhiteButtonArray addObjectsFromArray:fgab];
        } else {
            [keyboardWhiteButtonArray addObjectsFromArray:cde];
        }
    }
    
    // Black key array
    NSArray *blackKeyTemp = [[NSArray alloc] initWithObjects: @1, @2, @4, @5, @6,  nil];
    NSMutableArray *keyboardBlackButtonArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.octaves; i++) {
        
        for (NSNumber *num in blackKeyTemp) {
            int newNum = [num intValue]+(7*i);
            [keyboardBlackButtonArray addObject:[NSNumber numberWithInt:newNum]];
        }
    }
    
    // White key midi array
    NSArray *whiteMidiTemp = [[NSArray alloc] initWithObjects: @0, @2, @4, @5, @7, @9, @11,nil];
    NSMutableArray *whiteKeyMidi = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.octaves; i++) {
        for (NSNumber *num in whiteMidiTemp) {
            int newNum = lowestNote+([num intValue]+(12*i));
            [whiteKeyMidi addObject:[NSNumber numberWithInt:newNum]];
        }
    }
    
    // Black key midi array
    NSArray *blackMidiTemp = [[NSArray alloc] initWithObjects:@1, @3, @6, @8, @10, nil];
    NSMutableArray *blackKeyMidi = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.octaves; i++) {
        for (NSNumber *num in blackMidiTemp) {
            int newNum = lowestNote+([num intValue]+(12*i));
            [blackKeyMidi addObject:[NSNumber numberWithInt:newNum]];
        }
    }
    
    // Draw the scrollview to contain the keyboard and give it enough size for the keyboard.
    CGRect scrollViewRect = CGRectMake(keyboardXOrigin, keyboardYOrigin, keyboardWidth, keyboardHeight);
    self.keyboard = [[UIScrollView alloc] initWithFrame:scrollViewRect];
    self.keyboard.contentSize = CGSizeMake(keyboardWhiteButtonArray.count*whiteKeyWidth, self.keyboard.frame.size.height);
    self.keyboard.multipleTouchEnabled = YES;
    self.keyboard.layer.borderWidth = self.borderSize;
    self.keyboard.layer.cornerRadius = self.roundness;
    self.keyboard.layer.backgroundColor = self.bgColor.CGColor;
    self.keyboard.layer.borderColor = self.borderColor.CGColor;
    self.keyboard.userInteractionEnabled = scrollable;

    [self setNumberTouchesForScroll:self.touchesForScroll];
    
    // Draw the keyboard buttons - OBShapedButton is a custom class that ignores touches on transparent portions of a .png image.
    // This allows the detection between white and black keys to be smoother. https://github.com/ole/OBShapedButton
    // Also assign the appropriate .tag from the midi arrays.
    
    // Draw white keys
    tag = 0;
    float fontSize = whiteKeyWidth/3;
    for (UIImage *image in keyboardWhiteButtonArray) {
        OBShapedButton *whiteButton = [OBShapedButton buttonWithType:UIButtonTypeCustom];
        
        [whiteButton addTarget:self action:@selector(handleKeyboardButtonsTouchDown:) forControlEvents:UIControlEventTouchDown];
        [whiteButton addTarget:self action:@selector(handleKeyboardButtonsTouchUp:) forControlEvents:UIControlEventTouchUpInside];
        [whiteButton addTarget:self action:@selector(handleKeyboardButtonsTouchUp:) forControlEvents:UIControlEventTouchDragExit];
        [whiteButton addTarget:self action:@selector(handleKeyboardButtonsTouchUp:) forControlEvents:UIControlEventTouchCancel];
        
        [whiteButton setBackgroundImage:image forState:UIControlStateNormal];    //[keyboardWhiteButtonArray objectAtIndex:tag]
        whiteButton.adjustsImageWhenHighlighted = NO;
        whiteButton.showsTouchWhenHighlighted = NO;
        whiteButton.adjustsImageWhenDisabled = NO;
        //        whiteButton.showsTouchWhenHighlighted = YES;
        //        whiteButton.tintColor = [UIColor blueColor];
        whiteButton.frame = CGRectMake(whiteKeyWidth*tag, 0, whiteKeyWidth, keyboardHeight);
        
        if (self.hidesNumbers == NO) {
            if (tag % 7 == 0) {
                int octave = ((tag/7)*12)+lowestNote;
                [whiteButton.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
                [whiteButton setTitle:[NSString stringWithFormat:@"%i",octave] forState:UIControlStateNormal];
                [whiteButton setTitleColor:[UIColor colorWithWhite:0 alpha:1] forState:UIControlStateNormal];
                
                // Adjust the position of the .titleLabel property.
                [whiteButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
                [whiteButton setContentVerticalAlignment:UIControlContentVerticalAlignmentTop];
                [whiteButton setTitleEdgeInsets:UIEdgeInsetsMake(keyboardHeight-(fontSize*1.5)-(self.borderSize*.8), whiteKeyWidth*(1.5/fontSize)+(self.borderSize*.1), 0, 0)];
            }
        }
        
        whiteButton.tag = [[whiteKeyMidi objectAtIndex:tag] intValue];
        [allTheKeys addObject:whiteButton];
        tag++;
        [self.keyboard addSubview:whiteButton];
    }
    
    // Draw black keys
    tag = 0;
    for (NSNumber *num in keyboardBlackButtonArray) {
        OBShapedButton *blackButton = [OBShapedButton buttonWithType:UIButtonTypeCustom];
        [blackButton addTarget:self action:@selector(handleKeyboardButtonsTouchDown:) forControlEvents:UIControlEventTouchDown];
        [blackButton addTarget:self action:@selector(handleKeyboardButtonsTouchUp:) forControlEvents:UIControlEventTouchUpInside];
        [blackButton addTarget:self action:@selector(handleKeyboardButtonsTouchUp:) forControlEvents:UIControlEventTouchDragExit];
        [blackButton addTarget:self action:@selector(handleKeyboardButtonsTouchUp:) forControlEvents:UIControlEventTouchCancel];
        [blackButton setBackgroundImage:black forState:UIControlStateNormal];
        blackButton.adjustsImageWhenHighlighted = NO;
        blackButton.showsTouchWhenHighlighted = NO;
        int mod = [num intValue];//[keyboardBlackButtonArray objectAtIndex:tag]
        blackButton.frame = CGRectMake((whiteKeyWidth*mod)-(keyboardWidth*blackKeyOffset), 0, blackKeyWidth, blackKeyHeight);
        
        blackButton.tag = [[blackKeyMidi objectAtIndex:tag] intValue];
        [allTheKeys addObject:blackButton];
        tag++;
        [self.keyboard addSubview:blackButton];
    }
    
    [self addSubview:self.keyboard];
    
    
    if (self.shouldDoCoolAnimation == YES) {
        if (animate) {
            UIGraphicsBeginImageContext(self.keyboard.frame.size);
            [CATransaction begin];
            [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
            [CATransaction setCompletionBlock:^{
            }];
            CABasicAnimation *fillAnimation = [CABasicAnimation animationWithKeyPath:@"borderColor"];
            fillAnimation.duration = self.startupAnimationDuration;
            fillAnimation.fromValue = (id)[UIColor whiteColor].CGColor;
            fillAnimation.toValue = (id)self.borderColor.CGColor;
            fillAnimation.removedOnCompletion = YES;
            
            CABasicAnimation *sizeAnimation = [CABasicAnimation animationWithKeyPath:@"borderWidth"];
            sizeAnimation.duration = self.startupAnimationDuration/1.2;
            sizeAnimation.fromValue = @(100);
            sizeAnimation.toValue = @(self.borderSize);
            sizeAnimation.removedOnCompletion = YES;
            
            CABasicAnimation *bgAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
            bgAnimation.duration = self.startupAnimationDuration;
            bgAnimation.fromValue = (id)[UIColor whiteColor].CGColor;
            bgAnimation.toValue = (id)self.bgColor.CGColor;
            bgAnimation.removedOnCompletion = YES;
            
            [self.keyboard.layer addAnimation:fillAnimation forKey:@"borderColor"];
            [self.keyboard.layer addAnimation:sizeAnimation forKey:@"borderWidth"];
            [self.keyboard.layer addAnimation:bgAnimation forKey:@"backgroundColor"];
            [CATransaction commit];
            UIGraphicsEndImageContext();
        }
    }
}

- (void)setLocked:(BOOL)locked {
    scrollable = !locked;
    self.keyboard.userInteractionEnabled = !locked;
}

- (void)scrollTo:(float)octave withAnimation:(BOOL)animated {
    float position = self.keyboard.contentSize.width/self.octaves;
    position = position * octave;
    
    CGRect frame = CGRectMake(position, 0, self.keyboard.bounds.size.width, self.keyboard.bounds.size.height);
    [self.keyboard scrollRectToVisible:frame animated:animated];
}

- (void)animateViewDown:(UIView*)view {
    UIViewAnimationOptions option;
    float xsize;
    float ysize;
    float dur;
    float vel;
    
    if (view.frame.size.width < (self.bounds.size.width/self.visibleKeys)) {
        option = UIViewAnimationOptionCurveEaseIn;
        xsize = .9;
        ysize = .9;
        dur = .15f;
        vel = 7.f;
    } else {
        option = UIViewAnimationOptionCurveEaseOut;
        xsize = .95;
        ysize = .95;
        dur = .15f;
        vel = 10.f;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:dur
                              delay:0.0f
             usingSpringWithDamping:.2f
              initialSpringVelocity:vel
                            options:(UIViewAnimationOptionAllowUserInteraction |
                                     option)
                         animations:^{
                             view.transform = CGAffineTransformScale(CGAffineTransformIdentity, xsize, ysize);
                         }
                         completion:^(BOOL finished) {

                         }];
    });
}

- (void)animateViewUp:(UIView*)view {
    float dur;
    float vel;
    float damp;
    float del = 0;
    if (scrollable) {
        del = .15;
    }

    if (view.frame.size.width < (self.bounds.size.width/self.visibleKeys)) {
        dur = .2f;
        vel = 7.f;
        damp = .3f;
    } else {
        dur = .4f;
        vel = 10.f;
        damp = .2f;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:dur
                              delay:del
             usingSpringWithDamping:damp
              initialSpringVelocity:vel
                            options:(UIViewAnimationOptionAllowUserInteraction |
                                     UIViewAnimationOptionCurveEaseOut)
                         animations:^{
                             view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1);
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    });
}

//Handle clicking buttons. Set the control event for the Viewcontroller to receive updates.
- (void)handleKeyboardButtonsTouchDown:(UIView*)view {
    self.value = (float)view.tag;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self animateViewDown:view];
    });

    id<NNKeyboardDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(keyboardTouchDownEvent:)]) {
        [strongDelegate keyboardTouchDownEvent:self];
    }
}

- (void)handleKeyboardButtonsTouchUp:(UIView*)view {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self animateViewUp:view];
    });
    
    id<NNKeyboardDelegate> strongDelegate = self.delegate;
    if ([strongDelegate respondsToSelector:@selector(keyboardTouchUpEvent:)]) {
        [strongDelegate keyboardTouchUpEvent:self];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint touchLocation = [touch locationInView:self.keyboard];
        
        UIButton *button;
        for (UIButton* whichButton in self.keyboard.subviews) {
            if (CGRectContainsPoint(whichButton.frame, touchLocation)) {
                button = whichButton;
            }
        }
        
        if (button) {
            [self animateViewDown:button];
            
            int tag = (int)button.tag;
            [self.currentTouches addObject:touch];
            [self.currentButtons addObject:button];
            [self.currentNotes addObject:[NSNumber numberWithInt:tag]];
            [self.currentLoc addObject:[NSNumber numberWithInt:(int)touchLocation.x]];
            
            self.value = (float)tag;
            [self sendActionsForControlEvents:UIControlEventValueChanged];
            
            id<NNKeyboardDelegate> strongDelegate = self.delegate;
            if ([strongDelegate respondsToSelector:@selector(keyboardTouchDownEvent:)]) {
                [strongDelegate keyboardTouchDownEvent:self];
            }
        }
        //NSLog(@"Begin: %d",tag);
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint touchLocation = [touch locationInView:self.keyboard];

        int x = (int)touchLocation.x;
        if (x % 2 == 0) {
            int target = -1;
            for (int i = 0; i < self.currentTouches.count; i++) {
                if (touch == [self.currentTouches objectAtIndex:i]) {
                    target = i;
                    
                    int lastLoc = [[self.currentLoc objectAtIndex:target] intValue];
                    
                    if (lastLoc != x) {
                        UIButton *button;
                        for (UIButton* whichButton in self.keyboard.subviews) {
                            if (CGRectContainsPoint(whichButton.frame, touchLocation)) {
                                button = whichButton;
                            }
                        }
                        
                        int tag = (int)button.tag;
                        
                        if (button) {
                            int currentValue = [[self.currentNotes objectAtIndex:target] intValue];
                            if (currentValue != tag) {
                                //NSLog(@"Moved: %d", tag);

                                self.value = (float)tag;
                                [self sendActionsForControlEvents:UIControlEventValueChanged];
                                [self.currentNotes replaceObjectAtIndex:target withObject:[NSNumber numberWithInt:tag]];
                                [self animateViewUp:[self.currentButtons objectAtIndex:target]];
                                [self.currentButtons replaceObjectAtIndex:target withObject:button];
                                [self animateViewDown:button];
                                [self.currentLoc replaceObjectAtIndex:target withObject:[NSNumber numberWithInt:x]];
                                
                                id<NNKeyboardDelegate> strongDelegate = self.delegate;
                                if ([strongDelegate respondsToSelector:@selector(keyboardTouchMovedEvent:)]) {
                                    [strongDelegate keyboardTouchMovedEvent:self];
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        //CGPoint touchLocation = [touch locationInView:self.keyboard];
        
        int target = -1;
        for (int i = 0; i < self.currentTouches.count; i++) {
            if (touch == [self.currentTouches objectAtIndex:i]) {
                target = i;
            }
        }
        if (target > -1) {
            //NSLog(@"  End: %d",[[self.currentNotes objectAtIndex:target] intValue]);
            
            [self.currentNotes removeObjectAtIndex:target];
            [self.currentTouches removeObjectAtIndex:target];
            [self animateViewUp:[self.currentButtons objectAtIndex:target]];
            [self.currentButtons removeObjectAtIndex:target];
            
            id<NNKeyboardDelegate> strongDelegate = self.delegate;
            if ([strongDelegate respondsToSelector:@selector(keyboardTouchUpEvent:)]) {
                [strongDelegate keyboardTouchUpEvent:self];
            }
        }
    }
}


@end
