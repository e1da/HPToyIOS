//
//  BiquadParam.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 23/10/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "BiquadParam.h"
#import "HiFiToyObject.h"
#import "FloatUtility.h"

@implementation BiquadParam

- (id) init {
    self = [super init];
    if (self) {
        BiquadParamBorder_t b = {20000, 20, 10.0, 0.1, 12.0, -36.0};
        self.border = b;
        
        self.freq = 100;
        self.qFac = 1.41f;
        self.dbVolume = 0.0f;
    }
    return self;
}

+ (BiquadParam *) initWithCoef:(BiquadCoef_t)coef withBorder:(BiquadParamBorder_t)border withOrder:(BiquadOrder_t)order withType:(BiquadType_t)type {
    BiquadParam * instance = [[BiquadParam alloc] init];

    instance.border = border;
    [instance updateWithCoef:coef withOrder:order withType:type];
    return instance;
}


- (void) updateWithCoef:(BiquadCoef_t)coef withOrder:(BiquadOrder_t)order withType:(BiquadType_t)type{
    float arg, w0;

    if (order == BIQUAD_ORDER_2){
        switch (type){
            case BIQUAD_LOWPASS:
                arg = 2 * coef.b1 / coef.a1 + 1;
                if ((arg < 1.0f) && (arg > -1.0f)) break;
                
                w0 = acos(1.0f / arg);
                _freq = round(w0 * TAS5558_FS / (2 * M_PI));
                _qFac = sin(w0) * coef.a1 / (2 * (2 * cos(w0) - coef.a1));
                break;
                
            case BIQUAD_HIGHPASS:
                arg = 2 * coef.b1 / coef.a1 + 1;
                if ((arg < 1.0f) && (arg > -1.0f)) break;
                
                w0 = acos(-1.0f / arg);
                _freq = round(w0 * TAS5558_FS / (2 * M_PI));
                _qFac = sin(w0) * coef.a1 / (2 * (2 * cos(w0) - coef.a1));
                break;
                
            case BIQUAD_PARAMETRIC:
                arg = coef.a1 / (coef.b0 + coef.b2);
                if ((arg > 1.0f) || (arg < -1.0f)) break;
                
                w0 = acos(arg);
                _freq = round(w0 * TAS5558_FS / (2 * M_PI));
                
                arg = (coef.b0 * 2 * cos(w0) - coef.a1) / (2 * cos(w0) - coef.a1);
                if (arg < 0.0) break;
                
                float ampl = sqrt(arg);
                _dbVolume = 40 * log10(ampl);
                
                float alpha = (2 * cos(w0) / coef.a1 - 1) * ampl;
                _qFac = sin(w0) / (2 * alpha);
                break;
                
            case BIQUAD_ALLPASS:
                arg = coef.a1 / (coef.b0 + 1);
                if ((arg > 1.0f) || (arg < -1.0f)) break;
                
                w0 = acos(arg);
                _freq = round(w0 * TAS5558_FS / (2 * M_PI));
                _qFac = sin(w0) * coef.a1 / (2 * (2 * cos(w0) - coef.a1));
                break;
                
            case BIQUAD_BANDPASS:
                w0 = acos(coef.a1 / 2 * (1 + coef.b0 / (1 - coef.b0)));
                _freq = round(w0 * (float)TAS5558_FS / (2 * M_PI));
                //TODO set import bandwidth
                break;
                
            case BIQUAD_OFF:
            case BIQUAD_USER:
            default:
                break;
        } 
    } else {//BIQUAD_ORDER_1
        
        if (coef.a1 > 0) {
            w0 = -log10(coef.a1) / log10(2.7);
            _freq = round(w0 * TAS5558_FS / (2 * M_PI));
        }
    }
}

/*==========================================================================================
 NSCopying protocol implementation
 ==========================================================================================*/
-(BiquadParam *)copyWithZone:(NSZone *)zone {
    BiquadParam * copyParam = [[[self class] allocWithZone:zone] init];
    
    copyParam.border = self.border;
 
    copyParam.freq = self.freq;
    copyParam.qFac = self.qFac;
    copyParam.dbVolume = self.dbVolume;

    return copyParam;
}

/*==========================================================================================
 isEqual implementation
 ==========================================================================================*/
- (BOOL) isEqual: (id) object {
    
    if ([object isKindOfClass:[BiquadParam class]]) {
        BiquadParam * temp = object;
        
        BiquadParamBorder_t bTemp = temp.border;
        BiquadParamBorder_t b = self.border;
        
        if ((self.freq == temp.freq) &&
            (isFloatNull(self.qFac - temp.qFac)) &&
            (isFloatNull(self.dbVolume - temp.dbVolume)) &&
            
            (b.maxFreq == b.maxFreq) &&
            (b.minFreq == b.minFreq) &&
            (isFloatDiffLessThan(b.maxQ, bTemp.maxQ, 0.01f)) &&
            (isFloatDiffLessThan(b.minQ, bTemp.minQ, 0.01f)) &&
            (isFloatDiffLessThan(b.maxDbVol, bTemp.maxDbVol, 0.01f)) &&
            (isFloatDiffLessThan(b.minDbVol, bTemp.minDbVol, 0.01f)) ) {
            return YES;
        }
    }
    
    
    return NO;
}

/*- (BiquadType_t) getTypeFromCoef:(BiquadCoef_t)coef {
    
    if ( (isCoefEqual(coef.b0, 1.0f)) && (isFloatNull(coef.b1)) && (isFloatNull(coef.b2)) &&
        (isFloatNull(coef.a1)) && (isFloatNull(coef.a2)) ) {
        return BIQUAD_OFF;
        
    } else if ((isCoefEqual(coef.b1, 2 * coef.b0)) && (isCoefEqual(coef.b0, coef.b2)) ) {
        return BIQUAD_LOWPASS;
        
    } else if ((isCoefEqual(coef.b1, -2 * coef.b0)) && (isCoefEqual(coef.b0, coef.b2)) ) {
        return BIQUAD_HIGHPASS;
        
    } else if ((isCoefEqual(coef.b1, -coef.a1)) && (isCoefEqual(coef.b0, -coef.a2)) ) {
        return BIQUAD_ALLPASS;
        
    } else if (isCoefEqual(coef.b1, -coef.a1)) {
        return BIQUAD_PARAMETRIC;
        
    } else if ((isFloatNull(coef.b1)) && (isCoefEqual(coef.b0, -coef.b2)) ) {
        return BIQUAD_BANDPASS;
    }
    
    return BIQUAD_USER;
}

- (void) setType:(BiquadType_t)type {
    _type = type;
    if (_delegate) [_delegate didUpdateBiquadParam:self];
}*/

- (void) setFreq:(uint16_t)freq {
    if (freq > self.border.maxFreq) freq = self.border.maxFreq;
    if (freq < self.border.minFreq) freq = self.border.minFreq;
    
    _freq = freq;
    if (_delegate) [_delegate didUpdateBiquadParam:self];
}

- (double) getFreqPercent {
    uint16_t max = self.border.maxFreq;
    uint16_t min = self.border.minFreq;
    
    return (log10(self.freq) - log10(min)) / (log10(max) - log10(min));
}

- (void) setFreqPercent:(double)percent {
    if (percent > 1.0) percent = 1.0;
    if (percent < 0.0) percent = 0.0;
    
    uint16_t max = self.border.maxFreq;
    uint16_t min = self.border.minFreq;
    
    self.freq = pow(10, percent * (log10(max) - log10(min)) + log10(min));
}

- (void) setQFac:(float)qFac {
    if (qFac > self.border.maxQ) qFac = self.border.maxQ;
    if (qFac < self.border.minQ) qFac = self.border.minQ;
    
    _qFac = qFac;
    if (_delegate) [_delegate didUpdateBiquadParam:self];
}

- (void) setDbVolume:(float)dbVolume {
    if (dbVolume > self.border.maxDbVol) dbVolume = self.border.maxDbVol;
    if (dbVolume < self.border.minDbVol) dbVolume = self.border.minDbVol;
    
    _dbVolume = dbVolume;
    if (_delegate) [_delegate didUpdateBiquadParam:self];
}

/*- (void) setBiquadParam:(BiquadParam_t)p {
    _freq = p.freq;
    _qFac = p.qFac;
    _dbVolume = p.dbVolume;
    
    if (_delegate) [_delegate didUpdateBiquadParam:self];
}*/

/*- (BiquadParam_t) getBiquadParam {
    BiquadParam_t p;

    p.freq = _freq;
    p.qFac = _qFac;
    p.dbVolume = _dbVolume;
    
    return p;
}*/


//border setter function
- (void) setBorderMaxFreq:(int)maxFreq minFreq:(int)minFreq {
    _border.maxFreq = maxFreq;
    _border.minFreq = minFreq;
}

- (void) setBorderMaxQ:(double)maxQ minQfac:(double)minQ {
    _border.maxQ = maxQ;
    _border.minQ = minQ;
}

- (void) setBorderMaxDbVol:(double)maxDbVol minDbVolume:(double)minDbVol {
    _border.maxDbVol = maxDbVol;
    _border.minDbVol = minDbVol;
}

/*-----------------------------------------------------------------------------------------
 Math Calculation
 -----------------------------------------------------------------------------------------*/
- (double) get_LPF:(double)freqX {

    return sqrt(1.0f/(  pow(1 - pow(freqX / self.freq, 2), 2) + pow(freqX / (self.freq * self.qFac), 2)    ));
}

- (double) get_HPF:(double)freqX {
    return sqrt(pow( pow(freqX / self.freq , 4) - pow(freqX / self.freq, 2) , 2) +
                pow(freqX / self.freq, 6) / pow(self.qFac, 2))
    / (pow(1 - pow(freqX / self.freq, 2), 2) + pow(freqX / (self.qFac * self.freq), 2));
}

- (double) get_PeakingEQ:(double)freqX {
    double Ampl = pow(10, self.dbVolume / 40);
    double A1 = pow(1 - pow(freqX / self.freq, 2), 2) + pow(freqX / (self.qFac * self.freq), 2);
    double A2 = (1 - pow(freqX / self.freq, 2)) *
    (freqX * Ampl / (self.qFac * self.freq) - freqX / (Ampl * self.qFac * self.freq));
    
    double B = pow(1 - pow(freqX / self.freq, 2), 2) + pow(freqX / (Ampl * self.qFac * self.freq), 2);
    
    
    return  sqrt(pow(A1, 2) + pow(A2, 2)) / B;
}


@end
