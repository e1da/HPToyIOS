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


@interface XOver : NSObject <HiFiToyObject, NSCoding, NSCopying, XmlParserDelegate>

@property (nonatomic) int           address0;
@property (nonatomic) int           address1;

@property (nonatomic) ParamFilterContainer  * params;
@property (nonatomic) PassFilter2           * hp;
@property (nonatomic) PassFilter2           * lp;

//stereo
+ (XOver *)initWithAddress0:(int)address0 Address1:(int)address1
                     Params:(ParamFilterContainer *)params Hp:(PassFilter2 *)hp Lp:(PassFilter2 *)lp;
//mono
+ (XOver *)initWithAddress:(int)address
                     Params:(ParamFilterContainer *)params Hp:(PassFilter2 *)hp Lp:(PassFilter2 *)lp;
//stereo default
+ (XOver *)initDefaultWithAddress0:(int)address0 Address1:(int)address1;


- (int) getLength;
- (void) setOrder:(PassFilterOrder_t)order forPassFilter:(PassFilter2 *)passFilter;

//utility
- (int) getFreqForNextEnabledParametric;
//- (void) update;

- (double) getAFR:(double)freqX;

@end
