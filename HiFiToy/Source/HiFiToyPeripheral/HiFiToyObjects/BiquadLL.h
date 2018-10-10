//
//  BiquadLL.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 07/10/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HiFiToyObject.h"
#import "Number523.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : uint8_t {
    BIQUAD_ORDER_1,
    BIQUAD_ORDER_2
} BiquadOrder_t;

typedef enum : uint8_t {
    BIQUAD_LOWPASS      = 2,
    BIQUAD_HIGHPASS     = 1,
    BIQUAD_DISABLED     = 0,
    BIQUAD_PARAMETRIC   = 3,
    BIQUAD_ALLPASS      = 4,
    BIQUAD_BANDPASS     = 5,
    BIQUAD_USER         = 6
} BiquadType_t;

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

typedef struct {
    uint8_t         addr[2]; //0x00
    BiquadParam_t   biquad;  //0x02
} BiquadPacket_t;   //size = 14
#pragma options align=reset

extern bool isCoefEqual(float c0, float c1);
extern bool isBiquadCoefEqual(BiquadCoef_t arg0, BiquadCoef_t arg1);

@interface BiquadLL : NSObject <HiFiToyObject, NSCoding, NSCopying, XmlParserDelegate>

@property (nonatomic)   int     address0;
@property (nonatomic)   int     address1; //if == 0 then off else stereo (2nd channel)

@property (nonatomic) BiquadCoef_t coef;

+ (BiquadLL *)initWithAddress:(int)address;
+ (BiquadLL *)initWithAddress0:(int)address0 Address1:(int)address1;

// math calculation
- (double) getAFR:(double)freqX;

//setters/getters
- (BiquadOrder_t)   getOrder;
- (void)            setOrder:(BiquadOrder_t)order;
- (BiquadType_t)    getType;
- (void)            setType:(BiquadType_t)type;
- (int)             getFreq;
- (void)            setFreq:(int)freq;
- (double)          getFreqPercent;
- (void)            setFreqPercent:(double)percent;
- (float)           getQ;
- (void)            setQ:(float)q;
- (float)           getDbVol;
- (void)            setDbVol:(float)vol;

- (void)            setBiquadParam:(BiquadParam_t) param;
- (BiquadParam_t)   getBiquadParam;

- (void) setBorderMaxFreq:(int)maxFreq minFreq:(int)minFreq;
- (void) setBorderMaxQ:(double)maxQ minQfac:(double)minQ;
- (void) setBorderMaxDbVol:(double)maxDbVol minDbVolume:(double)minDbVol;
- (void) setBorderMaxFreq:(int)maxFreq minFreq:(int)minFreq
                     maxQ:(double)maxQ minQ:(double)minQ
                 maxDbVol:(double)maxDbVol minDbVol:(double)minDbVol;

//border property
@property (nonatomic)   int             maxFreq;
@property (nonatomic)   int             minFreq;
@property (nonatomic)   double          maxQ;
@property (nonatomic)   double          minQ;
@property (nonatomic)   double          maxDbVol;
@property (nonatomic)   double          minDbVol;

@end

NS_ASSUME_NONNULL_END
