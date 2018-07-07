//
//  PassFilter2.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 28/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HiFiToyObject.h"
#import "PassFilter.h"

@interface PassFilter2 : NSObject <HiFiToyObject, NSCoding, NSCopying, XmlParserDelegate>

@property (nonatomic)   int                 address0;
@property (nonatomic)   int                 address1; //if == 0 then off else stereo (2nd channel)

@property (nonatomic)   BiquadLength_t      biquadLength;
@property (nonatomic)   PassFilterOrder_t   order;
@property (nonatomic)   PassFilterType_t    type;
@property (nonatomic)   int                 freq;

//border property
@property (nonatomic)   int             maxFreq;
@property (nonatomic)   int             minFreq;


+ (PassFilter2 *)initWithAddress0:(int)address0
                         Address1:(int)address1
                     BiquadLength:(BiquadLength_t)biquadLength
                            Order:(PassFilterOrder_t)order
                             Type:(PassFilterType_t)type
                             Freq:(int)freq;

+ (PassFilter2 *)initWithAddress:(int)address
                     BiquadLength:(BiquadLength_t)biquadLength
                            Order:(PassFilterOrder_t)order
                             Type:(PassFilterType_t)type
                             Freq:(int)freq;


//getter/setter
- (void) setBorderMaxFreq:(int)maxFreq minFreq:(int)minFreq;

- (void) setFreqPercent:(double)percent;
- (double) getFreqPercent;

- (double) getAFR:(double)freqX;

@end
