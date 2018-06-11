//
//  BassTrebleChannel.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 01/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "BassTrebleChannel.h"

#define HW_BASSTREBLE_MAX_DB   18
#define HW_BASSTREBLE_MIN_DB   -18

@interface BassTrebleChannel(){
    int count;
}
@end

@implementation BassTrebleChannel

/*==========================================================================================
 NSCoding protocol implementation
 ==========================================================================================*/
- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:self.channel forKey:@"keyChannel"];
    [encoder encodeInt:self.bassFreq forKey:@"keyBassFreq"];
    [encoder encodeInt:self.bassDb forKey:@"keyBassDb"];
    [encoder encodeInt:self.trebleFreq forKey:@"keyTrebleFreq"];
    [encoder encodeInt:self.trebleDb forKey:@"keyTrebleDb"];
    
    [encoder encodeInt:self.maxBassDb forKey:@"keyMaxBassDb"];
    [encoder encodeInt:self.minBassDb forKey:@"keyMinBassDb"];
    [encoder encodeInt:self.maxTrebleDb forKey:@"keyMaxTrebleDb"];
    [encoder encodeInt:self.minTrebleDb forKey:@"keyMinTrebleDb"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.channel    = [decoder decodeIntForKey:@"keyChannel"];
        self.bassFreq   = [decoder decodeIntForKey:@"keyBassFreq"];
        self.bassDb     = [decoder decodeIntForKey:@"keyBassDb"];
        self.trebleFreq = [decoder decodeIntForKey:@"keyTrebleFreq"];
        self.trebleDb   = [decoder decodeIntForKey:@"keyTrebleDb"];
        
        self.maxBassDb      = [decoder decodeIntForKey:@"keyMaxBassDb"];
        self.minBassDb      = [decoder decodeIntForKey:@"keyMinBassDb"];
        self.maxTrebleDb    = [decoder decodeIntForKey:@"keyMaxTrebleDb"];
        self.minTrebleDb    = [decoder decodeIntForKey:@"keyMinTrebleDb"];
    }
    return self;
}

/*==========================================================================================
 NSCopying protocol implementation
 ==========================================================================================*/
-(BassTrebleChannel *)copyWithZone:(NSZone *)zone
{
    BassTrebleChannel * copyBassTrebleChannel = [[[self class] allocWithZone:zone] init];
    
    copyBassTrebleChannel.channel      = self.channel;
    copyBassTrebleChannel.bassFreq     = self.bassFreq;
    copyBassTrebleChannel.bassDb       = self.bassDb;
    copyBassTrebleChannel.trebleFreq   = self.trebleFreq;
    copyBassTrebleChannel.trebleDb     = self.trebleDb;
    
    copyBassTrebleChannel.maxBassDb    = self.maxBassDb;
    copyBassTrebleChannel.minBassDb    = self.minBassDb;
    copyBassTrebleChannel.maxTrebleDb  = self.maxTrebleDb;
    copyBassTrebleChannel.minTrebleDb  = self.minTrebleDb;
    
    return copyBassTrebleChannel;
}

/*==========================================================================================
 isEqual implementation
 ==========================================================================================*/
- (BOOL) isEqual: (id) object
{
    if ([object class] == [self class]){
        BassTrebleChannel * temp = object;
        if ((self.channel == temp.channel) &&
            (self.bassFreq == temp.bassFreq) &&
            (self.bassDb == temp.bassDb) &&
            (self.trebleFreq == temp.trebleFreq) &&
            (self.trebleDb == temp.trebleDb)){
            return YES;
        }
        
    }
    
    return NO;
}

/*---------------------- create methods -----------------------------*/
+ (BassTrebleChannel *)initWithChannel:(BassTrebleCh_t)channel
                              BassFreq:(BassFreq_t)bassFreq
                                BassDb:(float)bassDb
                            TrebleFreq:(TrebleFreq_t)trebleFreq
                              TrebleDb:(float)trebleDb
{
    return [BassTrebleChannel initWithChannel:channel
                                     BassFreq:bassFreq BassDb:bassDb
                                   TrebleFreq:trebleFreq TrebleDb:trebleDb
                                    maxBassDb:HW_BASSTREBLE_MAX_DB minBassDb:HW_BASSTREBLE_MIN_DB
                                  maxTrebleDb:HW_BASSTREBLE_MAX_DB minTrebleDb:HW_BASSTREBLE_MIN_DB];
}

+ (BassTrebleChannel *)initWithChannel:(BassTrebleCh_t)channel
                              BassFreq:(BassFreq_t)bassFreq
                                BassDb:(float)bassDb
                            TrebleFreq:(TrebleFreq_t)trebleFreq
                              TrebleDb:(float)trebleDb
                             maxBassDb:(int)maxBassDb
                             minBassDb:(int)minBassDb
                           maxTrebleDb:(int)maxTrebleDb
                           minTrebleDb:(int)minTrebleDb
{
    BassTrebleChannel *currentInstance = [[BassTrebleChannel alloc] init];
    
    currentInstance.channel = channel;
    
    if (bassFreq > BASS_FREQ_500)           bassFreq = BASS_FREQ_500;
    if (trebleFreq > TREBLE_FREQ_13000)     trebleFreq = TREBLE_FREQ_13000;
    
    currentInstance.bassFreq    = bassFreq;
    currentInstance.trebleFreq  = trebleFreq;
    
    if (maxBassDb > HW_BASSTREBLE_MAX_DB)      maxBassDb = HW_BASSTREBLE_MAX_DB;
    if (maxTrebleDb > HW_BASSTREBLE_MAX_DB)    maxTrebleDb = HW_BASSTREBLE_MAX_DB;
    if (minBassDb < HW_BASSTREBLE_MIN_DB)      minBassDb = HW_BASSTREBLE_MIN_DB;
    if (minTrebleDb < HW_BASSTREBLE_MIN_DB)    minTrebleDb = HW_BASSTREBLE_MIN_DB;
    
    currentInstance.maxBassDb       = maxBassDb;
    currentInstance.minBassDb       = minBassDb;
    currentInstance.maxTrebleDb     = maxTrebleDb;
    currentInstance.minTrebleDb     = minTrebleDb;
    
    currentInstance.bassDb          = bassDb;
    currentInstance.trebleDb        = trebleDb;
    
    return currentInstance;
}


//setters/getters
- (void) setBassDb:(int)db
{
    //check border
    if (db < self.minBassDb) db = self.minBassDb;
    if (db > self.maxBassDb) db = self.maxBassDb;
    
    _bassDb = db;
}

- (void) setTrebleDb:(int)db
{
    //check border
    if (db < self.minTrebleDb) db = self.minTrebleDb;
    if (db > self.maxTrebleDb) db = self.maxTrebleDb;
    
    _trebleDb = db;
}

- (float) getBassDbPercent
{
    return (float)(_bassDb - _minBassDb) / (_maxBassDb - _minBassDb);
}

- (void) setBassDbPercent:(float)percent
{
    if (percent > 1.0) percent = 1.0;
    if (percent < 0.0) percent = 0.0;
    
    [self setBassDb:percent * (_maxBassDb - _minBassDb) + _minBassDb];
}

- (float) getTrebleDbPercent
{
    return (float)(_trebleDb - _minTrebleDb) / (_maxTrebleDb - _minTrebleDb);
}

- (void) setTrebleDbPercent:(float)percent
{
    if (percent > 1.0) percent = 1.0;
    if (percent < 0.0) percent = 0.0;
    
    [self setTrebleDb:percent * (_maxTrebleDb - _minTrebleDb) + _minTrebleDb];
}

/*---------------------------- XML export/import ----------------------------------*/
-(XmlData *) toXmlData{
    XmlData * xmlData = [[XmlData alloc] init];
    [xmlData addElementWithName:@"BassFreq" withIntValue:self.bassFreq];
    [xmlData addElementWithName:@"BassDb" withIntValue:self.bassDb];
    [xmlData addElementWithName:@"TrebleFreq" withIntValue:self.trebleFreq];
    [xmlData addElementWithName:@"TrebleDb" withIntValue:self.trebleDb];
    
    [xmlData addElementWithName:@"maxBassDb" withIntValue:self.maxBassDb];
    [xmlData addElementWithName:@"minBassDb" withIntValue:self.minBassDb];
    [xmlData addElementWithName:@"maxTrebleDb" withIntValue:self.maxTrebleDb];
    [xmlData addElementWithName:@"minTrebleDb" withIntValue:self.minTrebleDb];
    
    
    XmlData * bassTrebleXmlData = [[XmlData alloc] init];
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                           [[NSNumber numberWithInt:self.channel] stringValue], @"Channel", nil];
    
    [bassTrebleXmlData addElementWithName:@"BassTrebleChannel" withXmlValue:xmlData withAttrib:dict];
    
    return bassTrebleXmlData;
    
}

-(void) importFromXml:(XmlParserWrapper *)xmlParser withAttrib:(NSDictionary<NSString *, NSString *> *)attributeDict {
    count = 0;
    [xmlParser pushDelegate:self];
}

/* -------------------------------------- XmlParserDelegate ---------------------------------------*/
- (void) didFindXmlElement:(NSString *)elementName
                attributes:(NSDictionary<NSString *, NSString *> *)attributeDict
                    parser:(XmlParserWrapper *)xmlParser {
    
}

- (void) didFoundXmlCharacters:(NSString *)string
                    forElement:(NSString *)elementName
                        parser:(XmlParserWrapper *)xmlParser {
    
    if ([elementName isEqualToString:@"BassFreq"]){
        self.bassFreq = [string intValue];
        count++;
    }
    if ([elementName isEqualToString:@"BassDb"]){
        self.bassDb = [string intValue];
        count++;
    }
    if ([elementName isEqualToString:@"TrebleFreq"]){
        self.trebleFreq = [string intValue];
        count++;
    }
    if ([elementName isEqualToString:@"TrebleDb"]){
        self.trebleDb = [string intValue];
        count++;
    }
    if ([elementName isEqualToString:@"maxBassDb"]){
        self.maxBassDb = [string intValue];
        count++;
    }
    if ([elementName isEqualToString:@"minBassDb"]){
        self.minBassDb = [string intValue];
        count++;
    }
    if ([elementName isEqualToString:@"maxTrebleDb"]){
        self.maxTrebleDb = [string intValue];
        count++;
    }
    if ([elementName isEqualToString:@"minTrebleDb"]){
        self.minTrebleDb = [string intValue];
        count++;
    }
    
}

- (void) didEndXmlElement:(NSString *)elementName
                   parser:(XmlParserWrapper *)xmlParser {
    
    if ([elementName isEqualToString:@"BassTrebleChannel"]){
        if (count != 8){
            xmlParser.error = [NSString stringWithFormat:
                               @"BassTrebleChannel=%@. Import from xml is not success. ",
                               [[NSNumber numberWithInt:self.channel] stringValue] ];
        }
        //NSLog(@"%@", [self getInfo]);
        [xmlParser popDelegate];
    }
}


@end
