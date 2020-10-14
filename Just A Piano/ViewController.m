//
//  ViewController.m
//
//  Created by KD on 2/9/18.
//  Copyright © 2018 notnatural, LLC. All rights reserved.
//

#import "ViewController.h"
#import "NNPiano.h"
#import "KDHelpers.h"
#import "KDAnimations.h"
#import "KDColor.h"
#import "KDWarningLabel.h"
#import "KDInAppHandler.h"
#import "kdTableView.h"
#import <StoreKit/StoreKit.h>

@interface ViewController () <KDInAppHandlerDelegate, kdTableViewDelegate> {
    BOOL locked;
    BOOL purchased;
    NSArray *soundBanks;
    NSString *currentSound;

    KDInAppHandler *inAppHandler;
    kdTableView *libraryTable;
    kdTableView *displayTable;
}

@property (nonatomic, strong) NNPiano *piano1;
@property (nonatomic, strong) NNPiano *piano2;
//@property (nonatomic, strong) NNPiano *piano3;

@end

@implementation ViewController
-(BOOL)prefersStatusBarHidden{
    return YES;
}
-(BOOL)shouldAutorotate {
    return NO;
}
- (void)viewDidAppear:(BOOL)animated {

}
- (void)setSoundBanks {
    soundBanks = @[@[@"Grand Piano", @"Piano", @0],
                   @[@"Another Piano", @"Piano2", @0],
                   @[@"Another Piano - Long Notes", @"PianoLong", @0],
                   @[@"Electric Piano", @"ElectricPiano", @0],
                   @[@"Lush Pad", @"LushPad", @0],
                   @[@"Light but Crunchy", @"LightCrunch", @0],
                   @[@"Really Bad Cat", @"ReallyBadCat", @0],
                   @[@"Strings", @"Strings", @0],
                   @[@"More Strings", @"MoreStrings", @0],
                   @[@"Flute", @"FluteShortNotes", @0],
                   @[@"Flute - Long Notes", @"FluteLongNotes", @0],
                   @[@"Trumpet", @"TrumpetShortNotes", @0],
                   @[@"Trumpet - Long Notes", @"TrumpetLongNotes", @0],
                   @[@"Marimba", @"MarimbaDeadStroke", @0],
                   @[@"Kalimba", @"KalimbaDry", @0],
                   @[@"Music Toy", @"MusicToy", @0],
                   @[@"Electric Organ", @"ElectricOrgan", @0],
                   @[@"Organ", @"Organ", @0],
                   @[@"Vox Choir", @"VoxChoir", @0],
                   @[@"Noisy Synth Bass", @"NoisySynthBass", @0],
                   ];
}
- (void)viewDidLoad {
    [super viewDidLoad];

    // for dev testing
    //[[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"purchased"];
    
    [self handleOpenCount];
    [self checkPurchased];
    
    BOOL iPad = NO;
    if ([KDHelpers iPadCheck]) {
        iPad = YES;
    }
    
    float divider = 2;
//    if (iPad) {
//        divider = 3;
//    }
    
    CGRect piano1Frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/divider);
    CGRect piano2Frame = CGRectMake(0, self.view.frame.size.height/divider, self.view.frame.size.width, self.view.frame.size.height/divider);
    
    [self setSoundBanks];

    self.piano1 = [[NNPiano alloc] initWithFrame:piano1Frame];
    self.piano2 = [[NNPiano alloc] initWithFrame:piano2Frame];
    
    NSArray *currentSoundBank = [soundBanks objectAtIndex:0];
    NSString *sound = [currentSoundBank objectAtIndex:1];
    [self changeSoundBank:sound];
    
    if (iPad) {
//        self.piano3 = [[NNPiano alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height/divider)*2, self.view.frame.size.width, self.view.frame.size.height/divider)];
        
        int visKeys = 12;
        self.piano1.keys.visibleKeys = visKeys;
        self.piano2.keys.visibleKeys = visKeys;
//        self.piano3.keys.visibleKeys = visKeys;
    }
 
    [self.view addSubview:self.piano1];
    [self.view addSubview:self.piano2];
    
//    if (iPad) {
//        [self.view addSubview:self.piano3];
//    }
    
    locked = YES;
    [self.piano1 setLocked:locked];
    [self.piano2 setLocked:locked];
    
    [self.piano1 scrollTo:2 withAnimation:NO];
    [self.piano2 scrollTo:3 withAnimation:NO];
    
//    if (iPad) {
//        [self.piano3 setLocked:locked];
//        [self.piano3 scrollTo:5 withAnimation:NO];
//    }
    
    [self addHelpLabel];
    [self addLockLabel];
//    [self addStoreLabel];
    [self addLibraryLabel];
    
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
    dispatch_after(delayTime, dispatch_get_main_queue(), ^(void){
        if (![KDHelpers checkVolume]) {
            KDWarningLabel *warn = [[KDWarningLabel alloc] init];
            [self.view addSubview:warn];
            [warn flashWithString:@"Your volume may be too low!"];
        }
    });
    
    libraryTable = [[kdTableView alloc] initWithFrame:self.view.bounds];
    libraryTable.tag = 0;
    libraryTable.canReorder = NO;
    libraryTable.animate = YES;
    libraryTable.allowsEditing = NO;
    libraryTable.hasCloseButton = YES;
    libraryTable.delegate = self;
    [self.view addSubview:libraryTable];
}

- (void)handleOpenCount {
    NSString *openCountKey = @"openCount";
    NSString *reviewCountKey = @"reviewCount";
    
    long openCount = [[NSUserDefaults standardUserDefaults] integerForKey:openCountKey];
    long reviewCount = [[NSUserDefaults standardUserDefaults] integerForKey:reviewCountKey];
    long reviewMod = (reviewCount + 1) * 3;
    openCount++;
    [[NSUserDefaults standardUserDefaults] setInteger:openCount forKey:openCountKey];

    if (openCount % reviewMod == 0) {
        [SKStoreReviewController requestReview];
        reviewCount++;
        reviewCount = reviewCount % 3;
        openCount = 0;
        [[NSUserDefaults standardUserDefaults] setInteger:reviewCount forKey:reviewCountKey];
        [[NSUserDefaults standardUserDefaults] setInteger:openCount forKey:openCountKey];
    }
    
    //reset counts
//    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:reviewCountKey];
//    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:openCountKey];
}
- (void)checkPurchased {
    purchased = [[NSUserDefaults standardUserDefaults] integerForKey:@"purchased"];
}

- (void)changeSoundBank:(NSString*)soundBankName {
    if (currentSound != soundBankName) {
        currentSound = soundBankName;

        float gain = 1;

        if ([currentSound isEqualToString:@"Piano"]) {
            gain = .5;
        }
        
        [self.piano1 tearDown];
        [self.piano2 tearDown];
        [NNPiano stopAudioSession];
        
        [self.piano1 setSoundBank:soundBankName];
        [self.piano2 setSoundBank:soundBankName];

        self.piano1.gain = gain;
        self.piano2.gain = gain;
    }
}

- (void)addHelpLabel {
    float size = 30;
    float buffer = 15;
    if ([KDHelpers iPadCheck]) {
        buffer = 20;
    }
    
    UIView *labelContainer = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-size-buffer, buffer, size, size)];
    
    UIImageView *image = [[UIImageView alloc] initWithFrame:labelContainer.bounds];
    image.image = [UIImage imageNamed:@"help"];
    image.contentScaleFactor = UIViewContentModeScaleAspectFit;
    image.backgroundColor = [UIColor whiteColor];
    image.userInteractionEnabled = YES;
    image.layer.cornerRadius = size/2;
    image.layer.masksToBounds = YES;

    labelContainer.layer.shadowRadius = 2;
    labelContainer.layer.shadowOpacity = .5;
    labelContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    labelContainer.layer.masksToBounds = NO;
    labelContainer.layer.shadowOffset = CGSizeMake(.2, 1);
    
    [labelContainer addSubview:image];
    [self.view addSubview:labelContainer];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [labelContainer addGestureRecognizer:tap];
}

- (void)addLockLabel {
    float size = 30;
    float buffer = 15;
    if ([KDHelpers iPadCheck]) {
        buffer = 20;
    }
    
    UIView *labelContainer = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-size-buffer-size-buffer, buffer, size, size)];
    
    UIImageView *image = [[UIImageView alloc] initWithFrame:labelContainer.bounds];
    image.image = [UIImage imageNamed:@"lock"];
    image.contentScaleFactor = UIViewContentModeScaleAspectFit;
    image.backgroundColor = [UIColor whiteColor];
    image.userInteractionEnabled = YES;
    image.layer.cornerRadius = size/2;
    image.layer.masksToBounds = YES;

    labelContainer.layer.shadowRadius = 2;
    labelContainer.layer.shadowOpacity = .5;
    labelContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    labelContainer.layer.masksToBounds = NO;
    labelContainer.layer.shadowOffset = CGSizeMake(.2, 1);
    
    [labelContainer addSubview:image];
    [self.view addSubview:labelContainer];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLock:)];
    [labelContainer addGestureRecognizer:tap];
}

- (void)addLibraryLabel {
    float size = 30;
    float buffer = 15;
    if ([KDHelpers iPadCheck]) {
        buffer = 20;
    }
    
    UIView *labelContainer = [[UIView alloc] initWithFrame:CGRectMake(buffer, buffer, size, size)];
    
    UIImageView *image = [[UIImageView alloc] initWithFrame:labelContainer.bounds];
    image.image = [UIImage imageNamed:@"library"];
    image.contentScaleFactor = UIViewContentModeScaleAspectFit;
    image.backgroundColor = [UIColor whiteColor];
    image.userInteractionEnabled = YES;
    image.layer.cornerRadius = size/2;
    image.layer.masksToBounds = YES;

    labelContainer.layer.shadowRadius = 2;
    labelContainer.layer.shadowOpacity = .5;
    labelContainer.layer.shadowColor = [UIColor blackColor].CGColor;
    labelContainer.layer.masksToBounds = NO;
    labelContainer.layer.shadowOffset = CGSizeMake(.2, 1);
    
    [labelContainer addSubview:image];
    [self.view addSubview:labelContainer];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLibrary:)];
    [labelContainer addGestureRecognizer:tap];
}

- (void)tap:(UITapGestureRecognizer*)sender {
    [KDAnimations jiggle:sender.view];
    UIView *pop = [KDHelpers popupWithClose:YES onView:self.view withCloseTarget:self forCloseSelector:@selector(close:) withColor:[UIColor whiteColor] withBlurAmount:0];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeBig:)];
    [pop addGestureRecognizer:tap];
    
    BOOL iPad = NO;
    if ([KDHelpers iPadCheck]) {
        iPad = YES;
    }
    
    //float size1 = 35;
    float size2 = 22;
    float size3 = 12;
    if (iPad) {
        //size1 = 50;
        size2 = 40;
        size3 = 25;
    }
    UILabel *title = [KDHelpers makeLabelWithWidth:VWB(pop) andFontSize:size2];
    UILabel *text1 = [KDHelpers makeLabelWithWidth:VWB(pop) andFontSize:size2];
    UILabel *text2 = [KDHelpers makeLabelWithWidth:VWB(pop) andFontSize:size2];
    UILabel *text3 = [KDHelpers makeLabelWithWidth:VWB(pop) andFontSize:size2];
    UILabel *text4 = [KDHelpers makeLabelWithWidth:VWB(pop) andFontSize:size2];
    UILabel *textIpad;
    UILabel *footer = [KDHelpers makeLabelWithWidth:VWB(pop) andFontSize:size3];
    
    text1.text = @"basically eight octaves";
    text2.text = @"slide your fingers to gliss";
    text3.text = @"or unlock the view to enable scrolling";
    text4.text = @"and use two fingers to change register";
    title.text = @"check out the sound library in the top left";
    footer.text = @"superofficial@notnatural.co";
    
    if (iPad) {
        textIpad = [KDHelpers makeLabelWithWidth:VWB(pop) andFontSize:size2];
        textIpad.text = @"(you can turn off multitouch gestures in your device settings)";
    }
    
    float buffer = 60;
    float margin = 20;
    if ([KDHelpers iPadCheck]) {
        margin = 30;
    }
    [KDHelpers setOriginY:buffer forView:text1];
    [KDHelpers appendView:text2 toView:text1 withMarginY:margin andIndentX:0];
    [KDHelpers appendView:text3 toView:text2 withMarginY:margin andIndentX:0];
    [KDHelpers appendView:text4 toView:text3 withMarginY:margin andIndentX:0];
    
    if (iPad) {
        [KDHelpers appendView:textIpad toView:text4 withMarginY:margin andIndentX:0];
        [KDHelpers appendView:title toView:textIpad withMarginY:margin andIndentX:0];
    } else {
        [KDHelpers appendView:title toView:text4 withMarginY:margin andIndentX:0];
    }
    
    [KDHelpers setOriginY:VHB(pop)-buffer-VHB(footer) forView:footer];
    [pop addSubview:text1];
    [pop addSubview:text2];
    [pop addSubview:text3];
    [pop addSubview:text4];
    [pop addSubview:title];
    [pop addSubview:footer];
    
    if (iPad) {
        [pop addSubview:textIpad];
    }
    
    [KDAnimations animateViewGrowAndShow:pop then:nil];
    [self.view addSubview:pop];
}
- (void)tapLock:(UITapGestureRecognizer*)sender {
    locked = !locked;
    [self.piano1 setLocked:locked];
    [self.piano2 setLocked:locked];
    
    UIImageView *image = [sender.view.subviews firstObject];
    if (locked) {
        image.image = [UIImage imageNamed:@"lock"];
    } else {
        image.image = [UIImage imageNamed:@"unlock2"];
    }
    [KDAnimations jiggle:sender.view];
}
- (void)tapLibrary:(UITapGestureRecognizer*)sender {
    [KDAnimations jiggle:sender.view];
    
    if (purchased) {
        libraryTable.data = [[NSMutableArray alloc] initWithArray:soundBanks];
        [libraryTable show];
    } else {
        UIView *pop = [KDHelpers popupWithClose:YES onView:self.view withCloseTarget:self forCloseSelector:@selector(close:) withColor:[UIColor whiteColor] withBlurAmount:0];
        
        float w = VWB(pop);
        float h = VHB(pop);
        
        inAppHandler = [KDInAppHandler initWithUID:0 productID:@"soundLibrary" andDelegate:self];
        UIView *buttons = [inAppHandler makeButtonContainerWithSize:CGSizeMake(w, h*.25)];
        [KDHelpers setOriginY:h*.75 forView:buttons];
        
        UIView *topContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 50, w, (h*.75)-50)];
        UIView *left = [[UIView alloc] initWithFrame:CGRectMake(0, 0, VWB(topContainer)/2, VHB(topContainer))];
        //UIView *right = [[UIView alloc] initWithFrame:CGRectMake(VWB(topContainer)/2, 0, VWB(topContainer)/2, VHB(topContainer))];
        
        NSString *text = @"Unlock the sound library\nfor $0.99 USD";
        UILabel *label = [KDHelpers makeLabelWithWidth:VWB(left)-10 andAlignment:NSTextAlignmentCenter andText:text];
        [label setCenter:CGPointMake(VWB(left)/2, VHB(left)/2)];
        
        float margin = 10;
        if ([KDHelpers iPadCheck]) {
            margin = 25;
        }
        displayTable = [[kdTableView alloc] initWithFrame:CGRectMake(VWB(topContainer)/2, 0, VWB(topContainer)/2, VHB(topContainer))];
        displayTable.topMargin = margin;
        displayTable.bottomMargin = margin;
        displayTable.canReorder = NO;
        displayTable.animate = NO;
        displayTable.allowsEditing = NO;
        displayTable.hasCloseButton = NO;
        
        NSMutableArray *arr = [[NSMutableArray alloc] initWithArray:soundBanks];
        [arr removeObjectAtIndex:0];
        displayTable.data = [[NSMutableArray alloc] initWithArray:arr];
        
        [left addSubview:label];
        [topContainer addSubview:left];
        [topContainer addSubview:displayTable];
        [displayTable show];
        
        [pop addSubview:topContainer];
        [pop addSubview:buttons];
        [self.view addSubview:pop];
    }
}

- (void)kdInAppPurchaseComplete:(KDInAppHandler*)inApp {
    purchased = YES;
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"purchased"];
}
- (void)kdInAppReceiptRequestDidFinish:(KDInAppHandler*)inApp {
    
}
- (void)kdInAppReceiptRequestDidFail:(KDInAppHandler*)inApp withError:(NSError*)error {
    
}

-(void)kdTableView:(kdTableView*)tableView didSelectRowAtIndex:(int)index {
    NSArray *currentSound = [soundBanks objectAtIndex:index];
    [self changeSoundBank:[currentSound objectAtIndex:1]];
    [libraryTable hide];
}

- (void)close:(UITapGestureRecognizer*)sender {
    [KDAnimations jiggle:sender.view];
    [KDAnimations animateViewShrinkAndWink:sender.view.superview andRemoveFromSuperview:YES then:nil];
}
- (void)closeBig:(UITapGestureRecognizer*)sender {
    [KDAnimations animateViewShrinkAndWink:sender.view andRemoveFromSuperview:YES then:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
