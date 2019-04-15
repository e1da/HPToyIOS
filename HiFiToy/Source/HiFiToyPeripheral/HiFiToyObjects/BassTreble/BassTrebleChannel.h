//
//  BassTrebleChannel.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 01/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XmlData.h"
#import "XmlParserWrapper.h"

#define HW_BASSTREBLE_MAX_DB   18
#define HW_BASSTREBLE_MIN_DB   -18

//freq for FS = 96kHz
typedef enum : uint8_t {
    BASS_FREQ_NONE, BASS_FREQ_125, BASS_FREQ_250, BASS_FREQ_375, BASS_FREQ_438, BASS_FREQ_500
} BassFreq_t;

//freq for FS = 96kHz
typedef enum : uint8_t {
    TREBLE_FREQ_NONE, TREBLE_FREQ_2750, TREBLE_FREQ_5500, TREBLE_FREQ_9000, TREBLE_FREQ_11000, TREBLE_FREQ_13000
} TrebleFreq_t;

typedef enum : uint8_t {
    BASS_TREBLE_CH_127, BASS_TREBLE_CH_34, BASS_TREBLE_CH_56, BASS_TREBLE_CH_8
} BassTrebleCh_t;

@interface BassTrebleChannel : NSObject <NSCoding, NSCopying, XmlParserDelegate>

@property (nonatomic)   BassTrebleCh_t  channel;

@property (nonatomic)   BassFreq_t      bassFreq;
@property (nonatomic)   int8_t          bassDb;
@property (nonatomic)   TrebleFreq_t    trebleFreq;
@property (nonatomic)   int8_t          trebleDb;

@property (nonatomic)   int8_t          maxBassDb;
@property (nonatomic)   int8_t          minBassDb;
@property (nonatomic)   int8_t          maxTrebleDb;
@property (nonatomic)   int8_t          minTrebleDb;

+ (BassTrebleChannel *)initWithChannel:(BassTrebleCh_t)channel
                              BassFreq:(BassFreq_t)bassFreq
                                BassDb:(int8_t)bassDb
                            TrebleFreq:(TrebleFreq_t)trebleFreq
                              TrebleDb:(int8_t)trebleDb
                             maxBassDb:(int8_t)maxBassDb
                             minBassDb:(int8_t)minBassDb
                           maxTrebleDb:(int8_t)maxTrebleDb
                           minTrebleDb:(int8_t)minTrebleDb;
+ (BassTrebleChannel *)initWithChannel:(BassTrebleCh_t)channel
                              BassFreq:(BassFreq_t)bassFreq
                                BassDb:(int8_t)bassDb
                            TrebleFreq:(TrebleFreq_t)trebleFreq
                              TrebleDb:(int8_t)trebleDb;
+ (BassTrebleChannel *)initWithChannel:(BassTrebleCh_t)channel;

- (float) getBassDbPercent;
- (void) setBassDbPercent:(float)percent;
- (float) getTrebleDbPercent;
- (void) setTrebleDbPercent:(float)percent;

//xml
-(XmlData *) toXmlData;
-(void) importFromXml:(XmlParserWrapper *)xmlParser withAttrib:(NSDictionary<NSString *, NSString *> *)attributeDict;

@end

