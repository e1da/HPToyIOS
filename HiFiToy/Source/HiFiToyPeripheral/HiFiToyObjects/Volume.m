//
//  Volume.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 30/05/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "Volume.h"
#import "HiFiToyControl.h"
#import "FloatUtility.h"

@interface Volume(){
    int count;
}
@end

@implementation Volume

/*==========================================================================================
 Init
 ==========================================================================================*/
- (id) init {
    self = [super init];
    if (self) {
        _address = 0;
        _db = 0;
        _maxDb = HW_MAX_DB;
        _minDb = HW_MIN_DB;
    }
    return self;
}

/*---------------------- create methods -----------------------------*/
+ (Volume *)initWithAddress:(uint8_t)address
                    dbValue:(float)db {
    Volume * v = [[Volume alloc] init];
    v.address = address;
    v.db = db;
    
    return v;
}

+ (Volume *)initWithAddress:(uint8_t)address
                    dbValue:(float)db
                      maxDb:(float)maxDb
                      minDb:(float)minDb {
    Volume * v = [[Volume alloc] init];
    
    v.address = address;
    v.maxDb = maxDb;
    v.minDb = minDb;
    v.db = db;
    
    return v;
}


/*==========================================================================================
 NSCoding protocol implementation
 ==========================================================================================*/
- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:self.address forKey:@"keyAddress"];
    [encoder encodeDouble:self.db forKey:@"keyDb"];
    [encoder encodeDouble:self.maxDb forKey:@"keyMaxDb"];
    [encoder encodeDouble:self.minDb forKey:@"keyMinDb"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.address    = [decoder decodeIntForKey:@"keyAddress"];
        self.maxDb      = [decoder decodeDoubleForKey:@"keyMaxDb"];
        self.minDb      = [decoder decodeDoubleForKey:@"keyMinDb"];
        self.db         = [decoder decodeDoubleForKey:@"keyDb"];
    }
    return self;
}

/*==========================================================================================
 NSCopying protocol implementation
 ==========================================================================================*/
-(Volume *)copyWithZone:(NSZone *)zone {
    Volume * copyVolume = [[[self class] allocWithZone:zone] init];
    
    copyVolume.address  = self.address;
    copyVolume.maxDb    = self.maxDb;
    copyVolume.minDb    = self.minDb;
    copyVolume.db       = self.db;
    
    return copyVolume;
}

/*==========================================================================================
 isEqual implementation
 ==========================================================================================*/
- (BOOL) isEqual: (id) object {
    if ([object class] == [self class]){
        Volume * temp = object;
        if ((self.address == temp.address) &&
            (isFloatDiffLessThan(self.db, temp.db, 0.02f)) ){
            return YES;
        }
        
    }
    
    return NO;
}

- (double) getDbPercent {
    return (_db - _minDb) / (_maxDb - _minDb);
}

- (void) setDbPercent:(double)percent {
    if (percent > 1.0) percent = 1.0;
    if (percent < 0.0) percent = 0.0;
    
    [self setDb:percent * (_maxDb - _minDb) + _minDb];
}

- (void) setDb:(float)db {
    //check border
    if (db < self.minDb) db = self.minDb;
    if (db > self.maxDb) db = self.maxDb;
    
    _db = db;
}

- (void) setMaxDb:(float)maxDb {
    if (maxDb > HW_MAX_DB) maxDb = HW_MAX_DB;
    if (maxDb < HW_MIN_DB) maxDb = HW_MIN_DB;
    _maxDb = maxDb;
}

- (void) setMinDb:(float)minDb {
    if (minDb > HW_MAX_DB) minDb = HW_MAX_DB;
    if (minDb < HW_MIN_DB) minDb = HW_MIN_DB;
    _minDb = minDb;
}

- (double)dbToAmpl:(double)db {
    return pow(10, (db / 20));
}

- (double)amplToDb:(double)ampl {
    return 20 * log10(ampl);
}

//info string
-(NSString *)getInfo {
    if (self.db > MUTE_VOLUME) {
        return [NSString stringWithFormat:@"%0.1fdb", self.db];
    }
    return @"Mute";
}

//send to dsp
- (void) sendWithResponse:(BOOL)response {
    NSData *data = [[self getDataBufs][0] binary];
    Packet_t packet;
    memcpy(&packet, data.bytes, data.length);
    
    //send data
    [[HiFiToyControl sharedInstance] sendPacketToDsp:&packet withResponse:response];
}

//get binary for save to dsp
- (NSArray<HiFiToyDataBuf *> *) getDataBufs {
    uint16_t v;
    if (self.db > MUTE_VOLUME) {
        
        v = (18.0 - self.db) / 0.25;
        if (v < 1) v = 1;
        if (v > 0x245) v = 0x245;
        
    } else {
        v = 0x245;
    }
    
    uint8_t data[4] = {0, 0, (v >> 8) & 0xFF, v & 0xFF};
    
    HiFiToyDataBuf * dataBuf = [HiFiToyDataBuf dataBufWithAddr:self.address withLength:4 withData:data];
    return [NSArray arrayWithObject:dataBuf];
}

- (BOOL) importData:(NSData *)data {
    HiFiToyPeripheral_t * HiFiToy = (HiFiToyPeripheral_t *) data.bytes;
    DataBufHeader_t * dataBufHeader = &HiFiToy->firstDataBuf;
    
    for (int i = 0; i < HiFiToy->dataBufLength; i++) {
        if ((dataBufHeader->addr == self.address) && (dataBufHeader->length == 4)){
            
            uint8_t * vBuf = (uint8_t *)dataBufHeader + sizeof(DataBufHeader_t);
            uint16_t v = (vBuf[2] << 8) | vBuf[3];
            if (v < 1) v = 1;
            if (v > 0x245) v = 0x245;
            
            if (v != 0x245) {
                self.db = 18.0 - v * 0.25;
            } else {
                self.db = MUTE_VOLUME;
            }
            return YES;
        }
        dataBufHeader = (DataBufHeader_t *)((uint8_t *)dataBufHeader + sizeof(DataBufHeader_t) + dataBufHeader->length);
    }
    
    return NO;
}

/*---------------------------- XML export/import ----------------------------------*/
-(XmlData *) toXmlData {
    XmlData * xmlData = [[XmlData alloc] init];
    [xmlData addElementWithName:@"MaxDb" withDoubleValue:self.maxDb];
    [xmlData addElementWithName:@"MinDb" withDoubleValue:self.minDb];
    [xmlData addElementWithName:@"Db" withDoubleValue:self.db];
    
    XmlData * gainXmlData = [[XmlData alloc] init];
    
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                           [[NSNumber numberWithInt:self.address] stringValue], @"Address", nil];
    
    [gainXmlData addElementWithName:@"Volume" withXmlValue:xmlData withAttrib:dict];
    
    return gainXmlData;
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
    
    if ([elementName isEqualToString:@"MaxDb"]){
        self.maxDb = [string doubleValue];
        count++;
    }
    if ([elementName isEqualToString:@"MinDb"]){
        self.minDb = [string doubleValue];
        count++;
    }
    if ([elementName isEqualToString:@"Db"]){
        self.db = [string doubleValue];
        count++;
    }
    
}

- (void) didEndXmlElement:(NSString *)elementName
                   parser:(XmlParserWrapper *)xmlParser {
    
    if ([elementName isEqualToString:@"Volume"]){
        if (count != 3){
            xmlParser.error = [NSString stringWithFormat:
                               @"Volume=%@. Import from xml is not success. ",
                               [[NSNumber numberWithInt:self.address] stringValue] ];
        }
        NSLog(@"%@", [self getInfo]);
        [xmlParser popDelegate];
    }
}



@end
