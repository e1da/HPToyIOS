//
//  BiquadParam.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 23/10/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : uint8_t {
    BIQUAD_ORDER_1,
    BIQUAD_ORDER_2
} BiquadOrder_t;

typedef enum : uint8_t {
    BIQUAD_LOWPASS      = 2,
    BIQUAD_HIGHPASS     = 1,
    BIQUAD_OFF          = 0,
    BIQUAD_PARAMETRIC   = 3,
    BIQUAD_ALLPASS      = 4,
    BIQUAD_BANDPASS     = 5,
    BIQUAD_USER         = 6
} BiquadType_t;

typedef struct {
    uint16_t    maxFreq;
    uint16_t    minFreq;
    float       maxQ;
    float       minQ;
    float       maxDbVol;
    float       minDbVol;
} BiquadParamBorder_t;

#pragma pack(1)
typedef struct {
    float b0;
    float b1;
    float b2;
    float a1;
    float a2;
} BiquadCoef_t;


typedef struct {
    BiquadOrder_t   order;
    BiquadType_t    type;
    uint16_t        freq;
    float           qFac;
    float           dbVolume;
} BiquadParam_t;
#pragma options align=reset


@class BiquadParam;

@protocol BiquadParamDelegate

- (void) didUpdateBiquadParam:(BiquadParam *) param;
@end
    
@interface BiquadParam : NSObject <NSCopying>

@property (nonatomic) id <BiquadParamDelegate> delegate;

@property (nonatomic)   uint16_t        freq;
@property (nonatomic)   float           qFac;
@property (nonatomic)   float           dbVolume;

//border property
@property (nonatomic)   BiquadParamBorder_t border;

+ (BiquadParam *)       initWithCoef:(BiquadCoef_t)coef withBorder:(BiquadParamBorder_t)border
                           withOrder:(BiquadOrder_t)order withType:(BiquadType_t)type;
- (void)                updateWithCoef:(BiquadCoef_t)coef withOrder:(BiquadOrder_t)order withType:(BiquadType_t)type;

- (double)              getFreqPercent;
- (void)                setFreqPercent:(double)percent;

- (void) setBorderMaxFreq:(int)maxFreq minFreq:(int)minFreq;
- (void) setBorderMaxQ:(double)maxQ minQfac:(double)minQ;
- (void) setBorderMaxDbVol:(double)maxDbVol minDbVolume:(double)minDbVol;

// math calculation
- (double) get_LPF:(double)freqX;
- (double) get_HPF:(double)freqX;
- (double) get_PeakingEQ:(double)freqX;

@end

NS_ASSUME_NONNULL_END
