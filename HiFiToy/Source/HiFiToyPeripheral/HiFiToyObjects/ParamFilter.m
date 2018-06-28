//
//  ParamFilter.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 27/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "ParamFilter.h"

@implementation ParamFilter

+ (ParamFilter *)initWithAddress:(int)address
                            Freq:(int)freq
                            Qfac:(double)qFac
                        dbVolume:(double) dbVolume
                         Enabled:(BOOL)enabled
{
    BiquadType_t type = (enabled) ? BIQUAD_PARAMETRIC : BIQUAD_DISABLED;
    return (ParamFilter *)[super initWithAddress:address Order:BIQUAD_ORDER_2 Type:type Freq:freq Qfac:qFac dbVolume:dbVolume];
}

+ (ParamFilter *)initWithAddress0:(int)address0
                         Address1:(int)address1
                             Freq:(int)freq
                             Qfac:(double)qFac
                         dbVolume:(double) dbVolume
                          Enabled:(BOOL)enabled
{
    BiquadType_t type = (enabled) ? BIQUAD_PARAMETRIC : BIQUAD_DISABLED;
    return (ParamFilter *)[super initWithAddress0:address0 Address1:address1 Order:BIQUAD_ORDER_2 Type:type Freq:freq Qfac:qFac dbVolume:dbVolume];
}

//Enabled methods
- (void) setEnabled:(BOOL)enabled
{
    BiquadType_t type = (enabled) ? BIQUAD_PARAMETRIC : BIQUAD_DISABLED;
    
    if (self.type != type) {
        self.type = type;
        [self sendWithResponse:YES];
    }
}

- (BOOL) isEnabled
{
    return (self.type == BIQUAD_PARAMETRIC);
}

- (BOOL) isActive
{
    return ((self.type == BIQUAD_PARAMETRIC) && (fabs(self.dbVolume) > 0.01));
}

@end
