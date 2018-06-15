//
//  DrcCoef.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 01/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "DrcCoef.h"
#import "TAS5558.h"
#import "Number923.h"
#import "Number523.h"
#import "HiFiToyControl.h"

DrcPoint_t initDrcPoint(float inputDb, float outputDb) {
    DrcPoint_t p;
    p.inputDb = inputDb;
    p.outputDb = outputDb;
    
    return p;
}

DrcPoint88_t initDrcPoint88(float inputDb, float outputDb) {
    DrcPoint88_t p;
    p.inputDb = to88(inputDb);
    p.outputDb = to88(outputDb);
    
    return p;
}

float getK(DrcPoint_t p0, DrcPoint_t p1) {
    if (p1.inputDb == p0.inputDb) {
        return 1;
    }
    return (float)(p1.outputDb - p0.outputDb) / (p1.inputDb - p0.inputDb);
}

DrcCoef_t getDrcCoef(DrcPoint_t p0, DrcPoint_t p1, DrcPoint_t p2, DrcPoint_t p3) {
    DrcCoef_t drcCoef;
    
    drcCoef.threshold1_db = p0.inputDb;
    drcCoef.threshold2_db = p1.inputDb;
    drcCoef.offset1_db = p0.inputDb - p0.outputDb;
    drcCoef.offset2_db = p1.inputDb - p1.outputDb;
    
    drcCoef.k0 = getK(p0, p1) - 1;
    drcCoef.k1 = getK(p1, p2) - 1;
    drcCoef.k2 = getK(p2, p3) - 1;
    
    return drcCoef;
}

DrcPoint_t * getDrcPoints(DrcCoef_t * drcCoef) {
    DrcPoint_t * drcPoint = calloc(4, sizeof(DrcPoint_t));
    
    drcPoint[1].inputDb = drcCoef->threshold1_db;
    drcPoint[1].outputDb = drcCoef->threshold1_db - drcCoef->offset1_db;
    drcPoint[2].inputDb = drcCoef->threshold2_db;
    drcPoint[2].outputDb = drcCoef->threshold2_db - drcCoef->offset2_db;
    
    drcPoint[3].inputDb = 0.0;
    drcPoint[3].outputDb = (drcCoef->k2 + 1) * (drcPoint[3].inputDb - drcPoint[2].inputDb) + drcPoint[2].outputDb;
    drcPoint[0].inputDb = -200.0;
    drcPoint[0].outputDb = (drcCoef->k0 + 1) * (drcPoint[0].inputDb - drcPoint[1].inputDb) + drcPoint[1].outputDb;
    
    return drcPoint;
}

@interface DrcCoef(){
    int count;
}
@end

@implementation DrcCoef

/*==========================================================================================
 NSCoding protocol implementation
 ==========================================================================================*/
- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:self.channel forKey:@"keyChannel"];
    [encoder encodeFloat:self.point0.inputDb forKey:@"keyInputDb0"];
    [encoder encodeFloat:self.point0.outputDb forKey:@"keyOutputDb0"];
    [encoder encodeFloat:self.point1.inputDb forKey:@"keyInputDb1"];
    [encoder encodeFloat:self.point1.outputDb forKey:@"keyOutputDb1"];
    [encoder encodeFloat:self.point2.inputDb forKey:@"keyInputDb2"];
    [encoder encodeFloat:self.point2.outputDb forKey:@"keyOutputDb2"];
    [encoder encodeFloat:self.point3.inputDb forKey:@"keyInputDb3"];
    [encoder encodeFloat:self.point3.outputDb forKey:@"keyOutputDb3"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.channel    = [decoder decodeIntForKey:@"keyChannel"];
        _point0.inputDb = [decoder decodeFloatForKey:@"keyInputDb0"];
        _point0.outputDb = [decoder decodeFloatForKey:@"keyOutputDb0"];
        _point1.inputDb = [decoder decodeFloatForKey:@"keyInputDb1"];
        _point1.outputDb = [decoder decodeFloatForKey:@"keyOutputDb1"];
        _point2.inputDb = [decoder decodeFloatForKey:@"keyInputDb2"];
        _point2.outputDb = [decoder decodeFloatForKey:@"keyOutputDb2"];
        _point3.inputDb = [decoder decodeFloatForKey:@"keyInputDb3"];
        _point3.outputDb = [decoder decodeFloatForKey:@"keyOutputDb3"];
    }
    return self;
}

/*==========================================================================================
 NSCopying protocol implementation
 ==========================================================================================*/
-(DrcCoef *)copyWithZone:(NSZone *)zone
{
    DrcCoef * copyDrcCoef = [[[self class] allocWithZone:zone] init];
    
    copyDrcCoef.channel      = self.channel;
    copyDrcCoef.point0     = self.point0;
    copyDrcCoef.point1     = self.point1;
    copyDrcCoef.point2     = self.point2;
    copyDrcCoef.point3     = self.point3;
    
    return copyDrcCoef;
}

/*==========================================================================================
 isEqual implementation
 ==========================================================================================*/
- (BOOL) isEqual: (id) object
{
    if ([object class] == [self class]){
        DrcCoef * temp = object;
        if ((self.channel == temp.channel) &&
            (fabs(self.point0.inputDb - temp.point0.inputDb) < 0.02f) &&
            (fabs(self.point0.outputDb - temp.point0.outputDb) < 0.02f) &&
            (fabs(self.point1.inputDb - temp.point1.inputDb) < 0.02f) &&
            (fabs(self.point1.outputDb - temp.point1.outputDb) < 0.02f) &&
            (fabs(self.point2.inputDb - temp.point2.inputDb) < 0.02f) &&
            (fabs(self.point2.outputDb - temp.point2.outputDb) < 0.02f) &&
            (fabs(self.point3.inputDb - temp.point3.inputDb) < 0.02f)){
            return YES;
        }
        
    }
    
    return NO;
}

/*---------------------- create methods -----------------------------*/
+ (DrcCoef *)initWithChannel:(DrcChannel_t)channel
                      Point0:(DrcPoint_t)p0
                      Point1:(DrcPoint_t)p1
                      Point2:(DrcPoint_t)p2
                      Point3:(DrcPoint_t)p3
{
    DrcCoef * currentInstance = [[DrcCoef alloc] init];
    
    currentInstance.channel = channel;
    currentInstance.point0 = p0;
    currentInstance.point1 = p1;
    currentInstance.point2 = p2;
    currentInstance.point3 = p3;
    
    return currentInstance;
}

+ (DrcCoef *)initWithChannel:(DrcChannel_t)channel
                      Point0:(DrcPoint_t)p0
                      Point1:(DrcPoint_t)p1
                      Point2:(DrcPoint_t)p2
{
    return [self initWithChannel:channel Point0:p0 Point1:p1 Point2:p1 Point3:p2];
}

//setter/getter
- (void) setPoint0:(DrcPoint_t)point0 {
    if (point0.outputDb > _point1.outputDb) {
        point0.outputDb = _point1.outputDb;
    }
    
    _point0.outputDb = point0.outputDb;
}

- (void) setPoint1:(DrcPoint_t)point1 {
    if (point1.inputDb > _point2.inputDb) {
        point1.inputDb = _point2.inputDb;
    }
    if (point1.outputDb > _point2.outputDb) {
        point1.outputDb = _point2.outputDb;
    }
    if (point1.outputDb < _point0.outputDb) {
        point1.outputDb = _point0.outputDb;
    }
    _point1 = point1;
}

- (void) setPoint2:(DrcPoint_t)point2 {
    if (point2.inputDb < _point1.inputDb) {
        point2.inputDb = _point1.inputDb;
    }
    if (point2.outputDb > _point3.outputDb) {
        point2.outputDb = _point3.outputDb;
    }
    if (point2.outputDb < _point1.outputDb) {
        point2.outputDb = _point1.outputDb;
    }
    _point2 = point2;
}

- (void) setPoint3:(DrcPoint_t)point3 {
    if (point3.outputDb < _point2.outputDb) {
        point3.outputDb = _point2.outputDb;
    }
    _point3.outputDb = point3.outputDb;
}


- (uint8_t) address {
    if (self.channel == DRC_CH_8) {
        return DRC2_THRESHOLD_REG;
    }
    return DRC1_THRESHOLD_REG;
}

//info string
-(NSString *)getInfo
{
    return [NSString stringWithFormat:@"0:%0.1f %0.1f 1:%0.1f %0.1f 2:%0.1f %0.1f 3:%0.1f %0.1f",
            _point0.inputDb, _point0.outputDb,
            _point1.inputDb, _point1.outputDb,
            _point2.inputDb, _point2.outputDb,
            _point3.inputDb, _point3.outputDb];
}

//send to dsp
- (void) sendWithResponse:(BOOL)response
{
    DrcPointPacket_t packet;
    packet.channel = self.channel;
    
    packet.point[0] = initDrcPoint88(_point0.inputDb, _point0.outputDb);
    packet.point[1] = initDrcPoint88(_point1.inputDb, _point1.outputDb);
    packet.point[2] = initDrcPoint88(_point2.inputDb, _point2.outputDb);
    packet.point[3] = initDrcPoint88(_point3.inputDb, _point3.outputDb);
    
    NSData *data = [[NSData alloc] initWithBytes:&packet length:sizeof(DrcPointPacket_t)];
    
    //send data
    [[HiFiToyControl sharedInstance] sendDataToDsp:data withResponse:response];
}

//get binary for save to dsp
- (NSData *) getBinary
{
 
    DataBufHeader_t dataBufHeader;
    dataBufHeader.addr = [self address];
    dataBufHeader.length = 7 * sizeof(Number923_t); // thresholds, ks, offsets
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendBytes:&dataBufHeader length:sizeof(DataBufHeader_t)];
    
    DrcCoef_t drcCoef = getDrcCoef(self.point0, self.point1, self.point2, self.point3);
    
    Number923_t number[7] = {to923Reverse(drcCoef.threshold1_db / -6.0206),
                                to923Reverse(drcCoef.threshold2_db / -6.0206),
                                to523Reverse(drcCoef.k0),
                                to523Reverse(drcCoef.k1),
                                to523Reverse(drcCoef.k2),
                                to923Reverse((drcCoef.offset1_db + 24.0824) / 6.0206),
                                to923Reverse((drcCoef.offset2_db + 24.0824) / 6.0206)
    };
    [data appendBytes:number length:(7 * sizeof(Number923_t))];
    
    return data;
}

- (BOOL) importData:(NSData *)data
{
    HiFiToyPeripheral_t * HiFiToy = (HiFiToyPeripheral_t *) data.bytes;
    DataBufHeader_t * dataBufHeader = &HiFiToy->firstDataBuf;
    
    for (int i = 0; i < HiFiToy->dataBufLength; i++) {
        if ((dataBufHeader->addr == [self address]) && (dataBufHeader->length == 28)){
            
            int32_t * number = (int32_t *)((uint8_t *)dataBufHeader + sizeof(DataBufHeader_t));
            
            //get drc coef
            DrcCoef_t drcCoef;
            
            drcCoef.threshold1_db = _923toFloat(number[0]) * -6.0206;
            drcCoef.threshold2_db = _923toFloat(number[1]) * -6.0206;
            
            drcCoef.k0 = _523toFloat(number[2]);
            drcCoef.k1 = _523toFloat(number[3]);
            drcCoef.k2 = _523toFloat(number[4]);
            
            drcCoef.offset1_db = _923toFloat(number[5]) * 6.0206 - 24.0824;
            drcCoef.offset2_db = _923toFloat(number[6]) * 6.0206 - 24.0824;
            
            //get drc point
            DrcPoint_t * drcPoint = getDrcPoints(&drcCoef);
            self.point0 = drcPoint[0];
            self.point1 = drcPoint[1];
            self.point2 = drcPoint[2];
            self.point3 = drcPoint[3];
            free(drcPoint);
            
            NSLog(@"import drc coef");
            return YES;
        }
        dataBufHeader = (DataBufHeader_t *)((uint8_t *)dataBufHeader + sizeof(DataBufHeader_t) + dataBufHeader->length);
    }
    
    return NO;
}

/*---------------------------- XML export/import ----------------------------------*/
-(XmlData *) toXmlData{
    XmlData * xmlData = [[XmlData alloc] init];
    [xmlData addElementWithName:@"InputDb0" withDoubleValue:self.point0.inputDb];
    [xmlData addElementWithName:@"OutputDb0" withDoubleValue:self.point0.outputDb];
    [xmlData addElementWithName:@"InputDb1" withDoubleValue:self.point1.inputDb];
    [xmlData addElementWithName:@"OutputDb1" withDoubleValue:self.point1.outputDb];
    [xmlData addElementWithName:@"InputDb2" withDoubleValue:self.point2.inputDb];
    [xmlData addElementWithName:@"OutputDb2" withDoubleValue:self.point2.outputDb];
    [xmlData addElementWithName:@"InputDb3" withDoubleValue:self.point3.inputDb];
    [xmlData addElementWithName:@"OutputDb3" withDoubleValue:self.point3.outputDb];
    
    
    XmlData * drcCoefXmlData = [[XmlData alloc] init];
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                           [[NSNumber numberWithInt:self.channel] stringValue], @"Channel", nil];
    
    [drcCoefXmlData addElementWithName:@"DrcCoef" withXmlValue:xmlData withAttrib:dict];
    
    return drcCoefXmlData;
    
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
    
    if ([elementName isEqualToString:@"InputDb0"]){
        _point0.inputDb = [string floatValue];
        count++;
    }
    if ([elementName isEqualToString:@"OutputDb0"]){
        _point0.outputDb = [string floatValue];
        count++;
    }
    if ([elementName isEqualToString:@"InputDb1"]){
        _point1.inputDb = [string floatValue];
        count++;
    }
    if ([elementName isEqualToString:@"OutputDb1"]){
        _point1.outputDb = [string floatValue];
        count++;
    }
    if ([elementName isEqualToString:@"InputDb2"]){
        _point2.inputDb = [string floatValue];
        count++;
    }
    if ([elementName isEqualToString:@"OutputDb2"]){
        _point2.outputDb = [string floatValue];
        count++;
    }
    if ([elementName isEqualToString:@"InputDb3"]){
        _point3.inputDb = [string floatValue];
        count++;
    }
    if ([elementName isEqualToString:@"OutputDb3"]){
        _point3.outputDb = [string floatValue];
        count++;
    }
    
}

- (void) didEndXmlElement:(NSString *)elementName
                   parser:(XmlParserWrapper *)xmlParser {
    
    if ([elementName isEqualToString:@"DrcCoef"]){
        if (count != 8){
            xmlParser.error = [NSString stringWithFormat:
                               @"DrcCoef=%@. Import from xml is not success. ",
                               [[NSNumber numberWithInt:self.channel] stringValue] ];
        }
        //NSLog(@"%@", [self getInfo]);
        [xmlParser popDelegate];
    }
}


@end
