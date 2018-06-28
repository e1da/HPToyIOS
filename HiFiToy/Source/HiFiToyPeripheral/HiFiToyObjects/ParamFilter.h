//
//  ParamFilter.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 27/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Biquad.h"

@interface ParamFilter : Biquad

+ (ParamFilter *)initWithAddress:(int)address
                            Freq:(int)freq
                            Qfac:(double)qFac
                        dbVolume:(double) dbVolume
                         Enabled:(BOOL)enabled;

+ (ParamFilter *)initWithAddress0:(int)address0
                         Address1:(int)address1
                             Freq:(int)freq
                             Qfac:(double)qFac
                         dbVolume:(double) dbVolume
                          Enabled:(BOOL)enabled;

- (void) setEnabled:(BOOL)enabled;
- (BOOL) isEnabled;
- (BOOL) isActive;
@end
