//
//  XOverViewController.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 13/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "XOverViewController.h"
#import "DialogSystem.h"

@interface XOverViewController(){
    BOOL addKeyDown;
    BOOL addParametricSuccess;
    
    CGPoint prev_translation;
    double delta_freq;
    BOOL xHysteresisFlag;
    BOOL yHysteresisFlag;
}

- (void) refreshView;
- (void) setTitleInfo;

- (void) selectActiveFilter:(UIGestureRecognizer *)recognizer;
- (void) moved:(BiquadLL *)biquad translation:(CGPoint)translation;
- (BOOL) checkCross:(BiquadLL *)biquad tap_point:(CGPoint)tap_point;

@end

@implementation XOverViewController

@synthesize xOverView;

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

- (void)viewWillAppear:(BOOL)animated
{
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
    
    self.navigationItem.backBarButtonItem.title = @"Back";
    self.navigationItem.leftItemsSupplementBackButton = YES;
    
    //create Button
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    addButton.frame = CGRectMake(self.view.frame.size.width - 60, 10, 20, 20);
    
    [addButton addTarget:self action:@selector(showHint:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    addKeyDown = NO;
    
    //configure XOverView
    self.xOverView.maxFreq = self.maxFreq;
    self.xOverView.minFreq = self.minFreq;
    
    if (self.xOverView.maxFreq > 500){
        self.xOverView.drawFreqUnitArray = [NSArray arrayWithObjects:[NSNumber numberWithInt:20],
                                            [NSNumber numberWithInt:100], [NSNumber numberWithInt:1000],
                                            [NSNumber numberWithInt:10000], nil];
    } else {
        self.xOverView.drawFreqUnitArray = [NSArray arrayWithObjects:[NSNumber numberWithInt:20],
                                            [NSNumber numberWithInt:100], [NSNumber numberWithInt:500], nil];
    }
    
    
    self.xOverView.filters = self.filters;
    _peqFlag_outl.title = ([self.filters isPEQEnabled]) ? @"PEQ On" : @"PEQ Off";

    [self refreshView];
}

-(void)viewWillLayoutSubviews
{
    CGRect rect = [[UIApplication sharedApplication] statusBarFrame];
    rect.size.height += self.navigationController.navigationBar.frame.size.height;
    self.xOverView.initHeight = rect.size.height;
    [self refreshView];
}

/*-----------------------------------------------------------------------------------------
 Prepare for segue
 -----------------------------------------------------------------------------------------*/
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showPopover"]) {
        UIViewController *destination = (UIViewController * )segue.destinationViewController;
        destination.popoverPresentationController.delegate = self;
        
    }
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller
{
    return UIModalPresentationNone;
}
- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller traitCollection:(UITraitCollection *)traitCollection
{
    return UIModalPresentationNone;
}

- (void) showHint:(UIButton *)button
{
    NSString * msgString = @"To select a filter please double tap on it or tap and hold > 1sec. Horizontal slide changes a frequency, vertical one controls PEQ's gain or LPF/HPF's order. Zoomin-zoomout to control Q of PEQ.";

    [[DialogSystem sharedInstance] showAlert:msgString];
}


- (void) setTitleInfo {
    
    NSString * title = nil;
    
    BiquadLL * b = [_filters getActiveBiquad];
    BiquadType_t type = b.biquadParam.type;
    
    if (type == BIQUAD_LOWPASS) {
        PassFilter * lp = [_filters getLowpass];
        title = [NSString stringWithFormat:@"LP:%@", [lp getInfo]];
    } else if (type == BIQUAD_HIGHPASS) {
        PassFilter * hp = [_filters getHighpass];
        title = [NSString stringWithFormat:@"HP:%@", [hp getInfo]];
    } else if (type == BIQUAD_PARAMETRIC) {
        title = [NSString stringWithFormat:@"PEQ%d:%@", _filters.activeBiquadIndex, [b getInfo]];
    } else if (type == BIQUAD_ALLPASS) {
        title = [NSString stringWithFormat:@"AP%d:%@", _filters.activeBiquadIndex, [b getInfo]];
    } else {
        title = @"Filters";
    }

    [self setTitle:title];
}

-(void) refreshView
{
    [self setTitleInfo];
    [xOverView setNeedsDisplay];
    
}

- (IBAction)setPeqFlag:(id)sender {

    BOOL enabled = [self.filters isPEQEnabled];
    [self.filters setPEQEnabled:!enabled];
    _peqFlag_outl.title = ([self.filters isPEQEnabled]) ? @"PEQ On" : @"PEQ Off";

    [self refreshView];
}

- (IBAction)doubleTapHandle:(UITapGestureRecognizer *)recognizer
{
    [self selectActiveFilter:recognizer];
}

- (IBAction)longPressHandle:(UILongPressGestureRecognizer *)recognizer
{
    [self selectActiveFilter:recognizer];
}

//change Freq Order dbVolume
- (IBAction)panHandle:(UIPanGestureRecognizer *)recognizer {

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
    [self refreshView];
    
}


//change QFac
- (IBAction)pinchHandle:(UIPinchGestureRecognizer *)recognizer
{
    static double lastScaleFactor;
    
    if (recognizer.state == UIGestureRecognizerStateBegan){
        lastScaleFactor = 1.0f;
    }
    
    double currentScaleFactor = recognizer.scale / lastScaleFactor;
    lastScaleFactor = recognizer.scale;

    BiquadLL * b = [_filters getActiveBiquad];
    BiquadParam * p = b.biquadParam;
    if (p.type != BIQUAD_PARAMETRIC) return;
    
    p.qFac /= currentScaleFactor;
    
    //send to dsp cc2540
    [b sendWithResponse:NO];
    
    //display refresh
    [self refreshView];
    
}

- (void ) selectActiveFilter:(UIGestureRecognizer *)recognizer
{
    CGPoint tap_point = [recognizer locationInView:recognizer.view];
    
    int tempIndex = _filters.activeBiquadIndex;
    
    if (![self.filters getLowpass]) {
        CGPoint p = CGPointMake([self.xOverView freqToPixel:self.maxFreq],
                                [self.xOverView dbToPixel:[self.filters getAFR:self.maxFreq]]);
        
        //check cross
        if ( (abs((int)(p.x - tap_point.x)) < 30) && (abs((int)(p.y - tap_point.y)) < 30) ) {
            self.filters.activeNullLP = YES;
            [self refreshView];
            return;
        } else {
            self.filters.activeNullLP = NO;
        }
    }
    if (![self.filters getHighpass]) {
        CGPoint tap_point = [recognizer locationInView:recognizer.view];
        CGPoint p = CGPointMake([self.xOverView freqToPixel:self.minFreq],
                                [self.xOverView dbToPixel:[self.filters getAFR:self.minFreq]]);
        
        //check cross
        if ( (abs((int)(p.x - tap_point.x)) < 30) && (abs((int)(p.y - tap_point.y)) < 30) ) {
            self.filters.activeNullHP = YES;
            [self refreshView];
            return;
        } else {
            self.filters.activeNullHP = NO;
        }
    }
    
    
    for (int u = 0; u < [_filters getBiquadLength]; u++){
        [_filters nextActiveBiquadIndex];
        
        BiquadLL * b = [_filters getActiveBiquad];
        BiquadType_t t = b.biquadParam.type;
        
        if ((t != BIQUAD_LOWPASS) && (t != BIQUAD_HIGHPASS) && (t != BIQUAD_PARAMETRIC) && (t != BIQUAD_ALLPASS)) {
            continue;
        }
        
        if ([self checkCross:b tap_point:tap_point]){
            [self refreshView];
            return;
        }
    }
    _filters.activeBiquadIndex = tempIndex;
}


- (void) moved:(BiquadLL *)biquad translation:(CGPoint)translation {
    BiquadParam * bParam = biquad.biquadParam;
    if (( bParam.type == BIQUAD_OFF) || (( bParam.type == BIQUAD_USER))) return;
    
    float dx = (translation.x -  prev_translation.x) / 2;
    float dy = translation.y -  prev_translation.y;
    
    //update freq
    if (((fabs(translation.x) > [self.xOverView getWidth] * 0.05) || (xHysteresisFlag)) && (!yHysteresisFlag)) {
        xHysteresisFlag = YES;

        double t;
        delta_freq = modf(delta_freq, &t);//get fraction part
        
        double freqPix = [self.xOverView freqToPixel:biquad.biquadParam.freq];
        delta_freq += [self.xOverView pixelToFreq:(freqPix + dx)] -  bParam.freq;
 
        //NSLog(@"dx=%f delta=%f", dx, delta_freq);
        
        if (fabs(delta_freq) >= 1.0) {
            if (( bParam.type == BIQUAD_HIGHPASS) || ( bParam.type == BIQUAD_LOWPASS)) {
                PassFilter * f = ( bParam.type == BIQUAD_LOWPASS) ? [_filters getLowpass] : [_filters getHighpass];
                
                int newFreq = [f Freq] + delta_freq;
                [f setFreq:newFreq];
                //ble send
                [f sendWithResponse:NO];
                
            } else {//parametric allpass
                bParam.freq += delta_freq;
                //ble send
                [biquad sendWithResponse:NO];
            }
        }

    }
    prev_translation.x = translation.x;
    
    
    if ((bParam.type == BIQUAD_HIGHPASS) || (bParam.type == BIQUAD_LOWPASS))  {

        if (!xHysteresisFlag) {
            
            if (dy < -100 ){
                [_filters downOrderFor: bParam.type]; // decrement order
                
                yHysteresisFlag = YES;
                prev_translation.y = translation.y;
                
            } else if (dy > 100 ){
                [_filters upOrderFor: bParam.type]; // increment order
                
                yHysteresisFlag = YES;
                prev_translation.y = translation.y;
            }
            
        }
    } else if (bParam.type == BIQUAD_PARAMETRIC) {
        
        if (((fabs(translation.y) > [self.xOverView getHeight] * 0.1) || (yHysteresisFlag)) && (!xHysteresisFlag)){
            yHysteresisFlag = YES;
            
            float newVolInPix = [xOverView dbToPixel:bParam.dbVolume] + dy / 4.0f;
            bParam.dbVolume = [xOverView pixelToDb:newVolInPix];
            //ble send
            [biquad sendWithResponse:NO];
            
        }
        prev_translation.y = translation.y;
    }
}

/* ----------------------- check cross Filters's freq ------------------------------*/
- (BOOL) checkCrossParamFilters:(BiquadLL *)biquad
                        point_x: (float)point_x
{
    if (abs((int)(point_x - [xOverView freqToPixel:biquad.biquadParam.freq])) < 15){
        return YES;
        
    }
    return NO;
}

- (BOOL) checkCrossPassFilters:(int)start_x
                         end_x:(int)end_x
                     tap_point:(CGPoint)tap_point
{
    BOOL result = NO;
    
    for (int i = start_x; i < end_x; i++){
        double y = [self.filters getAFR:[xOverView pixelToFreq:i]];
        
        if (sqrt(pow(tap_point.x - i, 2) +
                 pow(tap_point.y - [xOverView dbToPixel:( 20.0f * log10(y) )], 2)) < 20){
            result = YES;
            break;
        }
        
    }
    
    return result;
}

- (BOOL) checkCross:(BiquadLL *)biquad tap_point:(CGPoint)tap_point
{
    //BOOL result = NO;
    BiquadType_t type = biquad.biquadParam.type;
    
    if (type == BIQUAD_HIGHPASS) {
        int start_x = [xOverView freqToPixel:xOverView.minFreq];
        int end_x = [xOverView getHighPassBorderPix];
        return [self checkCrossPassFilters:start_x end_x:end_x tap_point:tap_point];
        
    } else if (type == BIQUAD_LOWPASS) {
        
        int start_x = [xOverView getLowPassBorderPix];
        int end_x = [xOverView freqToPixel:xOverView.maxFreq];
        return [self checkCrossPassFilters:start_x end_x:end_x tap_point:tap_point];
        
    }
    
    //parametric, allpasa
    return [self checkCrossParamFilters:biquad point_x:tap_point.x];
}

@end
