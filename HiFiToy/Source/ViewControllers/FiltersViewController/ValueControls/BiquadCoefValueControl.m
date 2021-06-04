//
//  BiquadCoefValueControl.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 26/10/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "BiquadCoefValueControl.h"
#import "DialogSystem.h"

@implementation BiquadCoefValueControl

- (id) init {
    self = [super init];
    if (self) {
        filterTypeControl = [[FilterTypeControl alloc] init];
        [filterTypeControl.prevBtn addTarget:self action:@selector(changeFilter:) forControlEvents:UIControlEventTouchUpInside];
        [filterTypeControl.nextBtn addTarget:self action:@selector(changeFilter:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:filterTypeControl];
        
        NSArray * types = [NSArray arrayWithObjects:@"Gui", @"Text", nil];
        typeBiquadSegmentedControl = [[UISegmentedControl alloc] initWithItems:types];
        [typeBiquadSegmentedControl setTintColor:[UIColor lightGrayColor]];
        [typeBiquadSegmentedControl addTarget:self action:@selector(changeTypeFilter:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:typeBiquadSegmentedControl];
        
        b0Label = [self createValueControlWithLabel:@"B0:"];
        b1Label = [self createValueControlWithLabel:@"B1:"];
        b2Label = [self createValueControlWithLabel:@"B2:"];
        a1Label = [self createValueControlWithLabel:@"A1:"];
        a2Label = [self createValueControlWithLabel:@"A2:"];
        
        syncButton = [[UIButton alloc] init];
        FilterLabel * f = [[FilterLabel alloc] initWithText:@"SYNC" withFontSize:20];
        [syncButton setAttributedTitle:f.attributedText forState:UIControlStateNormal];
        [syncButton addTarget:self action:@selector(pressSync) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:syncButton];
    }
    return self;
}

- (NumValueControl *) createValueControlWithLabel:(NSString *)label {
    NumValueControl * control = [NumValueControl initWithType:NumberTypeMaxReal];
    control.delegate = self;
    control.arrowHidden = YES;
    control.leftLabel.text = label;
    [control.leftLabel setTextAlignment:NSTextAlignmentRight];
    control.leftLabel.size = 16;
    control.valueFontSize = 20;
    
    [self addSubview:control];
    
    return control;
}

- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGFloat h = (80 * 8 < height) ? 80 : height / 8;
    
    [filterTypeControl setFrame:CGRectMake(0, 0, width, h)];
    
    [typeBiquadSegmentedControl setFrame:CGRectMake(width / 2 - h, 1.1 * h, h * 2, 0.8 * h)];
    
    b0Label.frame = CGRectMake(0, 2 * h,   width, h);
    b1Label.frame = CGRectMake(0, 3 * h,  width, h);
    b2Label.frame = CGRectMake(0, 4 * h,  width, h);
    a1Label.frame = CGRectMake(0, 5 * h,  width, h);
    a2Label.frame = CGRectMake(0, 6 * h,  width, h);
    
    syncButton.frame = CGRectMake(0, 7.1 * h, width, h);
}

- (void) setCoefHidden:(BOOL)hidden {
    b0Label.hidden = hidden;
    b1Label.hidden = hidden;
    b2Label.hidden = hidden;
    a1Label.hidden = hidden;
    a2Label.hidden = hidden;
    syncButton.hidden = hidden;
}

- (void) update {
    if (!_filters) return;
    
    filterTypeControl.titleLabel.text = [NSString stringWithFormat:@"BIQUAD #%d", _filters.activeBiquadIndex + 1];
    filterTypeControl.titleLabel.textColor = [UIColor orangeColor];
    
    Biquad * b = [_filters getActiveBiquad];
    
    if (b.type == BIQUAD_USER) {
        typeBiquadSegmentedControl.selectedSegmentIndex = 1;
        //biquadCoefControl.hidden = NO;
        [self setCoefHidden:NO];
        
    } else {
        typeBiquadSegmentedControl.selectedSegmentIndex = 0;
        //biquadCoefControl.hidden = YES;
        [self setCoefHidden:YES];
    }
    
    
    if (b) {
        b0Label.numValue = b.coef.b0;
        b1Label.numValue = b.coef.b1;
        b2Label.numValue = b.coef.b2;
        a1Label.numValue = -b.coef.a1;
        a2Label.numValue = -b.coef.a2;
    }
    
    if (_delegate) [_delegate updateBiquadCoefValueControl];
}

- (void) updateCoefValueControl:(NumValueControl *)control {
    if (!_filters) return;
    
    Biquad * biquad = [_filters getActiveBiquad];
    if (!biquad) return;
    
    BiquadCoef_t coef = biquad.coef;
    
    if (control == b0Label) {
        coef.b0 = control.numValue;
        
    } else if (control == b1Label) {
        coef.b1 = control.numValue;
        
    } else if (control == b2Label) {
        coef.b2 = control.numValue;
        
    } else if (control == a1Label) {
        coef.a1 = -control.numValue;
        
    } else if (control == a2Label) {
        coef.a2 = -control.numValue;
        
    }
    
    biquad.coef = coef;
    [self update];
}

- (void) didPressValue:(NumValueControl *) control {
    if (_delegate) {
        [_delegate showKeyboardWithValue:control];
    }
}

- (void) pressSync {
    DialogSystem * dialog = [DialogSystem sharedInstance];
    
    [dialog showDialog:@"Info"
                 msg:NSLocalizedString(@"Are you sure want to sync biquad coefficients?", @"")
               okBtn:@"Sync"
           cancelBtn:@"Cancel"
        okBtnHandler:^(UIAlertAction * action) {
        
        [[self->_filters getActiveBiquad] sendWithResponse:YES];
        [dialog showAlert:@"Biquad coefficients are syncronized."];
        
    }
    cancelBtnHandler:nil];
}

/* --------------------------------------------- Change filters method --------------------------------------------------- */
- (void) changeFilter:(UIButton *)btn {
    if ([btn.titleLabel.text isEqualToString:@"\u2329"]) { // press prev button
        [_filters decActiveBiquadIndex];
        [self update];
    } else if ([btn.titleLabel.text isEqualToString:@"\u232A"]) { // press next button
        [_filters incActiveBiquadIndex];
        [self update];
    }
}
 
- (void) changeTypeFilter:(UISegmentedControl *) segmentControl {
    
    Biquad * b = [_filters getActiveBiquad];
    BiquadType_t prevType = b.type;
    
    switch (segmentControl.selectedSegmentIndex) {
        case 0: //gui
        {
            if (prevType != BIQUAD_USER) return;
            
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
        }
        case 1: //text
        {
            if (prevType == BIQUAD_USER) return;
            
            if (_delegate) [_delegate showTextBiquad];
            
            b.enabled = YES;
            //b.order = BIQUAD_ORDER_2;
            b.type = BIQUAD_USER;
            
            [b sendWithResponse:YES];
            break;
        }
    }
    
    if (prevType == BIQUAD_HIGHPASS) {
        PassFilter * pass = [_filters getHighpass];
        if (pass) [pass sendWithResponse:YES];
        
    } else if (prevType == BIQUAD_LOWPASS) {
        PassFilter * pass = [_filters getLowpass];
        if (pass) [pass sendWithResponse:YES];
    }
    
    [self update];
}

@end
