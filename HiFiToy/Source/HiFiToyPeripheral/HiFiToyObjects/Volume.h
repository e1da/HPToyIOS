//
//  Volume.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 30/05/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HiFiToyObject.h"

@interface Volume : NSObject <HiFiToyObject, NSCoding, NSCopying, XmlParserDelegate>

@property (nonatomic)   int         address;
@property (nonatomic)   double      db;

@property (nonatomic)   double      maxDb;
@property (nonatomic)   double      minDb;

+ (Volume *)initWithAddress:(int)address
                    dbValue:(double)db;

+ (Volume *)initWithAddress:(int)address
                    dbValue:(double)db
                      maxDb:(double)maxDb
                      minDb:(double)minDb;

- (double) getDbPercent;
- (void) setDbPercent:(double)percent;//[0..1]
@end
