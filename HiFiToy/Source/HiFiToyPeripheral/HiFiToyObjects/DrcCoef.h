//
//  DrcCoef.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 01/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HiFiToyObject.h"
#import "Number88.h"

#define POINT0_INPUT_DB     -120//-96
#define POINT3_INPUT_DB     0//24

typedef enum : uint8_t{
    DRC_CH_1_7, DRC_CH_8
} DrcChannel_t;

typedef struct {
    float threshold1_db;
    float threshold2_db;
    float offset1_db;
    float offset2_db;
    float k0;    //k>0 - expansion
    float k1;    //-1<k<0 - compression
    float k2;
} DrcCoef_t;

typedef struct {
    float inputDb;
    float outputDb;
} DrcPoint_t;

typedef struct {
    Number88_t inputDb;
    Number88_t outputDb;
} DrcPoint88_t;

#pragma pack(1)
typedef struct {
    DrcChannel_t channel;
    DrcPoint88_t point[4];
} DrcPointPacket_t; //size = 17
#pragma options align=reset

DrcPoint_t initDrcPoint(float inputDb, float outputDb);
DrcPoint88_t initDrcPoint88(float inputDb, float outputDb);

@interface DrcCoef : NSObject <HiFiToyObject, NSCoding, NSCopying, XmlParserDelegate>

@property (nonatomic)   DrcChannel_t  channel;

@property (nonatomic)   DrcPoint_t    point0;
@property (nonatomic)   DrcPoint_t    point1;
@property (nonatomic)   DrcPoint_t    point2;
@property (nonatomic)   DrcPoint_t    point3;

+ (DrcCoef *)initWithChannel:(DrcChannel_t)channel
                      Point0:(DrcPoint_t)p0
                      Point1:(DrcPoint_t)p1
                      Point2:(DrcPoint_t)p2
                      Point3:(DrcPoint_t)p3;
+ (DrcCoef *)initWithChannel:(DrcChannel_t)channel
                      Point0:(DrcPoint_t)p0
                      Point1:(DrcPoint_t)p1
                      Point2:(DrcPoint_t)p2;

- (void) setPoint0WithCheck:(DrcPoint_t)point0;
- (void) setPoint1WithCheck:(DrcPoint_t)point1;
- (void) setPoint2WithCheck:(DrcPoint_t)point2;
- (void) setPoint3WithCheck:(DrcPoint_t)point3;

@end
