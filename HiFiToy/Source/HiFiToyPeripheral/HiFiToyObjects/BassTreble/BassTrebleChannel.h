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

//freq for FS = 96kHz
typedef enum : uint8_t {
    BASS_FREQ_125 = 1, BASS_FREQ_250, BASS_FREQ_375, BASS_FREQ_438, BASS_FREQ_500
} BassFreq_t;

//freq for FS = 96kHz
typedef enum : uint8_t {
    TREBLE_FREQ_2750 = 1, TREBLE_FREQ_5500, TREBLE_FREQ_9000, TREBLE_FREQ_11000, TREBLE_FREQ_13000
} TrebleFreq_t;

typedef enum : uint8_t {
    BASS_TREBLE_CH_127, BASS_TREBLE_CH_34, BASS_TREBLE_CH_56, BASS_TREBLE_CH_8
} BassTrebleCh_t;

@interface BassTrebleChannel : NSObject <NSCoding, NSCopying, XmlParserDelegate>

@property (nonatomic)   BassTrebleCh_t  channel;

@property (nonatomic)   BassFreq_t      bassFreq;
@property (nonatomic)   int             bassDb;
@property (nonatomic)   TrebleFreq_t    trebleFreq;
@property (nonatomic)   int             trebleDb;

@property (nonatomic)   int             maxBassDb;
@property (nonatomic)   int             minBassDb;
@property (nonatomic)   int             maxTrebleDb;
@property (nonatomic)   int             minTrebleDb;

+ (BassTrebleChannel *)initWithChannel:(BassTrebleCh_t)channel
                              BassFreq:(BassFreq_t)bassFreq
                                BassDb:(float)bassDb
                            TrebleFreq:(TrebleFreq_t)trebleFreq
                            TrebleDb:(float)trebleDb;

+ (BassTrebleChannel *)initWithChannel:(BassTrebleCh_t)channel
                              BassFreq:(BassFreq_t)bassFreq
                                BassDb:(float)bassDb
                            TrebleFreq:(TrebleFreq_t)trebleFreq
                              TrebleDb:(float)trebleDb
                             maxBassDb:(int)maxBassDb
                             minBassDb:(int)minBassDb
                           maxTrebleDb:(int)maxTrebleDb
                           minTrebleDb:(int)minTrebleDb;

- (float) getBassDbPercent;
- (void) setBassDbPercent:(float)percent;
- (float) getTrebleDbPercent;
- (void) setTrebleDbPercent:(float)percent;

//xml
-(XmlData *) toXmlData;
-(void) importFromXml:(XmlParserWrapper *)xmlParser withAttrib:(NSDictionary<NSString *, NSString *> *)attributeDict;

@end

