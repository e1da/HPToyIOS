//
//  FiltersViewController.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 28/09/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "FiltersViewController.h"
#import "XOverView.h"
#import "DialogSystem.h"
#import "CoefWarningController.h"


@interface FiltersViewController () {
    UIBarButtonItem * peqButton;
    UIBarButtonItem * showTextButton;
    XOverView * filtersView;
    BiquadCoefValueControl * biquadCoefControl;
    
    CGPoint prev_translation;
    double delta_freq;
    BOOL xHysteresisFlag;
    BOOL yHysteresisFlag;
    
    BOOL showBiquadText;
}

@end

@implementation FiltersViewController

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeLeft;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    [self.view setBackgroundColor:[UIColor darkGrayColor]];
    showBiquadText = NO;
    
    [self initGestures];
    [self initSubviews];
    
}

- (void) viewWillAppear:(BOOL)animated {
    //[super viewWillAppear:animated];
    UIApplication* application = [UIApplication sharedApplication];
    if (application.statusBarOrientation != UIInterfaceOrientationLandscapeLeft)
    {
        UIViewController *c = [[UIViewController alloc]init];
        [c.view setBackgroundColor:[UIColor blackColor]];
        [self.navigationController presentViewController:c animated:NO completion:^{
            [self.navigationController dismissViewControllerAnimated:YES completion:^{
            }];
        }];
    }
    
    [self updateSubviews];
    
}

- (void) initGestures {
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapHandler:)];
    tapGesture.numberOfTapsRequired = 2;
    longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressHandler:)];
    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panHandler:)];
    pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchHandler:)];
}

- (void) setEnabledGestures:(BOOL) enabled{
    tapGesture.enabled = enabled;
    longPressGesture.enabled = enabled;
    panGesture.enabled = enabled;
    pinchGesture.enabled = enabled;
}

- (void)initSubviews {
    //init info button
    UIButton * infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    infoButton.frame = CGRectMake(self.view.frame.size.width - 60, 10, 20, 20);
    [infoButton addTarget:self action:@selector(showInfo:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *infoBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:infoButton];
    
    //create peq on/off button
    peqButton = [[UIBarButtonItem alloc] init];
    peqButton.target = self;
    peqButton.action = @selector(setPeqFlag);
    peqButton.title = ([self.filters isPEQEnabled]) ? @"PEQ On" : @"PEQ Off";
    
    //init info button
    showTextButton = [[UIBarButtonItem alloc] init];
    showTextButton.target = self;
    showTextButton.action = @selector(setShowTextBiquad);
    showTextButton.title = @"       \u232A";
    
    //add buttons to bar
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:showTextButton, infoBarButtonItem, peqButton, nil];
    
    //configure XOverView
    filtersView = [[XOverView alloc] init];
    [filtersView addGestureRecognizer:tapGesture];
    [filtersView addGestureRecognizer:longPressGesture];
    [filtersView addGestureRecognizer:panGesture];
    [filtersView addGestureRecognizer:pinchGesture];
    filtersView.maxFreq = 30000;
    filtersView.minFreq = 20;
    
    if (filtersView.maxFreq > 500){
        filtersView.drawFreqUnitArray = [NSArray arrayWithObjects:[NSNumber numberWithInt:20],
                                            [NSNumber numberWithInt:100], [NSNumber numberWithInt:1000],
                                            [NSNumber numberWithInt:10000], nil];
    } else {
        filtersView.drawFreqUnitArray = [NSArray arrayWithObjects:[NSNumber numberWithInt:20],
                                            [NSNumber numberWithInt:100], [NSNumber numberWithInt:500], nil];
    }
    filtersView.filters = self.filters;
    
    [self.view addSubview:filtersView];
    
    biquadCoefControl = [[BiquadCoefValueControl alloc] init];
    biquadCoefControl.delegate = self;
    biquadCoefControl.filters = self.filters;
    [self.view addSubview:biquadCoefControl];
}

- (void) updateSubviews {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if ((orientation == UIInterfaceOrientationPortrait) ||
        (orientation == UIInterfaceOrientationPortraitUpsideDown)) {
        _filters.activeNullLP = NO;
        _filters.activeNullHP = NO;
    }
    
    [self setTitleInfo];
    [biquadCoefControl update];
    
    [filtersView setNeedsDisplay];
}

- (void) setShowTextBiquad {
    showBiquadText = !showBiquadText;
    showTextButton.title = showBiquadText ? @"       \u2329" : @"       \u232A";
    [self.view setNeedsLayout];
}

- (void) showInfo:(UIButton *)button
{
    NSString * msgString;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if ((orientation == UIInterfaceOrientationPortrait) ||
        (orientation == UIInterfaceOrientationPortraitUpsideDown)) {
        
        msgString = @"Info for portrait orientation";
    } else {
        msgString = @"To select the filter, please double tap on it. Horizontal slide changes a frequency, vertical one controls PEQ's gain or LPF/HPF's order. Zoom-in/out to control Q of PEQ. Holding on tap at the selected PEQ turns that into the APF for phase alignment. To get the biquad text entering mode, hold your iPhone upright.";
    }
    
    [[DialogSystem sharedInstance] showAlert:msgString];
}

- (void) setPeqFlag {
    
    BOOL enabled = [self.filters isPEQEnabled];
    [self.filters setPEQEnabled:!enabled];
    peqButton.title = ([self.filters isPEQEnabled]) ? @"PEQ On" : @"PEQ Off";
    
    [self updateSubviews];
}


- (void) setTitleInfo {
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if ((orientation == UIInterfaceOrientationPortrait) ||
        (orientation == UIInterfaceOrientationPortraitUpsideDown)) {
        self.title = @"Filters menu";
        return;
    }
    
    Biquad * b = [_filters getActiveBiquad];
    
    if (b.type == BIQUAD_LOWPASS) {
        PassFilter * lp = [_filters getLowpass];
        self.title = [NSString stringWithFormat:@"LP:%@", [lp getInfo]];
    } else if (b.type == BIQUAD_HIGHPASS) {
        PassFilter * hp = [_filters getHighpass];
        self.title = [NSString stringWithFormat:@"HP:%@", [hp getInfo]];
    } else if (b.type == BIQUAD_PARAMETRIC) {
        self.title = [NSString stringWithFormat:@"PEQ%d:%@", _filters.activeBiquadIndex + 1, [b getInfo]];
    } else if (b.type == BIQUAD_ALLPASS) {
        self.title = [NSString stringWithFormat:@"APF%d:%@", _filters.activeBiquadIndex + 1, [b getInfo]];
    } else {
        self.title = @"Filters menu";
    }
}

- (void) viewWillLayoutSubviews {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if ((orientation== UIInterfaceOrientationLandscapeLeft) ||
        (orientation== UIInterfaceOrientationLandscapeRight)) {
        
        [self viewWillLayoutSubviewsLandscape];
        [self setEnabledGestures:YES];
    } else {
        [self viewWillLayoutSubviewsPortrait];
        [self setEnabledGestures:NO];
        
    }
    
}

- (void) viewWillLayoutSubviewsPortrait {
    int top = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    int width = self.view.frame.size.width;
    int height = self.view.frame.size.height - top;
    
    [self updateSubviews];
    
    [filtersView setFrame:CGRectMake(0, top, width, 0.4 * height)];
    biquadCoefControl.frame = CGRectMake(0.05 * width, top + 0.4 * height, 0.9 * width, 0.5 * height);
}

- (void) viewWillLayoutSubviewsLandscape {
    int top = self.navigationController.navigationBar.frame.size.height +
                [UIApplication sharedApplication].statusBarFrame.size.height;
    int width = self.view.frame.size.width;
    int height = self.view.frame.size.height - top;
    
    [self updateSubviews];
    
    if (showBiquadText) {
        [filtersView setFrame:CGRectMake(0, top, width - 250, height)];
        biquadCoefControl.hidden = NO;
        biquadCoefControl.frame = CGRectMake(width - 250, top + 20 , 200, height - 40);
    } else {
        [filtersView setFrame:CGRectMake(0, top, width, height)];
        biquadCoefControl.hidden = YES;
    }
}

/* ----------------------------------- Keyboard methods (change NumValueControl) ----------------------------------------- */
-(void) updateBiquadCoefValueControl {
    [self setTitleInfo];
    [filtersView setNeedsDisplay];
}

- (void) showKeyboardWithValue:(NumValueControl *)valControl {
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    self.definesPresentationContext = YES;
    self.providesPresentationContextTransitionStyle = YES;
    
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
        
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
        //always fill the view
        blurEffectView.frame = self.view.bounds;
        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.view addSubview:blurEffectView]; //if you have more UIViews, use an insertSubview API to place it where needed
    }
    
    
    NumKeyboardController * keyController = [[NumKeyboardController alloc] init];
    keyController.delegate = self;
    keyController.valControl = valControl;
    
    keyController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:keyController animated:YES completion:nil];
}

- (void) didKeyboardEnter:(NumValueControl *) valControl {
    [biquadCoefControl updateCoefValueControl:valControl];
    [self didKeyboardClose];
    
}

- (void) didKeyboardClose {
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    //remove blur view
    for (int i = 0; i < self.view.subviews.count; i++) {
        UIView * subview = [self.view.subviews objectAtIndex:i];
        if ([subview isKindOfClass:[UIVisualEffectView class]]) {
            [subview removeFromSuperview];
        }
    }
    [self updateSubviews];
}

- (void) showTextBiquad {
    if ([self isCoefWarningEnabled]) {
        [self showCoefWarning];
    }
}

- (BOOL) isCoefWarningEnabled {
    id flag = [[NSUserDefaults standardUserDefaults] objectForKey:@"BiquadCoefWarningKey"];
    if (flag) {
        return ![[NSUserDefaults standardUserDefaults] boolForKey:@"BiquadCoefWarningKey"];
    }
    return YES;
}

- (void) showCoefWarning {
    CoefWarningController * coefWarningController = [[CoefWarningController alloc] init];

    coefWarningController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    [self presentViewController:coefWarningController animated:YES completion:nil];
}

//gesture handlers
- (void) doubleTapHandler:(UITapGestureRecognizer *)recognizer {
    [self selectActiveFilter:recognizer];
}

- (void) longPressHandler:(UILongPressGestureRecognizer *)recognizer {
    static BOOL update = NO;
    
    if ((_filters.activeNullLP) || (_filters.activeNullLP)) return;
    
    CGPoint tap_point = [recognizer locationInView:recognizer.view];
    Biquad * b = [_filters getActiveBiquad];
    
    if ((!update) && ([self checkCrossParamFilters:b point_x:tap_point.x])) {
        if (b.type == BIQUAD_PARAMETRIC) {
            b.enabled = YES;
            b.order = BIQUAD_ORDER_1;
            b.type = BIQUAD_ALLPASS;
            
            [b sendWithResponse:YES];
            update = YES;
            [self updateSubviews];
        } else if ((b.type == BIQUAD_ALLPASS) ) {
            b.enabled = [_filters isPEQEnabled];
            b.order = BIQUAD_ORDER_2;
            b.type = BIQUAD_PARAMETRIC;
            b.biquadParam.qFac = 1.41f;
            b.biquadParam.dbVolume = 0.0f;
            
            [b sendWithResponse:YES];
            update = YES;
            [self updateSubviews];
        }
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded){
        update = NO;
    }
}

- (void) panHandler:(UIPanGestureRecognizer *)recognizer {
    CGPoint translation = [recognizer translationInView:recognizer.view];
    
    if (recognizer.state == UIGestureRecognizerStateBegan){
        prev_translation = translation;
        
        xHysteresisFlag = NO;
        yHysteresisFlag = NO;
        delta_freq = 0;
    }
    
    
    if (_filters.activeNullLP) {
        float dy = translation.y -  prev_translation.y;
        
        if (dy > 100 ){
            [_filters upOrderFor:BIQUAD_LOWPASS]; // increment order
            prev_translation.y = translation.y;
        }
        
    } else if (_filters.activeNullHP) {
        float dy = translation.y -  prev_translation.y;
        
        if (dy > 100 ){
            [_filters upOrderFor:BIQUAD_HIGHPASS]; // increment order
            prev_translation.y = translation.y;
        }
        
    } else {
        [self moved:[_filters getActiveBiquad]  translation:translation];
        
    }
    
    //display refresh
    [self updateSubviews];
}

- (void) pinchHandler:(UIPinchGestureRecognizer *)recognizer {
    static double lastScaleFactor;
    
    if (recognizer.state == UIGestureRecognizerStateBegan){
        lastScaleFactor = 1.0f;
    }
    
    double currentScaleFactor = recognizer.scale / lastScaleFactor;
    lastScaleFactor = recognizer.scale;
    
    Biquad * b = [_filters getActiveBiquad];
    if (b.type != BIQUAD_PARAMETRIC) return;
    
    BiquadParam * p = b.biquadParam;
    
    p.qFac /= currentScaleFactor;
    
    //send to dsp cc2540
    [b sendWithResponse:NO];
    
    //display refresh
    [self updateSubviews];
}

- (void ) selectActiveFilter:(UIGestureRecognizer *)recognizer
{
    CGPoint tap_point = [recognizer locationInView:recognizer.view];
    
    int tempIndex = _filters.activeBiquadIndex;
    
    if (![self.filters getLowpass]) {
        CGPoint p = CGPointMake([filtersView freqToPixel:filtersView.maxFreq],
                                [filtersView dbToPixel:[self.filters getAFR:filtersView.maxFreq]]);
        
        //check cross
        if ( (abs((int)(p.x - tap_point.x)) < 30) && (abs((int)(p.y - tap_point.y)) < 30) ) {
            self.filters.activeNullLP = YES;
            [self updateSubviews];
            return;
        } else {
            self.filters.activeNullLP = NO;
        }
    }
    if (![self.filters getHighpass]) {
        CGPoint tap_point = [recognizer locationInView:recognizer.view];
        CGPoint p = CGPointMake([filtersView freqToPixel:filtersView.minFreq],
                                [filtersView dbToPixel:[self.filters getAFR:filtersView.minFreq]]);
        
        //check cross
        if ( (abs((int)(p.x - tap_point.x)) < 30) && (abs((int)(p.y - tap_point.y)) < 30) ) {
            self.filters.activeNullHP = YES;
            [self updateSubviews];
            return;
        } else {
            self.filters.activeNullHP = NO;
        }
    }
    
    
    for (int u = 0; u < [_filters getBiquadLength]; u++){
        [_filters nextActiveBiquadIndex];
        
        Biquad * b = [_filters getActiveBiquad];
        
        if ((b.type != BIQUAD_LOWPASS) && (b.type != BIQUAD_HIGHPASS) && (b.type != BIQUAD_PARAMETRIC) && (b.type != BIQUAD_ALLPASS)) {
            continue;
        }
        
        if ([self checkCross:b tap_point:tap_point]){
            [self updateSubviews];
            return;
        }
    }
    _filters.activeBiquadIndex = tempIndex;
}

- (void) moved:(Biquad *)biquad translation:(CGPoint)translation {
    BiquadParam * bParam = biquad.biquadParam;
    if (( biquad.type == BIQUAD_OFF) || (( biquad.type == BIQUAD_USER))) return;
    
    float dx = (translation.x -  prev_translation.x) / 2;
    float dy = translation.y -  prev_translation.y;
    
    //update freq
    if (((fabs(translation.x) > [filtersView getWidth] * 0.05) || (xHysteresisFlag)) && (!yHysteresisFlag)) {
        xHysteresisFlag = YES;
        
        double t;
        delta_freq = modf(delta_freq, &t);//get fraction part
        
        double freqPix = [filtersView freqToPixel:biquad.biquadParam.freq];
        delta_freq += [filtersView pixelToFreq:(freqPix + dx)] -  bParam.freq;
        
        //NSLog(@"dx=%f delta=%f", dx, delta_freq);
        
        if (fabs(delta_freq) >= 1.0) {
  
            if ( biquad.type == BIQUAD_HIGHPASS) {
                PassFilter * hp = [_filters getHighpass];
                PassFilter * lp = [_filters getLowpass];
                
                int newFreq = [hp Freq] + delta_freq;
                if ((lp) && (newFreq > [lp Freq])) newFreq = [lp Freq];
                
                if ([hp Freq] != newFreq) {
                    [hp setFreq:newFreq];
                    //ble send
                    [hp sendWithResponse:NO];
                }
                
            } else if ( biquad.type == BIQUAD_LOWPASS) {
                PassFilter * lp = [_filters getLowpass];
                PassFilter *  hp = [_filters getHighpass];
                
                int newFreq = [lp Freq] + delta_freq;
                if ((hp) && (newFreq < [hp Freq])) newFreq = [hp Freq];
                
                if ([lp Freq] != newFreq) {
                    [lp setFreq:newFreq];
                    //ble send
                    [lp sendWithResponse:NO];
                }
                
                
            } else {//parametric allpass
                bParam.freq += delta_freq;
                //ble send
                [biquad sendWithResponse:NO];
            }
        }
        
    }
    prev_translation.x = translation.x;
    
    
    if ((biquad.type == BIQUAD_HIGHPASS) || (biquad.type == BIQUAD_LOWPASS))  {
        
        if (!xHysteresisFlag) {
            
            if (dy < -100 ){
                [_filters downOrderFor: biquad.type]; // decrement order
                
                yHysteresisFlag = YES;
                prev_translation.y = translation.y;
                
            } else if (dy > 100 ){
                [_filters upOrderFor: biquad.type]; // increment order
                
                yHysteresisFlag = YES;
                prev_translation.y = translation.y;
            }
            
        }
    } else if (biquad.type == BIQUAD_PARAMETRIC) {
        
        if (((fabs(translation.y) > [filtersView getHeight] * 0.1) || (yHysteresisFlag)) && (!xHysteresisFlag)){
            yHysteresisFlag = YES;
            
            float newVolInPix = [filtersView dbToPixel:bParam.dbVolume] + dy / 4.0f;
            bParam.dbVolume = [filtersView pixelToDb:newVolInPix];
            //ble send
            [biquad sendWithResponse:NO];
            
        }
        prev_translation.y = translation.y;
    }
}

/* ----------------------- check cross Filters's freq ------------------------------*/
- (BOOL) checkCrossParamFilters:(Biquad *)biquad
                        point_x: (float)point_x {
    if (abs((int)(point_x - [filtersView freqToPixel:biquad.biquadParam.freq])) < 15){
        return YES;
        
    }
    return NO;
}

- (BOOL) checkCrossPassFilters:(int)start_x
                         end_x:(int)end_x
                     tap_point:(CGPoint)tap_point {
    BOOL result = NO;
    
    for (int i = start_x; i < end_x; i++){
        double y = [self.filters getAFR:[filtersView pixelToFreq:i]];
        
        if (sqrt(pow(tap_point.x - i, 2) +
                 pow(tap_point.y - [filtersView dbToPixel:( 20.0f * log10(y) )], 2)) < 20){
            result = YES;
            break;
        }
        
    }
    
    return result;
}

- (BOOL) checkCross:(Biquad *)biquad tap_point:(CGPoint)tap_point {
    
    if (biquad.type == BIQUAD_HIGHPASS) {
        int start_x = [filtersView freqToPixel:filtersView.minFreq];
        int end_x = [filtersView getHighPassBorderPix];
        return [self checkCrossPassFilters:start_x end_x:end_x tap_point:tap_point];
        
    } else if (biquad.type == BIQUAD_LOWPASS) {
        
        int start_x = [filtersView getLowPassBorderPix];
        int end_x = [filtersView freqToPixel:filtersView.maxFreq];
        return [self checkCrossPassFilters:start_x end_x:end_x tap_point:tap_point];
        
    }
    
    //parametric, allpasa
    return [self checkCrossParamFilters:biquad point_x:tap_point.x];
}



@end
