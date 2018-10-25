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


@interface FiltersViewController () {
    UIView * filtersView;
    
    FilterTypeControl * filterTypeControl;
    UISegmentedControl * typeBiquadSegmentedControl;
    
    NumValueControl * freqControl;
    NumValueControl * volumeControl;
    NumValueControl * qfacControl;
    
    UILabel * fL;
    
}

@end

@implementation FiltersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    UINavigationItem * topItem = self.navigationController.navigationBar.topItem;
    topItem.title = @"";
    
    self.title = @"Filter menu";
    [self.view setBackgroundColor:[UIColor darkGrayColor]];
    [self initSubviews];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateSubviews];
}

- (void)initSubviews {
    filtersView = [[UIView alloc] init];
    [filtersView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:filtersView];

    filterTypeControl = [[FilterTypeControl alloc] init];
    [filterTypeControl.prevBtn addTarget:self action:@selector(changeFilter:) forControlEvents:UIControlEventTouchUpInside];
    [filterTypeControl.nextBtn addTarget:self action:@selector(changeFilter:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:filterTypeControl];
    
    NSArray * types = [NSArray arrayWithObjects:@"LP",@"HP",@"Param", @"AllPass", @"Off", nil];
    typeBiquadSegmentedControl = [[UISegmentedControl alloc] initWithItems:types];
    [typeBiquadSegmentedControl setTintColor:[UIColor lightGrayColor]];
    typeBiquadSegmentedControl.enabled = NO;
    [self.view addSubview:typeBiquadSegmentedControl];
    
    freqControl = [[NumValueControl alloc] init];
    [freqControl setNumValue:500 withDeltaValue:10 withType:NumberTypePositiveInteger];
    freqControl.leftLabel.text = @"FREQ";
    freqControl.leftLabel.textColor = [UIColor lightGrayColor];
    [freqControl.leftLabel setTextAlignment:NSTextAlignmentRight];
    freqControl.rightLabel.text = @"HZ";
    [freqControl.rightLabel setTextAlignment:NSTextAlignmentLeft];
    [freqControl addValuePressEvent:self action:@selector(showKeyboardWithValue:)];
    [self.view addSubview:freqControl];
    
    volumeControl = [[NumValueControl alloc] init];
    [volumeControl setNumValue:-3 withDeltaValue:0.1 withType:NumberTypeFloat];
    volumeControl.leftLabel.text = @"BOOST";
    [volumeControl.leftLabel setTextAlignment:NSTextAlignmentRight];
    volumeControl.rightLabel.text = @"DB";
    [volumeControl.rightLabel setTextAlignment:NSTextAlignmentLeft];
    [volumeControl addValuePressEvent:self action:@selector(showKeyboardWithValue:)];
    [self.view addSubview:volumeControl];
    
    qfacControl = [[NumValueControl alloc] init];
    [qfacControl setNumValue:1.41 withDeltaValue:0.01 withType:NumberTypePositiveDouble];
    qfacControl.leftLabel.text = @"Q-FAC";
    [qfacControl.leftLabel setTextAlignment:NSTextAlignmentRight];
    qfacControl.rightLabel.text = @"";
    [qfacControl.rightLabel setTextAlignment:NSTextAlignmentLeft];
    [qfacControl addValuePressEvent:self action:@selector(showKeyboardWithValue:)];
    [self.view addSubview:qfacControl];
    
}

- (void) updateSubviews {
    BiquadLL * b = [_filters getActiveBiquad];
    BiquadType_t type = b.biquadParam.type;
    
    if (type == BIQUAD_HIGHPASS) {
        PassFilter * p = [_filters getHighpass];
       
        int dbOnOctave[4] = {0, 12, 24, 48};// db/oct
        filterTypeControl.titleLabel.text = [NSString stringWithFormat:@"HIGHPASS %ddb/oct", dbOnOctave[[p getOrder]]];
        filterTypeControl.titleLabel.textColor = [UIColor orangeColor];
        typeBiquadSegmentedControl.selectedSegmentIndex = 1;
        
        freqControl.hidden = NO;
        [freqControl setNumValue:[p Freq] withDeltaValue:10 withType:NumberTypePositiveInteger];
        volumeControl.hidden = YES;
        qfacControl.hidden = YES;
        
    } else if (type == BIQUAD_LOWPASS) {
        PassFilter * p = [_filters getLowpass];
        
        int dbOnOctave[4] = {0, 12, 24, 48};// db/oct
        filterTypeControl.titleLabel.text = [NSString stringWithFormat:@"LOWPASS %ddb/oct", dbOnOctave[[p getOrder]]];
        filterTypeControl.titleLabel.textColor = [UIColor orangeColor];
        typeBiquadSegmentedControl.selectedSegmentIndex = 0;
        
        freqControl.hidden = NO;
        [freqControl setNumValue:[p Freq] withDeltaValue:10 withType:NumberTypePositiveInteger];
        volumeControl.hidden = YES;
        qfacControl.hidden = YES;
        
    } else if (type == BIQUAD_PARAMETRIC){
        
        filterTypeControl.titleLabel.text = [NSString stringWithFormat:@"PARAMETRIC #%d", _filters.activeBiquadIndex];
        filterTypeControl.titleLabel.textColor = [UIColor orangeColor];
        typeBiquadSegmentedControl.selectedSegmentIndex = 2;
        
        BiquadParam * bParam = b.biquadParam;
        
        freqControl.hidden = NO;
        [freqControl setNumValue:bParam.freq withDeltaValue:10 withType:NumberTypePositiveInteger];
        volumeControl.hidden = NO;
        [volumeControl setNumValue:bParam.dbVolume withDeltaValue:0.1 withType:NumberTypeFloat];
        qfacControl.hidden = NO;
        [qfacControl setNumValue:bParam.qFac withDeltaValue:0.01 withType:NumberTypePositiveDouble];
        
    } else if (type == BIQUAD_ALLPASS) {
        
        filterTypeControl.titleLabel.text = [NSString stringWithFormat:@"ALLPASS #%d", _filters.activeBiquadIndex];
        filterTypeControl.titleLabel.textColor = [UIColor orangeColor];
        typeBiquadSegmentedControl.selectedSegmentIndex = 3;
        
        freqControl.hidden = NO;
        [freqControl setNumValue:b.biquadParam.freq withDeltaValue:10 withType:NumberTypePositiveInteger];
        volumeControl.hidden = YES;
        qfacControl.hidden = YES;
        
    } else { // off biquad
        
        filterTypeControl.titleLabel.text = [NSString stringWithFormat:@"OFF BIQUAD #%d", _filters.activeBiquadIndex];
        filterTypeControl.titleLabel.textColor = [UIColor orangeColor];
        typeBiquadSegmentedControl.selectedSegmentIndex = 4;
        
        freqControl.hidden = YES;
        volumeControl.hidden = YES;
        qfacControl.hidden = YES;
    }
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
    
    /*filterTypeControl.hidden = NO;
    typeBiquadSegmentedControl.hidden = NO;
    
    freqControl.hidden = NO;
    
    if ((self.xover.hp != activeElement) && (self.xover.lp != activeElement)) {
        volumeControl.hidden = NO;
        qfacControl.hidden = NO;
    } else {
        volumeControl.hidden = YES;
        qfacControl.hidden = YES;
    }*/
    [self updateSubviews];
    
    [filtersView setFrame:CGRectMake(0, top, width, 0.4 * height)];
    
    [filterTypeControl setFrame:CGRectMake(0, top + 0.4 * height, width, 0.1 * height)];
    
    [typeBiquadSegmentedControl setFrame:CGRectMake(0.1 * width, top + 0.52 * height,
                                                    0.8 * width, 0.1 * height)];
    
    freqControl.frame = CGRectMake(0, top + 0.65 * height, self.view.frame.size.width, 0.1 * height);
    volumeControl.frame = CGRectMake(0, top + 0.75 * height, self.view.frame.size.width, 0.1 * height);
    qfacControl.frame = CGRectMake(0, top + 0.85 * height, self.view.frame.size.width, 0.1 * height);
}

- (void) viewWillLayoutSubviewsLandscape {
    int top = self.navigationController.navigationBar.frame.size.height;
    int width = self.view.frame.size.width;
    int height = self.view.frame.size.height - top;
    
    filterTypeControl.hidden = YES;
    typeBiquadSegmentedControl.hidden = YES;
    
    freqControl.hidden = YES;
    volumeControl.hidden = YES;
    qfacControl.hidden = YES;
    
    [filtersView setFrame:CGRectMake(0, top, width, height)];
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

/* ----------------------------------- Keyboard methods (change NumValueControl) ----------------------------------------- */
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

- (void) didKeyboardEnter:(double) value {
    [self didKeyboardClose];
    
    NSLog(@"Return value = %@", [NSString stringWithFormat:@"%f", value]);
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
