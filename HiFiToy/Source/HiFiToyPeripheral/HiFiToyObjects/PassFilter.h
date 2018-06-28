//
//  PassFilter.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 30/05/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HiFiToyObject.h"
#import "Biquad.h"

typedef BiquadType_t PassFilterType_t;

typedef enum : uint8_t{
    BIQUAD_LENGTH_0, BIQUAD_LENGTH_1, BIQUAD_LENGTH_2, BIQUAD_LENGTH_4
} BiquadLength_t;

typedef enum : uint8_t{
    FILTER_ORDER_0 = 0,
    FILTER_ORDER_2 = 1,
    FILTER_ORDER_4 = 2,
    FILTER_ORDER_8 = 3
} PassFilterOrder_t;

#pragma pack(1)
typedef struct {
    PassFilterOrder_t   order;
    PassFilterType_t    type;
    uint16_t freq;
} PassFilter_t;

typedef struct {
    uint8_t             addr;           //0x00
    uint8_t             biquadLength;   //0x01, val = 1, 2, 4
    PassFilter_t        filter;         //0x02
} PassFilterPacket_t;                   //size == 6
#pragma options align=reset

@interface PassFilter : NSObject <HiFiToyObject, NSCoding, NSCopying, XmlParserDelegate>

@property (nonatomic)   Biquad * biquad0;
@property (nonatomic)   Biquad * biquad1;
@property (nonatomic)   Biquad * biquad2;
@property (nonatomic)   Biquad * biquad3;

//@property (nonatomic)   PassFilterOrder_t order;

//border property
@property (nonatomic)   PassFilterOrder_t maxOrder;
@property (nonatomic)   PassFilterOrder_t minOrder;


+ (PassFilter *)initWithOrder:(PassFilterOrder_t)order Type:(PassFilterType_t)type Freq:(int)freq
                         Addr:(int)addr
                 BiquadLength:(BiquadLength_t)biquadLength;

// getter/setter
-(void) setOrder:(PassFilterOrder_t)order;
-(PassFilterOrder_t) getOrder;
-(void) setType:(PassFilterType_t)type;
-(PassFilterType_t) getType;

-(void) setFreq:(int)freq;
-(int) Freq;

//-(void) setEnabled:(BOOL)enabled;
-(BOOL) isEnabled;

//-(void) setPassFilter:(PassFilter *)filter;

//border setter function
- (void) setBorderMaxFreq:(int)maxFreq minFreq:(int)minFreq;
- (void) setBorderMaxQfac:(double)maxQfac minQfac:(double)minQfac;
- (void) setBorderMaxDbVolume:(double)maxDbVolume minDbVolume:(double)minDbVolume;
- (void) setBorderMaxOrder:(PassFilterOrder_t)maxOrder minOrder:(PassFilterOrder_t)minOrder;

- (void) setBorderMaxFreq:(int)maxFreq minFreq:(int)minFreq
                  maxQfac:(double)maxQfac minQfac:(double)minQfac
              maxDbVolume:(double)maxDbVolume minQfac:(double)minDbVolume
                 maxOrder:(PassFilterOrder_t)maxOrder minOrder:(PassFilterOrder_t)minOrder;

/*-----------------------------------------------------------------------------------------
 Math Calculation
 -----------------------------------------------------------------------------------------*/
- (double) getAFR:(double)freqX;

@end
