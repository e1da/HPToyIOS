//
//  PeqValueControl.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 25/10/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "BiquadValueControl.h"

@implementation BiquadValueControl

- (id) init {
    self = [super init];
    if (self) {
        freqControl = [NumValueControl initWithType:NumberTypePositiveInteger];
        freqControl.delegate = self;
        freqControl.leftLabel.text = @"FREQ";
        freqControl.leftLabel.textColor = [UIColor lightGrayColor];
        [freqControl.leftLabel setTextAlignment:NSTextAlignmentRight];
        freqControl.rightLabel.text = @"HZ";
        [freqControl.rightLabel setTextAlignment:NSTextAlignmentLeft];
        [self addSubview:freqControl];

        volumeControl = [NumValueControl initWithType:NumberTypeFloat];
        volumeControl.delegate = self;
        volumeControl.leftLabel.text = @"BOOST";
        [volumeControl.leftLabel setTextAlignment:NSTextAlignmentRight];
        volumeControl.rightLabel.text = @"DB";
        [volumeControl.rightLabel setTextAlignment:NSTextAlignmentLeft];
        [self addSubview:volumeControl];
        
        qfacControl = [NumValueControl initWithType:NumberTypePositiveDouble];
        qfacControl.delegate = self;
        qfacControl.leftLabel.text = @"Q-FAC";
        [qfacControl.leftLabel setTextAlignment:NSTextAlignmentRight];
        qfacControl.rightLabel.text = @"";
        [qfacControl.rightLabel setTextAlignment:NSTextAlignmentLeft];
        [self addSubview:qfacControl];
        
        self.showOnlyFreq = NO;
    }
    return self;
}

- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    freqControl.frame = CGRectMake(0,   0,              width, height / 3);
    volumeControl.frame = CGRectMake(0, height / 3,     width, height / 3);
    qfacControl.frame = CGRectMake(0,   2 * height / 3, width, height / 3);
}

- (void) setShowOnlyFreq:(BOOL)showOnlyFreq {
    _showOnlyFreq = showOnlyFreq;
    
    if (_showOnlyFreq) {
        qfacControl.hidden = YES;
        volumeControl.hidden = YES;
    } else {
        qfacControl.hidden = NO;
        volumeControl.hidden = NO;
    }
}

- (void) update {
    if (!_filters) return;
    
    BiquadLL * b = [_filters getActiveBiquad];
    
    if (b) {
        freqControl.numValue = b.biquadParam.freq;
        volumeControl.numValue = b.biquadParam.dbVolume;
        qfacControl.numValue = b.biquadParam.qFac;
    }
    
    if (_delegate) [_delegate updateBiquadValueControl];
}

- (void) updateValueControl:(NumValueControl *)control {
    if (!_filters) return;
    
    BiquadLL * biquad = [_filters getActiveBiquad];
    if (!biquad) return;
    
    BiquadParam * bParam = biquad.biquadParam;
    
    if (control == freqControl) {
        if (biquad.type == BIQUAD_LOWPASS) {
            PassFilter * lp = [_filters getLowpass];
            [lp setFreq:control.numValue];
            [lp sendWithResponse:YES];
            
        } else if (biquad.type == BIQUAD_HIGHPASS){
            PassFilter * hp = [_filters getHighpass];
            [hp setFreq:control.numValue];
            [hp sendWithResponse:YES];
            
        } else {
            bParam.freq = control.numValue;
            [biquad sendWithResponse:YES];
        }
        
    } else if (control == volumeControl) {
        bParam.dbVolume = control.numValue;
        [biquad sendWithResponse:YES];
        
    } else if (control == qfacControl) {
        bParam.qFac = control.numValue;
        [biquad sendWithResponse:YES];
    }
    
    [self update];
}

- (void) setFilters:(Filters *)filters {
    _filters = filters;
    [self update];
}

- (void) didPressNext:(NumValueControl *) control {
    if (!_filters) return;
    
    BiquadLL * biquad = [_filters getActiveBiquad];
    if (!biquad) return;
    
    BiquadParam * bParam = biquad.biquadParam;
    
    if (control == freqControl) {
        
        int delta;
        if (bParam.freq < 100) {
            delta = 10;
        } else if (bParam.freq < 1000) {
            delta = 100;
        } else {
            delta = 1000;
        }
        
        uint16_t newFreq;
        if (bParam.freq % delta != 0) {
            newFreq = bParam.freq / delta * delta + delta;
        } else {
            newFreq = bParam.freq + delta;
        }
        
        if (biquad.type == BIQUAD_LOWPASS) {
            PassFilter * lp = [_filters getLowpass];
            [lp setFreq:newFreq];
            [lp sendWithResponse:YES];
            
        } else if (biquad.type == BIQUAD_HIGHPASS){
            PassFilter * hp = [_filters getHighpass];
            [hp setFreq:newFreq];
            [hp sendWithResponse:YES];
            
        } else {
            bParam.freq = newFreq;
            [biquad sendWithResponse:YES];
        }
        
    } else if (control == volumeControl) {
        bParam.dbVolume += 0.1;
        [biquad sendWithResponse:YES];
        
    } else if (control == qfacControl) {
        bParam.qFac += 0.01;
        [biquad sendWithResponse:YES];
    }
    
    [self update];
}

- (void) didPressPrev:(NumValueControl *) control {
    if (!_filters) return;
    
    BiquadLL * biquad = [_filters getActiveBiquad];
    if (!biquad) return;
    
    BiquadParam * bParam = biquad.biquadParam;
    
    if (control == freqControl) {
        
        int delta;
        if (bParam.freq <= 100) {
            delta = 10;
        } else if (bParam.freq <= 1000) {
            delta = 100;
        } else {
            delta = 1000;
        }
        
        uint16_t newFreq;
        if (bParam.freq % delta != 0) {
            newFreq = bParam.freq / delta * delta;
        } else {
            newFreq = bParam.freq - delta;
        }
        
        if (biquad.type == BIQUAD_LOWPASS) {
            PassFilter * lp = [_filters getLowpass];
            [lp setFreq:newFreq];
            [lp sendWithResponse:YES];
            
        } else if (biquad.type == BIQUAD_HIGHPASS){
            PassFilter * hp = [_filters getHighpass];
            [hp setFreq:newFreq];
            [hp sendWithResponse:YES];
            
        } else {
            bParam.freq = newFreq;
            [biquad sendWithResponse:YES];
        }
        
    } else if (control == volumeControl) {
        bParam.dbVolume -= 0.1;
        [biquad sendWithResponse:YES];
        
    } else if (control == qfacControl) {
        bParam.qFac -= 0.01;
        [biquad sendWithResponse:YES];
    }
    
    [self update];
}

- (void) didPressValue:(NumValueControl *) control {
    if (_delegate) {
        [_delegate showKeyboardWithValue:control];
    }
}

@end
