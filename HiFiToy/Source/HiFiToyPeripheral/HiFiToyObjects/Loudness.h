//
//  Loudness.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 30/05/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HiFiToyObject.h"
#import "Biquad.h"

@interface Loudness : NSObject <HiFiToyObject, NSCoding, NSCopying, XmlParserDelegate>

@property (nonatomic)   Biquad * biquad;

@property (nonatomic)   float   LG;
@property (nonatomic)   float   LO;
@property (nonatomic)   float   gain;
@property (nonatomic)   float   offset;

+ (Loudness *)initWithOrder:(Biquad *)biquad LG:(float)LG LO:(float)LO
                       Gain:(float)gain Offset:(float)offset;

@end
