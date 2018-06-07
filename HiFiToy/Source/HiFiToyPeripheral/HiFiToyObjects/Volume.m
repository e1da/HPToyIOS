//
//  Volume.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 30/05/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "Volume.h"
#import "HiFiToyControl.h"

#define HW_MAX_DB   18.0
#define HW_MIN_DB   -127.0

@interface Volume(){
    int count;
}
@end

@implementation Volume

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
-(Volume *)copyWithZone:(NSZone *)zone
{
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
- (BOOL) isEqual: (id) object
{
    if ([object class] == [self class]){
        Volume * temp = object;
        if ((self.address == temp.address) &&
            (fabs(self.db - temp.db) < 0.02f)){
            return YES;
        }
        
    }
    
    return NO;
}

/*---------------------- create methods -----------------------------*/
+ (Volume *)initWithAddress:(int)address
                    dbValue:(double)db
{
    return [Volume initWithAddress:address dbValue:db maxDb:0.0 minDb:-40.0];
}

+ (Volume *)initWithAddress:(int)address
                    dbValue:(double)db
                      maxDb:(double)maxDb
                      minDb:(double)minDb
{
    Volume *currentInstance = [[Volume alloc] init];
    
    currentInstance.address = address;
    
    if (maxDb > HW_MAX_DB) maxDb = HW_MAX_DB;
    if (minDb > HW_MIN_DB) minDb = HW_MIN_DB;
    currentInstance.maxDb = maxDb;
    currentInstance.minDb = minDb;
    
    currentInstance.db = db;
    
    return currentInstance;
    
}

- (double) getDbPercent {
    return (_db - _minDb) / (_maxDb - _minDb);
}
- (void) setDbPercent:(double)percent {
    if (percent > 1.0) percent = 1.0;
    if (percent < 0.0) percent = 0.0;
    
    [self setDb:percent * (_maxDb - _minDb) + _minDb];
}

- (void) setDb:(double)db
{
    //check border
    if (db < self.minDb) db = self.minDb;
    if (db > self.maxDb) db = self.maxDb;
    
    _db = db;
}

- (double)dbToAmpl:(double)db
{
    return pow(10, (db / 20));
}

- (double)amplToDb:(double)ampl
{
    return 20 * log10(ampl);
}

//info string
-(NSString *)getInfo
{
    return [NSString stringWithFormat:@"%0.1fdb", self.db];
}

//send to dsp
- (void) sendWithResponse:(BOOL)response
{
    NSData *data = [self getBinary];

    //send data
    [[HiFiToyControl sharedInstance] sendDataToDsp:data withResponse:response];
}

//get binary for save to dsp
- (NSData *) getBinary
{
    DataBufHeader_t dataBufHeader;
    dataBufHeader.addr = self.address;
    dataBufHeader.length = 4;
    
    uint16_t v = (18.0 - self.db) / 0.25;
    if (v < 1) v = 1;
    if (v > 0x245) v = 0x245;
    
    uint8_t vBuf[4] = {0, 0, (v >> 8) & 0xFF, v & 0xFF};
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendBytes:&dataBufHeader length:sizeof(DataBufHeader_t)];
    [data appendBytes:vBuf length:4];
    return data;
}

- (BOOL) importData:(NSData *)data
{
    HiFiToyPeripheral_t * HiFiToy = (HiFiToyPeripheral_t *) data.bytes;
    DataBufHeader_t * dataBufHeader = &HiFiToy->firstDataBuf;
    
    for (int i = 0; i < HiFiToy->dataBufLength; i++) {
        if ((dataBufHeader->addr == self.address) && (dataBufHeader->length == 4)){
            
            uint8_t * vBuf = (uint8_t *)dataBufHeader + sizeof(DataBufHeader_t);
            uint16_t v = (vBuf[2] << 8) | vBuf[3];
            if (v < 1) v = 1;
            if (v > 0x245) v = 0x245;
            
            self.db = 18.0 - v * 0.25;
            return YES;
        }
        dataBufHeader += sizeof(DataBufHeader_t) + dataBufHeader->length;
    }
    
    return NO;
}

/*---------------------------- XML export/import ----------------------------------*/
-(XmlData *) toXmlData{
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
