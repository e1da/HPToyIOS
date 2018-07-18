//
//  PassFilter2.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 28/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HiFiToyObject.h"
#import "Biquad.h"

#define MAX_ORDER   FILTER_ORDER_4

typedef BiquadType_t PassFilterType_t;

typedef enum : int8_t{
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
    uint8_t             addr[2];        //0x00
    PassFilter_t        filter;         //0x02
} PassFilterPacket_t;                   //size == 6
#pragma options align=reset


@interface PassFilter2 : NSObject <HiFiToyObject, NSCoding, NSCopying, XmlParserDelegate>

@property (nonatomic)   int                 address0;
@property (nonatomic)   int                 address1; //if == 0 then off else stereo (2nd channel)

@property (nonatomic)   PassFilterOrder_t   order;
@property (nonatomic)   PassFilterType_t    type;
@property (nonatomic)   int                 freq;

//border property
@property (nonatomic)   int             maxFreq;
@property (nonatomic)   int             minFreq;


+ (PassFilter2 *)initWithAddress0:(int)address0
                         Address1:(int)address1
                            Order:(PassFilterOrder_t)order
                             Type:(PassFilterType_t)type
                             Freq:(int)freq;

+ (PassFilter2 *)initWithAddress:(int)address
                           Order:(PassFilterOrder_t)order
                            Type:(PassFilterType_t)type
                            Freq:(int)freq;


//getter/setter
- (void) setBorderMaxFreq:(int)maxFreq minFreq:(int)minFreq;

- (void) setFreqPercent:(double)percent;
- (double) getFreqPercent;

- (double) getAFR:(double)freqX;

@end
