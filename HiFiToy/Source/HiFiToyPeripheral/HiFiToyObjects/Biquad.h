//
//  Biquad.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 30/05/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HiFiToyObject.h"

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
    BIQUAD_BANDPASS     = 5
} BiquadType_t;

#pragma pack(1)
typedef struct {
    BiquadOrder_t   order;
    BiquadType_t    type;
    uint16_t        freq;
    float           q;
    float           volume;
} Biquad_t;

typedef struct {
    uint8_t         addr[2]; //0x00
    Biquad_t        biquad;  //0x02
} BiquadPacket_t;   //size = 14
#pragma options align=reset

@interface Biquad : NSObject <HiFiToyObject, NSCoding, NSCopying, XmlParserDelegate>

@property (nonatomic)   int     address0;
@property (nonatomic)   int     address1; //if == 0 then off else stereo (2nd channel)

@property (nonatomic)   BiquadOrder_t   order;
@property (nonatomic)   BiquadType_t    type;
@property (nonatomic)   int             freq;
@property (nonatomic)   double          qFac;
@property (nonatomic)   double          dbVolume;

//border property
@property (nonatomic)   int             maxFreq;
@property (nonatomic)   int             minFreq;
@property (nonatomic)   double          maxQfac;
@property (nonatomic)   double          minQfac;
@property (nonatomic)   double          maxDbVolume;
@property (nonatomic)   double          minDbVolume;

+ (Biquad *)initWithAddress:(int)address
                         Order:(BiquadOrder_t)order
                          Type:(BiquadType_t)type
                          Freq:(int)freq
                          Qfac:(double)qFac
                      dbVolume:(double) dbVolume;

+ (Biquad *)initWithAddress0:(int)address0
                    Address1:(int)address1
                      Order:(BiquadOrder_t)order
                       Type:(BiquadType_t)type
                       Freq:(int)freq
                       Qfac:(double)qFac
                   dbVolume:(double) dbVolume;

/*-----------------------------------------------------------------------------------------
 Math Calculation
 -----------------------------------------------------------------------------------------*/
- (double) getAFR:(double)freqX;

//border setter function
- (void) setBorderMaxFreq:(int)maxFreq minFreq:(int)minFreq;
- (void) setBorderMaxQfac:(double)maxQfac minQfac:(double)minQfac;
- (void) setBorderMaxDbVolume:(double)maxDbVolume minDbVolume:(double)minDbVolume;

- (void) setBorderMaxFreq:(int)maxFreq minFreq:(int)minFreq
                  maxQfac:(double)maxQfac minQfac:(double)minQfac
              maxDbVolume:(double)maxDbVolume minDbVolume:(double)minDbVolume;

- (void) setFreqPercent:(double)percent;
- (double) getFreqPercent;

- (void) setBiquad:(Biquad *)biquad;


@end
