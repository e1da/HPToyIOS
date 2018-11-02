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
        b0Label = [self createValueControlWithLabel:@"B0:"];
        b1Label = [self createValueControlWithLabel:@"B1:"];
        b2Label = [self createValueControlWithLabel:@"B2:"];
        a1Label = [self createValueControlWithLabel:@"A1:"];
        a2Label = [self createValueControlWithLabel:@"A2:"];
        
        syncButton = [[UIButton alloc] init];
        FilterLabel * f = [[FilterLabel alloc] initWithText:@"BIQUAD SYNC" withFontSize:20];
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
    
    b0Label.frame = CGRectMake(0,           0,              width / 2, height / 3);
    b1Label.frame = CGRectMake(0,           height / 3,     width / 2, height / 3);
    b2Label.frame = CGRectMake(0,           2 * height / 3, width / 2, height / 3);
    a1Label.frame = CGRectMake(width / 2,   0,              width / 2, height / 3);
    a2Label.frame = CGRectMake(width / 2,   height / 3,     width / 2, height / 3);
    
    syncButton.frame = CGRectMake(width / 2, 2 * height / 3, width / 2, height / 3);
}

- (void) update {
    if (!_filters) return;
    
    BiquadLL * b = [_filters getActiveBiquad];
    
    if (b) {
        b0Label.numValue = b.coef.b0;
        b1Label.numValue = b.coef.b1;
        b2Label.numValue = b.coef.b2;
        a1Label.numValue = -b.coef.a1;
        a2Label.numValue = -b.coef.a2;
    }
    
    //if (_delegate) [_delegate updateBiquadValueControl];
}

- (void) updateCoefValueControl:(NumValueControl *)control {
    if (!_filters) return;
    
    BiquadLL * biquad = [_filters getActiveBiquad];
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
    NSLog(@"press sync");
    [[DialogSystem sharedInstance] showBiquadCoefSyncDialog:[_filters getActiveBiquad]];
}

@end
