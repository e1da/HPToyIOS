//
//  XOver.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 27/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ParamFilterContainer.h"
#import "PassFilter2.h"

#define MAX_BIQUADS 7

typedef enum : uint8_t{
    ERROR          = 0x00,
    HP0_LP0_PARAM7 = 0x07,//b0 00 00 111
    HP0_LP1_PARAM6 = 0x0E,//b0 00 01 110
    HP0_LP2_PARAM5 = 0x15,//b0 00 10 101
    HP1_LP0_PARAM6 = 0x26,//b0 01 00 110
    HP1_LP1_PARAM5 = 0x2D,//b0 01 01 101
    HP1_LP2_PARAM4 = 0x34,//b0 01 10 100
    HP2_LP0_PARAM5 = 0x45,//b0 10 00 101
    HP2_LP1_PARAM4 = 0x4C,//b0 10 01 100
    HP2_LP2_PARAM3 = 0x53,//b0 10 10 011
} XOverState_t;

@interface XOver : NSObject <HiFiToyObject, NSCoding, NSCopying, XmlParserDelegate>

@property (nonatomic) int           address0;
@property (nonatomic) int           address1;

//@property (nonatomic) XOverState_t  state;

@property (nonatomic) ParamFilterContainer  * params;
@property (nonatomic) PassFilter2           * hp;
@property (nonatomic) PassFilter2           * lp;

//stereo
+ (XOver *)initWithAddress0:(int)address0 Address1:(int)address1
                     Params:(ParamFilterContainer *)params Hp:(PassFilter2 *)hp Lp:(PassFilter2 *)lp;
//mono
+ (XOver *)initWithAddress:(int)address
                     Params:(ParamFilterContainer *)params Hp:(PassFilter2 *)hp Lp:(PassFilter2 *)lp;

- (XOverState_t) getState;
- (int) getLength;

- (void) update;

- (double) getAFR:(double)freqX;

@end
