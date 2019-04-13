//
//  Volume.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 30/05/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HiFiToyObject.h"

#define HW_MAX_DB   18.0
#define HW_MIN_DB   -127.0

#define MUTE_VOLUME -81

@interface Volume : NSObject <HiFiToyObject, NSCoding, NSCopying, XmlParserDelegate>

@property (nonatomic)   uint8_t     address;
@property (nonatomic)   float       db;

@property (nonatomic)   float       maxDb;
@property (nonatomic)   float       minDb;

+ (Volume *)initWithAddress:(uint8_t)address
                    dbValue:(float)db;

+ (Volume *)initWithAddress:(uint8_t)address
                    dbValue:(float)db
                      maxDb:(float)maxDb
                      minDb:(float)minDb;

- (double) getDbPercent;
- (void) setDbPercent:(double)percent;//[0..1]
@end
