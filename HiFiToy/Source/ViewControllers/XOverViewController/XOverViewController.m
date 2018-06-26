//
//  XOverViewController.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 13/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "XOverViewController.h"
#import "DialogSystem.h"
#import "BiquadContainer.h"
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
- (NSString *) getFirstEnableParametric;
- (NSString *) getFirstDisableParametric;
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
    return YES;
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
    
    //create Button
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    addButton.frame = CGRectMake(self.view.frame.size.width - 60, 10, 20, 20);
    
    [addButton addTarget:self action:@selector(showHint:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    
    addKeyDown = NO;
    
    self.activeElementKey = [self getFirstEnableParametric];
    
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
    
    
    self.xOverView.dspElements = self.dspElements;
    self.xOverView.activeElementKey = self.activeElementKey;
    
    
    BiquadContainer * biquadContainer = [self.dspElements objectForKey:@"PEQS"];
    if ([biquadContainer isEnabled]){
        _peqFlag_outl.title = @"PEQ On";
        _addEQ_outl.enabled = YES;
    } else {
        _peqFlag_outl.title = @"PEQ Off";
        _addEQ_outl.enabled = NO;
    }
}

-(void)viewWillLayoutSubviews
{
    CGRect rect = [[UIApplication sharedApplication] statusBarFrame];
    rect.size.height += self.navigationController.navigationBar.frame.size.height;
    self.xOverView.initHeight = rect.size.height;
    [self refreshView];
}

- (void) showHint:(UIButton *)button
{
    NSString * msgString = @"To select a filter please double tap on it or tap and hold > 1sec. Horizontal slide changes a frequency, vertical one controls PEQ's gain or LPF/HPF's order. Zoomin-zoomout to control Q of PEQ.";

    [[DialogSystem sharedInstance] showAlert:msgString];
}


- (void) setTitleInfo
{
    id activeDspElement = [self.dspElements objectForKey:self.activeElementKey];
    
    if (!activeDspElement) return;
    
    NSString * s;
    if ([self.activeElementKey containsString:@"EQ"]){
        s = [NSString stringWithFormat:@"PEQ%@", [self.activeElementKey substringFromIndex:3]];
    } else {
        s = self.activeElementKey;
    }
    
    NSString *title = [NSString stringWithFormat:@"%@:%@", s, [activeDspElement getInfo]];
    
    [self setTitle:title];
}

-(void) refreshView
{
    [self setTitleInfo];
    [xOverView setNeedsDisplay];
    
}

- (IBAction)setPeqFlag:(id)sender {
    BiquadContainer * biquadContainer = [self.dspElements objectForKey:@"PEQS"];
    
    if ([biquadContainer isEnabled]){
        [biquadContainer setEnabled:NO];
        self.peqFlag_outl.title = @"PEQ Off";
        _addEQ_outl.enabled = NO;
    } else {
        [biquadContainer setEnabled:YES];
        self.peqFlag_outl.title = @"PEQ On";
        _addEQ_outl.enabled = YES;
    }
    
    _activeElementKey = [self getFirstEnableParametric];
    self.xOverView.activeElementKey = self.activeElementKey;
    
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
    id dspElement = [self.dspElements objectForKey:self.activeElementKey];
    
    [self moved:dspElement  gesture:recognizer];
    //ble send
    [dspElement sendWithResponse:NO];
    
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
    
    if (![self.activeElementKey containsString:@"EQ"]) return;
    
    Biquad * dspElement = [self.dspElements objectForKey:self.activeElementKey];
    dspElement.qFac /= currentScaleFactor;
    //send to dsp cc2540
    [dspElement sendWithResponse:NO];
    
    //display refresh
    [self refreshView];
    
}

// sequence EQ1, EQ2 .. EQn, HP, LP, EQ1 ...
- (NSString *) nextElement:(NSString *) key
{
    if ([key containsString:@"EQ#"]){
        
        int k = [[key substringFromIndex:3] intValue];//get int index of EQ and convert to integer format
        NSString * nextKey = [NSString stringWithFormat:@"EQ#%d", k + 1];
        
        
        if ([self.dspElements objectForKey:nextKey]){ //if object exist
            return nextKey;
        } else if ([self.dspElements objectForKey:@"HP"]){
            return @"HP";
        } else if ([self.dspElements objectForKey:@"LP"]){
            return @"LP";
        } else if ([self.dspElements objectForKey:@"EQ#1"]){
            return @"EQ#1";
        }
        
    } else if ([key containsString:@"HP"]){
        if ([self.dspElements objectForKey:@"LP"]){
            return @"LP";
        } else if ([self.dspElements objectForKey:@"EQ#1"]){
            return @"EQ#1";
        }
        
    } else if ([key containsString:@"LP"]){
        if ([self.dspElements objectForKey:@"EQ#1"]){
            return @"EQ#1";
        } else if ([self.dspElements objectForKey:@"LP"]){
            return @"LP";
            
        }
        
    }
    
    return nil;
}

- (void ) selectActiveFilter:(UIGestureRecognizer *)recognizer
{
    CGPoint tap_point = [recognizer locationInView:recognizer.view];
    
    NSString * elementKey = self.activeElementKey;
    
    for (int u = 0; u < self.dspElements.allKeys.count; u++){
        elementKey = [self nextElement:elementKey];
        
        id dspElement = [self.dspElements objectForKey:elementKey];
        
        if ([dspElement isKindOfClass:[Biquad class]]){//skip DspBiquad with Enabled == NO
            if (((Biquad *)dspElement).type != BIQUAD_PARAMETRIC){
                continue;
            }
        }
        
        if ([self checkCross:dspElement tap_point:tap_point]){
            self.activeElementKey = elementKey;
            self.xOverView.activeElementKey = self.activeElementKey;
            break;
        }
    }
    
    
    [self refreshView];
}


- (void) moved:(id)dspElement gesture:(UIPanGestureRecognizer *)recognizer
{
    if ((![dspElement isKindOfClass:[Biquad class]]) && (![dspElement isKindOfClass:[PassFilter class]])) {
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
            if ([dspElement isKindOfClass:[Biquad class]]){
                Biquad * biquad = dspElement;
                biquad.freq += delta_freq;
            }
            if ([dspElement isKindOfClass:[PassFilter class]]) {
                PassFilter * filter = dspElement;
                [filter setFreq:([filter Freq] + (int)delta_freq)];
            }
        }

    }
    
    //y-axis moved handler different for filter and biquad elements
    if ([dspElement isKindOfClass:[Biquad class]]){//DspBiquad
        if (((fabs(translation.y) > [self.xOverView getHeight] * 0.1) || (yHysteresisFlag)) && (!xHysteresisFlag)){
            yHysteresisFlag = YES;
        //if ((abs((int)dy) > 20 ) || (change_freq == NO)){
            float bb_vol = [xOverView dbToPixel:[dspElement dbVolume]];
            [dspElement setDbVolume:[xOverView pixelToDb:(bb_vol + dy / 4.0f)]];
            
            
            //change_freq = NO;
            //prev_translation.y = translation.y;
        }
    } else {//PassFilter
        PassFilter * filter = (PassFilter *)dspElement;
        
        /*if ((dy < -100 ) && (filter.order > FILTER_ORDER_2)){
            filter.order--;
            //filter.Order--;
            prev_translation.y = translation.y;
            change_freq = NO;
        }
        if ((dy > 100 ) && (filter.order < FILTER_ORDER_8)){
            filter.order++;
            //filter.Order++;
            prev_translation.y = translation.y;
            change_freq = NO;
        }*/
        
    }
    
    prev_translation = translation;
    
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
    
    if ([dspElement isKindOfClass:[Biquad class]]){
        Biquad * biquad = (Biquad *)dspElement;
        if (biquad.type == BIQUAD_PARAMETRIC){
            return [self checkCrossParamFilters:biquad point_x:tap_point.x];
        }
    } else if ([dspElement isKindOfClass:[PassFilter class]]){
        PassFilter * filter = (PassFilter *)dspElement;
        
        if (filter.type == BIQUAD_HIGHPASS){
            
            int start_x = [xOverView freqToPixel:xOverView.minFreq];
            int end_x = [xOverView getHighPassBorderPix];
            return [self checkCrossHighLowPass:start_x end_x:end_x tap_point:tap_point];
            
        } else if (filter.type == BIQUAD_LOWPASS){
            
            int start_x = [xOverView getLowPassBorderPix];
            int end_x = [xOverView freqToPixel:xOverView.maxFreq];
            return [self checkCrossHighLowPass:start_x end_x:end_x tap_point:tap_point];
        }
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
    id dspElement = [self.dspElements objectForKey:self.activeElementKey];
    
    if ([dspElement isKindOfClass:[Biquad class]]){
        Biquad * biquad = (Biquad *)dspElement;
        biquad.type = BIQUAD_DISABLED;
        biquad.dbVolume = 0.0;
        
        //ble send
        [dspElement sendWithResponse:YES];
        
        //choose new active element
        NSString * keyParametric = [self getFirstEnableParametric];
        
        if (!keyParametric){
            if ([self.dspElements objectForKey:@"HP"]){
                keyParametric = @"HP";
            } else if ([self.dspElements objectForKey:@"LP"]){
                keyParametric = @"LP";
            }
        }
        self.activeElementKey = keyParametric;
        
        self.xOverView.activeElementKey = self.activeElementKey;
        
        [self refreshView];
    }
}


/*- (IBAction)touchupinside:(id)sender {
    NSLog(@"touchupinside");
    addKeyDown = NO;
    
    if (addParametricSuccess == NO){
        [self enableNextBiquadsWithQfac:1.41f
                               dbVolume:0.0f];
        
        [self refreshView];
    }
    
}

- (IBAction)touchupoutside:(id)sender {
    NSLog(@"touchupoutside");
    addKeyDown = NO;
    
    if (addParametricSuccess == NO){
        [self enableNextBiquadsWithQfac:1.41f
                               dbVolume:0.0f];
        
        [self refreshView];
    }
}



- (IBAction)touchdown:(id)sender {
    NSLog(@"touchdown");
    addKeyDown = YES;
    addParametricSuccess = NO;
}*/

//advanced function for add del and other manage operation with biquads
- (NSString *) getFirstEnableParametric
{
    if ((!self.dspElements) || (self.dspElements.count == 0)){
        return nil;
    } else {
        NSString * keyParametric;
        
        int index = 1;
        
        while (1){
            keyParametric = [NSString stringWithFormat:@"EQ#%d", index];
            Biquad * biquad = (Biquad *)[self.dspElements objectForKey:keyParametric];
            
            if (!biquad){
                break;
            }
            
            if (biquad.type == BIQUAD_PARAMETRIC){//return first biquad with Enable==YES
                return keyParametric;
            }
            
            index++;
        }
    }
    
    if ([self.dspElements objectForKey:@"HP"]){
        return @"HP";
    } else if ([self.dspElements objectForKey:@"LP"]){
        return @"LP";
    }
    
    
    return nil;
}

- (NSString *) getFirstDisableParametric
{
    if ((!self.dspElements) || (self.dspElements.count == 0)){
        return nil;
    } else {
        NSString * keyParametric;
        
        int index = 1;
        
        while (1){
            keyParametric = [NSString stringWithFormat:@"EQ#%d", index];
            Biquad * biquad = (Biquad *)[self.dspElements objectForKey:keyParametric];
            
            if (!biquad){
                break;
            }
            
            if (biquad.type == BIQUAD_DISABLED){//return first biquad with Enable==YES
                return keyParametric;
            }
            
            index++;
        }
    }
    
    return nil;
}

- (int) getFreqForNextEnabledParametric{
    int freq = -1;
    
    if ((!self.dspElements) || (self.dspElements.count == 0)){
        return freq;
    }
    
    NSMutableArray * freqs = [[NSMutableArray alloc] init];
    
    //get freqs of all enabled dspElements
    for (int u = 0; u < self.dspElements.count; u++){
        
        id dspElement = [self.dspElements.allValues objectAtIndex:u];
        
        //get freqs
        if ([dspElement isKindOfClass:[Biquad class]]){//skip DspBiquad with Enabled == NO
            Biquad * biquad = dspElement;
            
            if (biquad.type == BIQUAD_PARAMETRIC){
                [freqs addObject:[NSNumber numberWithInt:biquad.freq]];
            }
        } else if ([dspElement isKindOfClass:[PassFilter class]]){
            PassFilter * filter = dspElement;
            [freqs addObject:[NSNumber numberWithInt:[filter Freq]]];
        } /*else {
           return -1; //error
           }*/
    }
    
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
    NSString * firstKeyDisableBiquad = [self getFirstDisableParametric];
    
    if (!firstKeyDisableBiquad) return NO;//error, not find disable biquad
    
    Biquad * biquad = [self.dspElements objectForKey:firstKeyDisableBiquad];
    biquad.type = BIQUAD_PARAMETRIC;
    biquad.freq = Freq;
    biquad.qFac = Qfac;
    biquad.dbVolume = dbVolume;
    
    self.activeElementKey = firstKeyDisableBiquad;
    self.xOverView.activeElementKey = self.activeElementKey;
    
    return YES;
}

//freq find automatically
- (BOOL) enableNextBiquadsWithQfac:(double)Qfac
                          dbVolume:(double) dbVolume
{
    NSString * firstKeyDisableBiquad = [self getFirstDisableParametric];
    
    if (!firstKeyDisableBiquad) return NO;//error, not find disable biquad
    
    Biquad * biquad = [self.dspElements objectForKey:firstKeyDisableBiquad];
    biquad.type = BIQUAD_PARAMETRIC;
    
    int freq = [self getFreqForNextEnabledParametric];
    if (freq == -1){
        biquad.freq = 300;
    } else {
        biquad.freq = freq;
    }
    biquad.qFac = Qfac;
    biquad.dbVolume = dbVolume;
    
    self.activeElementKey = firstKeyDisableBiquad;
    self.xOverView.activeElementKey = self.activeElementKey;
    
    return YES;
}
@end
