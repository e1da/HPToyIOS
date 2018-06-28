//
//  PassFilter2.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 28/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "PassFilter2.h"
#import "HiFiToyControl.h"

@interface PassFilter2(){
    int count;
}
@end

@implementation PassFilter2

/*==========================================================================================
 Init
 ==========================================================================================*/
- (id) init
{
    self = [super init];
    if (self){
        [self setBorderMaxFreq:30000 minFreq:10];
    }
    
    return self;
}

/*==========================================================================================
 NSCoding protocol implementation
 ==========================================================================================*/
- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:self.address0 forKey:@"keyAddress0"];
    [encoder encodeInt:self.address1 forKey:@"keyAddress1"];
    
    [encoder encodeInt:self.biquadLength forKey:@"keyBiquadLength"];
    [encoder encodeInt:self.order forKey:@"keyOrder"];
    [encoder encodeInt:self.type forKey:@"keyType"];
    [encoder encodeInt:self.freq forKey:@"keyFreq"];
    
    [encoder encodeInt:self.maxFreq forKey:@"keyMaxFreq"];
    [encoder encodeInt:self.minFreq forKey:@"keyMinFreq"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.address0 = [decoder decodeIntForKey:@"keyAddress0"];
        self.address1 = [decoder decodeIntForKey:@"keyAddress1"];
        
        self.biquadLength = [decoder decodeIntForKey:@"keyBiquadLength"];
        self.order = [decoder decodeIntForKey:@"keyOrder"];
        self.type = [decoder decodeIntForKey:@"keyType"];
        
        self.maxFreq = [decoder decodeIntForKey:@"keyMaxFreq"];
        self.minFreq = [decoder decodeIntForKey:@"keyMinFreq"];
        self.freq = [decoder decodeIntForKey:@"keyFreq"];
    }
    return self;
}

/*==========================================================================================
 NSCopying protocol implementation
 ==========================================================================================*/
-(PassFilter2 *)copyWithZone:(NSZone *)zone
{
    PassFilter2 * copyFilter = [[[self class] allocWithZone:zone] init];
    
    copyFilter.address0 = self.address0;
    copyFilter.address1 = self.address1;
    
    copyFilter.biquadLength = self.biquadLength;
    copyFilter.order = self.order;
    copyFilter.type = self.type;
    
    copyFilter.maxFreq = self.maxFreq;
    copyFilter.minFreq = self.minFreq;
    copyFilter.freq = self.freq;
    
    return copyFilter;
}

/*==========================================================================================
 isEqual implementation
 ==========================================================================================*/
- (BOOL) isEqual: (id) object
{
    if ([object class] == [self class]){
        PassFilter2 * temp = object;
        
        if ((self.address0 != temp.address0) ||
            (self.address1 != temp.address1) ||
            (self.biquadLength != temp.biquadLength) ||
            (self.order != temp.order) ||
            (self.type != temp.type) ||
            (self.freq != temp.freq)){
            
            return NO;
        }
        return YES;
    }
    return NO;
}

/*---------------------- create method -----------------------------*/
+ (PassFilter2 *)initWithAddress:(int)address
                     BiquadLength:(BiquadLength_t)biquadLength
                            Order:(PassFilterOrder_t)order
                             Type:(PassFilterType_t)type
                             Freq:(int)freq
{
    return [PassFilter2 initWithAddress0:address Address1:0 BiquadLength:biquadLength Order:order Type:type Freq:freq];
}

+ (PassFilter2 *)initWithAddress0:(int)address0
                         Address1:(int)address1
                     BiquadLength:(BiquadLength_t)biquadLength
                            Order:(PassFilterOrder_t)order
                             Type:(PassFilterType_t)type
                             Freq:(int)freq
{
    PassFilter2 *currentInstance = [[PassFilter2 alloc] init];
    
    currentInstance.address0 = address0;
    currentInstance.address1 = address1;
    
    currentInstance.biquadLength = biquadLength;
    currentInstance.order = order;
    currentInstance.type = type;
    currentInstance.freq = freq;
    
    return currentInstance;
}

- (uint8_t) address {
    return _address0;
}

//getter/setter function
- (void) setOrder:(PassFilterOrder_t)order
{
    if (order > self.biquadLength) order = (PassFilterOrder_t)self.biquadLength;
    
    _order = order;
}

- (void) setType:(PassFilterType_t)type
{
    if ((type != BIQUAD_LOWPASS) || (type != BIQUAD_HIGHPASS)) type = BIQUAD_DISABLED;
    _type = type;
}

- (void) setBorderMaxFreq:(int)maxFreq minFreq:(int)minFreq
{
    self.maxFreq = maxFreq;
    self.minFreq = minFreq;
}

- (void) setFreq:(int)freq
{
    
    _freq = freq;
    
    if (_freq > self.maxFreq) _freq = self.maxFreq;
    if (_freq < self.minFreq) _freq = self.minFreq;
    
}

- (void) setFreqPercent:(double)percent
{
    if (percent > 1.0) percent = 1.0;
    if (percent < 0.0) percent = 0.0;
    
    double freq = pow(10, percent * (log10(_maxFreq) - log10(_minFreq)) + log10(_minFreq));
    self.freq = freq;
}

- (double) getFreqPercent
{
    return (log10(_freq) - log10(_minFreq)) / (log10(_maxFreq) - log10(_minFreq));
}

- (NSArray * ) getBiquads
{
    Biquad * biquad[4];
    
    //init biquads
    for (int i = 0; i < self.biquadLength; i++) {
        
        if (self.address1) {
            biquad[i] = [Biquad initWithAddress0:(self.address0 + i) Address1:(self.address1 + i)
                                           Order:BIQUAD_ORDER_2 Type:self.type
                                           Freq:self.freq Qfac:0.71f dbVolume:0.0f];
        } else {
            biquad[i] = [Biquad initWithAddress:(self.address0 + i) Order:BIQUAD_ORDER_2 Type:self.type
                                           Freq:self.freq Qfac:0.71f dbVolume:0.0f];
        }
    }
    
    switch (self.order){
        case FILTER_ORDER_0:
            if (biquad[0]) biquad[0].type = BIQUAD_DISABLED;
            if (biquad[1]) biquad[1].type = BIQUAD_DISABLED;
            if (biquad[2]) biquad[2].type = BIQUAD_DISABLED;
            if (biquad[3]) biquad[3].type = BIQUAD_DISABLED;
            break;
            
        case FILTER_ORDER_2:
            if (biquad[0]) biquad[0].qFac = 0.71f;
            if (biquad[1]) biquad[1].type = BIQUAD_DISABLED;
            if (biquad[2]) biquad[2].type = BIQUAD_DISABLED;
            if (biquad[3]) biquad[3].type = BIQUAD_DISABLED;
            break;
            
        case FILTER_ORDER_4:
            if (biquad[0]) biquad[0].qFac = 0.54f;
            if (biquad[1]) biquad[1].qFac = 1.31f;
            if (biquad[2]) biquad[2].type = BIQUAD_DISABLED;
            if (biquad[3]) biquad[3].type = BIQUAD_DISABLED;
            break;
            
        case FILTER_ORDER_8:
            if (biquad[0]) biquad[0].qFac = 0.90f;
            if (biquad[1]) biquad[1].qFac = 2.65f;
            if (biquad[2]) biquad[2].qFac = 0.51f;
            if (biquad[3]) biquad[3].qFac = 0.60f;
            break;
    }
    
    return [NSArray arrayWithObjects:biquad count:4];
}

//get AMPL FREQ response
- (double) getAFR:(double)freqX
{
    double resultAFR = 1.0;
    NSArray * biquads = [self getBiquads];
    
    for (int i = 0; i < biquads.count; i++) {
        Biquad * biquad = [biquads objectAtIndex:i];
        resultAFR *= [biquad getAFR:freqX];
    }
    
    return resultAFR;
}

//info string
-(NSString *)getInfo
{
    int dbOnOctave[4] = {0, 12, 24, 48};// db/oct
    return [NSString stringWithFormat:@"%ddb/oct; Freq:%dHz", dbOnOctave[self.order], self.freq];
}

//send to dsp
- (void) sendWithResponse:(BOOL)response
{
    PassFilterPacket_t packet;
    
    packet.addr         = [self address];
    packet.biquadLength = self.biquadLength;//0,1,2,3
    packet.filter.order = self.order;
    packet.filter.type  = self.type;
    packet.filter.freq  = self.freq;
    
    //send data
    NSData *data = [[NSData alloc] initWithBytes:&packet length:sizeof(PassFilterPacket_t)];
    [[HiFiToyControl sharedInstance] sendDataToDsp:data withResponse:response];
}

//get binary for save to dsp
- (NSData *) getBinary
{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSArray * biquads = [self getBiquads];
    
    for (int i = 0; i < biquads.count; i++) {
        Biquad * biquad = [biquads objectAtIndex:i];
        [data appendData:[biquad getBinary]];
    }
    
    return data;
}

- (BOOL) importData:(NSData *)data
{
    NSArray * biquads = [self getBiquads];
    
    for (int i = 0; i < biquads.count; i++) {
        Biquad * biquad = [biquads objectAtIndex:i];
        if ([biquad importData:data] == NO) {
            return NO;
        }
    }
    
    Biquad * biquad = [biquads objectAtIndex:0];
    
    if (biquad) {
        self.freq = biquad.freq;
        self.type = biquad.type;
        
        if (fabs(biquad.qFac - 0.71) < 0.01) {
            self.order =  FILTER_ORDER_2;
            
        } else if (fabs(biquad.qFac - 0.54) < 0.01){
            self.order =  FILTER_ORDER_4;
            
        } if (fabs(biquad.qFac - 0.90) < 0.01) {
            self.order =  FILTER_ORDER_8;
        } else {
            return NO;
        }
        
    } else {
        return NO;
    }
    
    
    NSLog(@"import filter with order = %d", self.order);
    return YES;
}

/*---------------------------- XML export/import ----------------------------------*/
-(XmlData *) toXmlData{
    XmlData * xmlData = [[XmlData alloc] init];
    [xmlData addElementWithName:@"MaxFreq" withIntValue:self.maxFreq];
    [xmlData addElementWithName:@"MinFreq" withIntValue:self.minFreq];
    
    [xmlData addElementWithName:@"BiquadLength" withIntValue:self.biquadLength];
    [xmlData addElementWithName:@"Order" withIntValue:self.order];
    [xmlData addElementWithName:@"Type" withIntValue:self.type];
    [xmlData addElementWithName:@"Freq" withIntValue:self.freq];
    
    
    XmlData * biquadXmlData = [[XmlData alloc] init];
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                           [[NSNumber numberWithInt:self.address0] stringValue], @"Address0",
                           [[NSNumber numberWithInt:self.address1] stringValue], @"Address1", nil];
    
    
    [biquadXmlData addElementWithName:@"PassFilter" withXmlValue:xmlData withAttrib:dict];
    
    return biquadXmlData;
    
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
    
    if ([elementName isEqualToString:@"MaxFreq"]){
        self.maxFreq = [string intValue];
        count++;
    }
    if ([elementName isEqualToString:@"MinFreq"]){
        self.minFreq = [string intValue];
        count++;
    }
    
    if ([elementName isEqualToString:@"BiquadLength"]){
        self.biquadLength = [string intValue];
        count++;
    }
    if ([elementName isEqualToString:@"Order"]){
        self.order = [string intValue];
        count++;
    }
    if ([elementName isEqualToString:@"Type"]){
        self.type = [string intValue];
        count++;
    }
    if ([elementName isEqualToString:@"Freq"]){
        self.freq = [string intValue];
        count++;
    }
}

- (void) didEndXmlElement:(NSString *)elementName
                   parser:(XmlParserWrapper *)xmlParser {
    
    if ([elementName isEqualToString:@"PassFilter"]){
        if (count != 6){
            xmlParser.error = [NSString stringWithFormat:
                               @"PassFilter=%@. Import from xml is not success. ",
                               [[NSNumber numberWithInt:self.address0] stringValue] ];
        }
        NSLog(@"%@", [self getInfo]);
        [xmlParser popDelegate];
    }
}

@end
