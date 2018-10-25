//
//  BiquadLL.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 07/10/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HiFiToyObject.h"
#import "BiquadParam.h"
#import "Number523.h"

NS_ASSUME_NONNULL_BEGIN

#pragma pack(1)
typedef struct {
    uint8_t         addr[2]; //0x00
    BiquadParam_t   biquad;  //0x02
} BiquadPacket_t;   //size = 14
#pragma options align=reset

extern bool isBiquadCoefEqual(BiquadCoef_t arg0, BiquadCoef_t arg1);

@interface BiquadLL : NSObject <HiFiToyObject, NSCoding, NSCopying, XmlParserDelegate, BiquadParamDelegate>

@property (nonatomic)   BOOL    hiddenGui;
@property (nonatomic)   BOOL    enabled;

@property (nonatomic)   int     address0;
@property (nonatomic)   int     address1; //if == 0 then off else stereo (2nd channel)

@property (nonatomic) BiquadCoef_t  coef;
@property (nonatomic) BiquadParam * biquadParam;

+ (BiquadLL *)initWithAddress:(int)address;
+ (BiquadLL *)initWithAddress0:(int)address0 Address1:(int)address1;

- (double) getAFR:(double)freqX;

@end

NS_ASSUME_NONNULL_END
