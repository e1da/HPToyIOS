//
//  FiltersViewController.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 28/09/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "FiltersViewController.h"
#import "AdvSlider.h"
#import "NumValueControl.h"
#import "FilterLabel.h"
#import "FilterTypeControl.h"
#import "XOverView.h"


@interface FiltersViewController () {
    XOverView * filtersView;
    
    FilterTypeControl * filterTypeControl;
    UISegmentedControl * typeBiquadSegmentedControl;
    BiquadValueControl * biquadControl;
    BiquadCoefValueControl * biquadCoefControl;
}

@end

@implementation FiltersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    //UINavigationItem * topItem = self.navigationController.navigationBar.topItem;
    //topItem.title = @"";
    
    self.title = @"Filter menu";
    [self.view setBackgroundColor:[UIColor darkGrayColor]];
    [self initSubviews];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateSubviews];
}

- (void)initSubviews {
    filtersView = [[XOverView alloc] init];
    //[filtersView setBackgroundColor:[UIColor whiteColor]];
    //configure XOverView
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

    filterTypeControl = [[FilterTypeControl alloc] init];
    [filterTypeControl.prevBtn addTarget:self action:@selector(changeFilter:) forControlEvents:UIControlEventTouchUpInside];
    [filterTypeControl.nextBtn addTarget:self action:@selector(changeFilter:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:filterTypeControl];
    
    NSArray * types = [NSArray arrayWithObjects:@"LP", @"HP", @"Param", @"AllPass", @"User", @"Off", nil];
    typeBiquadSegmentedControl = [[UISegmentedControl alloc] initWithItems:types];
    [typeBiquadSegmentedControl setTintColor:[UIColor lightGrayColor]];
    [typeBiquadSegmentedControl addTarget:self action:@selector(changeTypeFilter:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:typeBiquadSegmentedControl];
    
    biquadControl = [[BiquadValueControl alloc] init];
    biquadControl.delegate = self;
    biquadControl.filters = self.filters;
    [self.view addSubview:biquadControl];
    
    biquadCoefControl = [[BiquadCoefValueControl alloc] init];
    biquadCoefControl.delegate = self;
    biquadCoefControl.filters = self.filters;
    [self.view addSubview:biquadCoefControl];
}

- (void) updateSubviews {
    _filters.activeNullLP = NO;
    _filters.activeNullHP = NO;
    
    BiquadLL * b = [_filters getActiveBiquad];
    
    [biquadControl update];
    [biquadCoefControl update];
    
    [typeBiquadSegmentedControl setEnabled:(![_filters isLowpassFull]) forSegmentAtIndex:0];
    [typeBiquadSegmentedControl setEnabled:(![_filters isHighpassFull]) forSegmentAtIndex:1];
    
    if (b.type == BIQUAD_HIGHPASS) {
        PassFilter * p = [_filters getHighpass];
       
        int dbOnOctave[4] = {0, 12, 24, 48};// db/oct
        filterTypeControl.titleLabel.text = [NSString stringWithFormat:@"HIGHPASS %ddb/oct", dbOnOctave[[p getOrder]]];
        filterTypeControl.titleLabel.textColor = [UIColor orangeColor];
        typeBiquadSegmentedControl.selectedSegmentIndex = 1;
        
        biquadControl.showOnlyFreq = YES;
        biquadControl.hidden = NO;
        biquadCoefControl.hidden = YES;
        
    } else if (b.type == BIQUAD_LOWPASS) {
        PassFilter * p = [_filters getLowpass];
        
        int dbOnOctave[4] = {0, 12, 24, 48};// db/oct
        filterTypeControl.titleLabel.text = [NSString stringWithFormat:@"LOWPASS %ddb/oct", dbOnOctave[[p getOrder]]];
        filterTypeControl.titleLabel.textColor = [UIColor orangeColor];
        typeBiquadSegmentedControl.selectedSegmentIndex = 0;
        
        biquadControl.showOnlyFreq = YES;
        biquadControl.hidden = NO;
        biquadCoefControl.hidden = YES;
        
    } else if (b.type == BIQUAD_PARAMETRIC){
        
        filterTypeControl.titleLabel.text = [NSString stringWithFormat:@"PARAMETRIC #%d", _filters.activeBiquadIndex];
        filterTypeControl.titleLabel.textColor = [UIColor orangeColor];
        typeBiquadSegmentedControl.selectedSegmentIndex = 2;
        
        biquadControl.showOnlyFreq = NO;
        biquadControl.hidden = NO;
        biquadCoefControl.hidden = YES;
        
    } else if (b.type == BIQUAD_ALLPASS) {
        
        filterTypeControl.titleLabel.text = [NSString stringWithFormat:@"ALLPASS #%d", _filters.activeBiquadIndex];
        filterTypeControl.titleLabel.textColor = [UIColor orangeColor];
        typeBiquadSegmentedControl.selectedSegmentIndex = 3;
        
        biquadControl.showOnlyFreq = YES;
        biquadControl.hidden = NO;
        biquadCoefControl.hidden = YES;
        
    } else if (b.type == BIQUAD_USER){ // off biquad
        
        filterTypeControl.titleLabel.text = [NSString stringWithFormat:@"USER BIQUAD #%d", _filters.activeBiquadIndex];
        filterTypeControl.titleLabel.textColor = [UIColor orangeColor];
        typeBiquadSegmentedControl.selectedSegmentIndex = 4;
        
        biquadControl.hidden = YES;
        biquadCoefControl.hidden = NO;
        
    } else {
        filterTypeControl.titleLabel.text = [NSString stringWithFormat:@"OFF BIQUAD #%d", _filters.activeBiquadIndex];
        filterTypeControl.titleLabel.textColor = [UIColor orangeColor];
        typeBiquadSegmentedControl.selectedSegmentIndex = 5;
        
        biquadControl.hidden = YES;
        biquadCoefControl.hidden = YES;
    }
    
    [filtersView setNeedsDisplay];
}

- (void) viewWillLayoutSubviews {
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if ((orientation== UIInterfaceOrientationLandscapeLeft) ||
        (orientation== UIInterfaceOrientationLandscapeRight)) {
        
        [self viewWillLayoutSubviewsLandscape];
    } else {
        [self viewWillLayoutSubviewsPortrait];
        
    }
    
}

- (void) viewWillLayoutSubviewsPortrait {
    int top = self.navigationController.navigationBar.frame.size.height + 20;
    int width = self.view.frame.size.width;
    int height = self.view.frame.size.height - top;
    
    filterTypeControl.hidden = NO;
    typeBiquadSegmentedControl.hidden = NO;
    [self updateSubviews];
    
    [filtersView setFrame:CGRectMake(0, top, width, 0.4 * height)];
    
    [filterTypeControl setFrame:CGRectMake(0, top + 0.4 * height, width, 0.1 * height)];
    
    [typeBiquadSegmentedControl setFrame:CGRectMake(0.1 * width, top + 0.52 * height,
                                                    0.8 * width, 0.1 * height)];
    
    biquadControl.frame = CGRectMake(0, top + 0.65 * height, width, 0.3 * height);
    biquadCoefControl.frame = CGRectMake(0.1 * width, top + 0.65 * height, 0.8 * width, 0.3 * height);
}

- (void) viewWillLayoutSubviewsLandscape {
    int top = self.navigationController.navigationBar.frame.size.height;
    int width = self.view.frame.size.width;
    int height = self.view.frame.size.height - top;
    
    filterTypeControl.hidden = YES;
    typeBiquadSegmentedControl.hidden = YES;
    biquadControl.hidden = YES;
    biquadCoefControl.hidden = YES;
    
    [filtersView setFrame:CGRectMake(0, top, width, height)];
    [filtersView setNeedsDisplay];
}

/* --------------------------------------------- Change filters method --------------------------------------------------- */
- (void) changeFilter:(UIButton *)btn {
    
    if ([btn.titleLabel.text isEqualToString:@"\u2329"]) { // press prev button
        [_filters prevActiveBiquadIndex];
        [self updateSubviews];
    } else if ([btn.titleLabel.text isEqualToString:@"\u232A"]) { // press next button
        [_filters nextActiveBiquadIndex];
        [self updateSubviews];
    }
}

/* --------------------------------------------- Change filters method --------------------------------------------------- */
- (void) changeTypeFilter:(UISegmentedControl *) segmentControl {
    
    BiquadLL * b = [_filters getActiveBiquad];
    BiquadType_t prevType = b.type;
    
    switch (segmentControl.selectedSegmentIndex) {
        case 0:
        {
            NSLog(@"LP");
            
            if ([_filters isLowpassFull]) break;
            
            PassFilter * lp = [_filters getLowpass];
            int freq = (lp) ? lp.Freq : 20000;
                
            b.enabled = YES;
            b.order = BIQUAD_ORDER_2;
            b.type = BIQUAD_LOWPASS;
            b.biquadParam.freq = freq;
                
            lp = [_filters getLowpass];
            [lp sendWithResponse:YES];
            
            break;
        }
        case 1:
        {
            NSLog(@"HP");
            
            if ([_filters isHighpassFull]) break;
            
            PassFilter * hp = [_filters getHighpass];
            int freq = (hp) ? hp.Freq : 20;
            
            b.enabled = YES;
            b.order = BIQUAD_ORDER_2;
            b.type = BIQUAD_HIGHPASS;
            b.biquadParam.freq = freq;
            
            hp = [_filters getHighpass];
            [hp sendWithResponse:YES];
            
            break;
        }
        case 2:
            NSLog(@"PEQ");
 
            b.enabled = [_filters isPEQEnabled];
            b.order = BIQUAD_ORDER_2;
            b.type = BIQUAD_PARAMETRIC;
            
            if (prevType != BIQUAD_ALLPASS) {
                int freq = [_filters getBetterNewFreq];
                b.biquadParam.freq = (freq != -1) ? freq : 100;
            }
            b.biquadParam.qFac = 1.41f;
            b.biquadParam.dbVolume = 0.0f;
            
            [b sendWithResponse:YES];
            break;
            
        case 3:
            NSLog(@"AP");
            
            b.enabled = YES;
            b.order = BIQUAD_ORDER_1;
            b.type = BIQUAD_ALLPASS;
            
            if (prevType != BIQUAD_PARAMETRIC) {
                int freq = [_filters getBetterNewFreq];
                b.biquadParam.freq = (freq != -1) ? freq : 100;
                b.biquadParam.qFac = 1.41f;
            }
            b.biquadParam.dbVolume = 0.0f;
            
            [b sendWithResponse:YES];
            break;
            
        case 4:
            NSLog(@"USER");

            b.enabled = YES;
            //b.order = BIQUAD_ORDER_2;
            b.type = BIQUAD_USER;
            
            [b sendWithResponse:YES];
            break;
            
        case 5:
            NSLog(@"OFF");
            
            b.enabled = YES;
            b.order = BIQUAD_ORDER_2;
            b.type = BIQUAD_OFF;
            
            [b sendWithResponse:YES];
            break;
    }
    
    if (prevType == BIQUAD_HIGHPASS) {
        PassFilter * pass = [_filters getHighpass];
        if (pass) [pass sendWithResponse:YES];
        
    } else if (prevType == BIQUAD_LOWPASS) {
        PassFilter * pass = [_filters getLowpass];
        if (pass) [pass sendWithResponse:YES];
    }
    
    [self updateSubviews];
}

/* ----------------------------------- Keyboard methods (change NumValueControl) ----------------------------------------- */
- (void) updateBiquadValueControl {
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
    [biquadControl updateValueControl:valControl];
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

@end
