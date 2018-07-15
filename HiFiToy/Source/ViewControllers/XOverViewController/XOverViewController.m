//
//  XOverViewController.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 13/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "XOverViewController.h"
#import "DialogSystem.h"
#import "ParamFilterContainer.h"
#import "BiquadManagerViewController.h"
#import "PassFilter.h"

@interface XOverViewController(){
    BOOL addKeyDown;
    BOOL addParametricSuccess;
}

- (void) refreshView;
- (void) setTitleInfo;

- (void) selectActiveFilter:(UIGestureRecognizer *)recognizer;
- (void) moved:(id)dspElement gesture:(UIPanGestureRecognizer *)recognizer;
- (BOOL) checkCross:(id)dspElement tap_point:(CGPoint)tap_point;

//advanced function for add del and other manage operation with biquads
- (BOOL) enableNextBiquadsWithFreq:(int)Freq
                              Qfac:(double)Qfac
                          dbVolume:(double) dbVolume;
//freq find automatically
- (BOOL) enableNextBiquadsWithQfac:(double)Qfac
                          dbVolume:(double) dbVolume;

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
    
    
    activeElement = [self.xover.params getFirstEnabled];
    if (!activeElement) {
        if (self.xover.hp) {
            activeElement = self.xover.hp;
        } else {
            activeElement = self.xover.lp;
        }
    }
    
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
    
    
    self.xOverView.xover = self.xover;
    self.xOverView.activeElement = activeElement;
    
    if ((self.xover.params) && ([self.xover.params isEnabled])) {
        _peqFlag_outl.title = @"PEQ On";
        _addEQ_outl.enabled = YES;
    } else {
        _peqFlag_outl.title = @"PEQ Off";
        _addEQ_outl.enabled = NO;
    }
    
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
    if ([[segue identifier] isEqualToString:@"showBiquadManager"]) {
        BiquadManagerViewController *destination = (BiquadManagerViewController * )segue.destinationViewController;
        destination.xover = self.xover;
        
    }
    
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


- (void) setTitleInfo
{
    if (!activeElement) return;
    
    NSString * title = nil;
    
    if (activeElement == self.xover.hp) {
        title = [NSString stringWithFormat:@"HP:%@", [activeElement getInfo]];
    } else if (activeElement == self.xover.lp) {
        title = [NSString stringWithFormat:@"LP:%@", [activeElement getInfo]];
        
    } else if ([self.xover.params containsParam:(ParamFilter *)activeElement]) {
        
        NSUInteger num = [self.xover.params indexOfParam:(ParamFilter *)activeElement];
        title = [NSString stringWithFormat:@"PEQ%d:%@", (int)num, [activeElement getInfo]];
        
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
    if (!self.xover.params) return;
    
    if ([self.xover.params isEnabled]) {
        [self.xover.params setEnabled:NO];
        self.peqFlag_outl.title = @"PEQ Off";
        _addEQ_outl.enabled = NO;
        
        if ([self.xover.params containsParam:(ParamFilter *)activeElement]) {
            activeElement =  (self.xover.hp) ? self.xover.hp : self.xover.lp;
        }
        
    } else {
        [self.xover.params setEnabled:YES];
        self.peqFlag_outl.title = @"PEQ On";
        _addEQ_outl.enabled = YES;
        
        if (!activeElement) activeElement = [self.xover.params getFirstEnabled];
    }
    
    self.xOverView.activeElement = activeElement;
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
- (IBAction)panHandle:(UIPanGestureRecognizer *)recognizer
{
    [self moved:activeElement  gesture:recognizer];
    //ble send
    [activeElement sendWithResponse:NO];
    
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
    
    ParamFilter * param = (ParamFilter *)activeElement;
    
    if (![self.xover.params containsParam:param]) return;
    
    param.qFac /= currentScaleFactor;
    //send to dsp cc2540
    [param sendWithResponse:NO];
    
    //display refresh
    [self refreshView];
    
}

// sequence EQ1, EQ2 .. EQn, HP, LP, EQ1 ...
- (id) nextElement:(id) element
{
    
    if ([self.xover.params containsParam:(ParamFilter *)element]) {
        
        int num = (int)[self.xover.params indexOfParam:(ParamFilter *)element];
        
        if (num < self.xover.params.count - 1) {
            return [self.xover.params paramAtIndex:num + 1];
        } else if (self.xover.hp) {
            return self.xover.hp;
        } else if (self.xover.lp) {
            return self.xover.lp;
        } else {
            [self.xover.params paramAtIndex:0];
        }
    } else if (self.xover.hp == element) {
        
        if (self.xover.lp) {
            return self.xover.lp;
        } else if ((self.xover.params) && (self.xover.params.count > 0)) {
            return [self.xover.params paramAtIndex:0];
        }
        
    } else if (self.xover.lp == element) {
        
        if ((self.xover.params) && (self.xover.params.count > 0)) {
            return [self.xover.params paramAtIndex:0];
        } else if (self.xover.hp) {
            return self.xover.hp;
        }
    }
    
    return nil;
}

- (void ) selectActiveFilter:(UIGestureRecognizer *)recognizer
{
    CGPoint tap_point = [recognizer locationInView:recognizer.view];
    
    id element = activeElement;
    
    for (int u = 0; u < [self.xover getLength]; u++){
        element = [self nextElement:element];

        ParamFilter * param = (ParamFilter *)element;// skip disabled param filters
        if (([self.xover.params containsParam:param]) && (![param isEnabled])){
            continue;
        }
        
        if ([self checkCross:element tap_point:tap_point]){
            activeElement = element;
            self.xOverView.activeElement = element;
            break;
        }
    }
    
    
    [self refreshView];
}


- (void) moved:(id)dspElement gesture:(UIPanGestureRecognizer *)recognizer
{
    if ((![dspElement isKindOfClass:[ParamFilter class]]) && (![dspElement isKindOfClass:[PassFilter2 class]])) {
        return;
    }
    
    CGPoint translation = [recognizer translationInView:recognizer.view];
    
    static double delta_freq = 0;
    //static BOOL change_freq = YES;
    static BOOL xHysteresisFlag = NO;
    static BOOL yHysteresisFlag = NO;
    
    static CGPoint prev_translation;// = {0.0f, 0.0f};
    
    
    if (recognizer.state == UIGestureRecognizerStateBegan){
        prev_translation = translation; //CGPointMake(0.0f, 0.0f);
        
        //change_freq = YES;
        xHysteresisFlag = NO;
        yHysteresisFlag = NO;
        delta_freq = 0;
    }
    
    float dx = (translation.x -  prev_translation.x) / 2;
    float dy = translation.y -  prev_translation.y;
    
    
    //update freq
    if (((fabs(translation.x) > [self.xOverView getWidth] * 0.05) || (xHysteresisFlag)) && (!yHysteresisFlag)) {
        xHysteresisFlag = YES;

        double t;
        delta_freq = modf(delta_freq, &t);//get fraction part
        
        double freqPix = [self.xOverView freqToPixel:[dspElement freq]];
        delta_freq += [self.xOverView pixelToFreq:(freqPix + dx)] - [dspElement freq];
 
        //NSLog(@"dx=%f delta=%f", dx, delta_freq);
        
        if (fabs(delta_freq) >= 1.0) {
            if ([dspElement isKindOfClass:[ParamFilter class]]){
                ParamFilter * param = dspElement;
                param.freq += delta_freq;
            }
            if ([dspElement isKindOfClass:[PassFilter2 class]]) {
                PassFilter2 * filter = dspElement;
                filter.freq += delta_freq;
            }
        }

    }
    prev_translation.x = translation.x;
    
    //y-axis moved handler different for filter and biquad elements
    if ([dspElement isKindOfClass:[ParamFilter class]]) {
        
        if (((fabs(translation.y) > [self.xOverView getHeight] * 0.1) || (yHysteresisFlag)) && (!xHysteresisFlag)){
            yHysteresisFlag = YES;
            
            float bb_vol = [xOverView dbToPixel:[dspElement dbVolume]];
            [dspElement setDbVolume:[xOverView pixelToDb:(bb_vol + dy / 4.0f)]];

        }
        prev_translation.y = translation.y;
        
    } else if ([dspElement isKindOfClass:[PassFilter2 class]]) {//PassFilter2
        PassFilter2 * filter = (PassFilter2 *)dspElement;
        
        if (!xHysteresisFlag) {
            
            if (dy < -100 ){
                filter.order--;
                
                yHysteresisFlag = YES;
                prev_translation.y = translation.y;
                
            } else if (dy > 100 ){
                filter.order++;
                
                yHysteresisFlag = YES;
                prev_translation.y = translation.y;
            }
            
        }
        
    }
    
}

/* ----------------------- check cross Filters's freq ------------------------------*/
- (BOOL) checkCrossParamFilters:(Biquad *)biquad
                        point_x: (float)point_x
{
    if (abs((int)(point_x - [xOverView freqToPixel:biquad.freq])) < 15){
        return YES;
        
    }
    return NO;
}

- (BOOL) checkCrossHighLowPass:(int)start_x
                         end_x:(int)end_x
                     tap_point:(CGPoint)tap_point
{
    BOOL result = NO;
    
    for (int i = start_x; i < end_x; i++){
        double y = [xOverView getFilters_y:[xOverView pixelToFreq:i]];
        
        if (sqrt(pow(tap_point.x - i, 2) +
                 pow(tap_point.y - [xOverView dbToPixel:( 20.0f * log10(y) )], 2)) < 20){
            result = YES;
            break;
        }
        
    }
    
    return result;
}

- (BOOL) checkCross:(id)dspElement tap_point:(CGPoint)tap_point
{
    BOOL result = NO;
    
    if ([self.xover.params containsParam:dspElement]) {
        ParamFilter * param = dspElement;
        if ([param isEnabled]) {
            return [self checkCrossParamFilters:param point_x:tap_point.x];
        }
    } else if (dspElement == self.xover.hp) {
        
        int start_x = [xOverView freqToPixel:xOverView.minFreq];
        int end_x = [xOverView getHighPassBorderPix];
        return [self checkCrossHighLowPass:start_x end_x:end_x tap_point:tap_point];
        
    } else if (dspElement == self.xover.lp) {
        
        int start_x = [xOverView getLowPassBorderPix];
        int end_x = [xOverView freqToPixel:xOverView.maxFreq];
        return [self checkCrossHighLowPass:start_x end_x:end_x tap_point:tap_point];
    }
    
    return result;
}

//add delete Action
- (IBAction)addParametric:(id)sender {
    [self enableNextBiquadsWithQfac:1.41f
                           dbVolume:0.0f];
    
    [self refreshView];
}

- (IBAction)delParametric:(id)sender {
    id dspElement = activeElement;
    
    if ([dspElement isKindOfClass:[ParamFilter class]]){
        ParamFilter * param = (ParamFilter *)dspElement;
        [param setEnabled:NO];
        param.dbVolume = 0.0;
        //biquad.type = BIQUAD_DISABLED;
        //biquad.dbVolume = 0.0;
        
        //ble send
        [param sendWithResponse:YES];
        
        //choose new active element
        id element = [self.xover.params getFirstEnabled];
        
        if (!element){
            element =  (self.xover.hp) ? self.xover.hp : self.xover.lp;
        }
        activeElement = element;
        self.xOverView.activeElement = activeElement;
        
        [self refreshView];
    }
}

- (int) getFreqForNextEnabledParametric{
    int freq = -1;
    
    NSMutableArray * freqs = [[NSMutableArray alloc] init];
    
    //get freqs from all params, hp, lp
    if (self.xover.params) {
        for (int i = 0; i < self.xover.params.count; i++) {
            ParamFilter * param = [self.xover.params paramAtIndex:i];
            if ([param isEnabled]) {
                [freqs addObject:[NSNumber numberWithInt:param.freq]];
                
            }
        }
    }
    if (self.xover.hp) [freqs addObject:[NSNumber numberWithInt:self.xover.hp.freq]];
    if (self.xover.lp) [freqs addObject:[NSNumber numberWithInt:self.xover.lp.freq]];
    
    if (freqs.count < 2) return freq;
    
    //sort freqs
    NSSortDescriptor *lowestToHighest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    [freqs sortUsingDescriptors:[NSArray arrayWithObject:lowestToHighest]];
    
    //get max delta freq
    int maxIndex = 0;
    int maxDFreq = 0;
    for (int i = 0; i < freqs.count - 1; i++){
        int f0 = [[freqs objectAtIndex:i] intValue];
        int f1 = [[freqs objectAtIndex:i + 1] intValue];
        
        if (f1 - f0 > maxDFreq){
            maxDFreq = f1 - f0;
            maxIndex = i;
        }
    }
    
    int f0 = [[freqs objectAtIndex:maxIndex] intValue];
    int f1 = [[freqs objectAtIndex:maxIndex + 1] intValue];
    
    //freq calculate
    double dfreq = (log10(f0) + log10(f1)) / 2;
    freq = pow(10, dfreq);
    
    return freq;
}


- (BOOL) enableNextBiquadsWithFreq:(int)Freq
                              Qfac:(double)Qfac
                          dbVolume:(double) dbVolume
{
    ParamFilter * param = [self.xover.params getFirstDisabled];
    
    if (!param) return NO;//error, not find disabled param biquad
    
    param.freq = Freq;
    param.qFac = Qfac;
    param.dbVolume = dbVolume;
    
    activeElement = param;
    self.xOverView.activeElement = param;
    
    return YES;
}

//freq find automatically
- (BOOL) enableNextBiquadsWithQfac:(double)Qfac
                          dbVolume:(double) dbVolume
{
    ParamFilter * param = [self.xover.params getFirstDisabled];
    
    if (!param) return NO;//error, not find disable biquad

    int freq = [self getFreqForNextEnabledParametric];
    param.freq = (freq == -1) ? 300 : freq;
    
    param.qFac = Qfac;
    param.dbVolume = dbVolume;
    [param setEnabled:YES];
    
    activeElement = param;
    self.xOverView.activeElement = param;
    
    return YES;
}

@end
