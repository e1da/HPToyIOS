//
//  DrcTimeConst.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 04/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DrcCoef.h"

@interface DrcTimeConst : NSObject <HiFiToyObject, NSCoding, NSCopying, XmlParserDelegate>

@property (nonatomic)   DrcChannel_t    channel;
@property (nonatomic)   float           energyMS;
@property (nonatomic)   float           attackMS;
@property (nonatomic)   float           decayMS;

+ (DrcTimeConst *)initWithChannel:(DrcChannel_t)channel
                           Energy:(float)energyMS
                           Attack:(float)attackMS
                            Decay:(float)decayMS;

@end
