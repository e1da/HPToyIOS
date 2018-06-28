//
//  PassFilter.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 30/05/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "PassFilter.h"
#import "HiFiToyControl.h"

@interface PassFilter(){
    Biquad * biquad[4];
    
    int count;
}
@end

@implementation PassFilter

/*==========================================================================================
 Init
 ==========================================================================================*/
- (id) init
{
    self = [super init];
    if (self){
        [self setBorderMaxOrder:FILTER_ORDER_8 minOrder:FILTER_ORDER_2];
    }
    
    return self;
}

/*==========================================================================================
 NSCoding protocol implementation
 ==========================================================================================*/

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:self.maxOrder forKey:@"keyMaxOrder"];
    [encoder encodeInt:self.minOrder forKey:@"keyMinOrder"];
    //[encoder encodeInt:self.order forKey:@"keyOrder"];
    
    [encoder encodeObject:biquad[0] forKey:@"keyBiquad0"];
    [encoder encodeObject:biquad[1] forKey:@"keyBiquad1"];
    [encoder encodeObject:biquad[2] forKey:@"keyBiquad2"];
    [encoder encodeObject:biquad[3] forKey:@"keyBiquad3"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        biquad[0] = [decoder decodeObjectForKey:@"keyBiquad0"];
        biquad[1] = [decoder decodeObjectForKey:@"keyBiquad1"];
        biquad[2] = [decoder decodeObjectForKey:@"keyBiquad2"];
        biquad[3] = [decoder decodeObjectForKey:@"keyBiquad3"];
        
        self.maxOrder = [decoder decodeIntForKey:@"keyMaxOrder"];
        self.minOrder = [decoder decodeIntForKey:@"keyMinOrder"];
        self.order = [decoder decodeIntForKey:@"keyOrder"];
    }
    return self;
}

/*==========================================================================================
 NSCopying protocol implementation
 ==========================================================================================*/
-(PassFilter *)copyWithZone:(NSZone *)zone
{
    PassFilter * copyFilter = [[[self class] allocWithZone:zone] init];
    
    //copyFilter.numberBiquads = self.numberBiquads;
    copyFilter.biquad0 = [self.biquad0 copy];
    copyFilter.biquad1 = [self.biquad1 copy];
    copyFilter.biquad2 = [self.biquad2 copy];
    copyFilter.biquad3 = [self.biquad3 copy];
    
    copyFilter.maxOrder = self.maxOrder;
    copyFilter.minOrder = self.minOrder;
    //copyFilter.order = self.order;
    
    return copyFilter;
}

/*==========================================================================================
 isEqual implementation
 ==========================================================================================*/
- (BOOL) isEqual: (id) object
{
    if ([object class] == [self class]){
        PassFilter * temp = object;
        
        if (([self.biquad0 isEqual:temp.biquad0] == NO) ||
            ([self.biquad1 isEqual:temp.biquad1] == NO) ||
            
            (self.maxOrder != temp.maxOrder) ||
            (self.minOrder != temp.minOrder) //||
            /*(self.order != temp.order)*/){
            return NO;
        }
        
        if ((!self.biquad2) || (!self.biquad3)){//if nil
            if ((self.biquad2 != temp.biquad2) ||
                (self.biquad3 != temp.biquad3)){
                return NO;
            }
        } else {
            if (([self.biquad2 isEqual:temp.biquad2] == NO) ||
                ([self.biquad3 isEqual:temp.biquad3] == NO)){
                return NO;
            }
        }
        
        return YES;
    }
    return NO;
}

/*---------------------- create method -----------------------------*/
+ (PassFilter *)initWithOrder:(PassFilterOrder_t)order Type:(PassFilterType_t)type Freq:(int)freq
                         Addr:(int)addr
                 BiquadLength:(BiquadLength_t)biquadLength
{
    PassFilter *currentInstance = [[PassFilter alloc] init];
    
    //set default value for all biquad
    switch (biquadLength) {
        case BIQUAD_LENGTH_4:
            currentInstance.biquad3 = [Biquad initWithAddress:(addr + 3) Order:BIQUAD_ORDER_2 Type:type
                                                         Freq:freq Qfac:0.71f dbVolume:0.0f];
            currentInstance.biquad2 = [Biquad initWithAddress:(addr + 2) Order:BIQUAD_ORDER_2 Type:type
                                                         Freq:freq Qfac:0.71f dbVolume:0.0f];
        case BIQUAD_LENGTH_2:
            currentInstance.biquad1 = [Biquad initWithAddress:(addr + 1) Order:BIQUAD_ORDER_2 Type:type
                                                         Freq:freq Qfac:0.71f dbVolume:0.0f];
        case BIQUAD_LENGTH_1:
            currentInstance.biquad0 = [Biquad initWithAddress:addr Order:BIQUAD_ORDER_2 Type:type
                                                         Freq:freq Qfac:0.71f dbVolume:0.0f];
            break;
        case BIQUAD_LENGTH_0:
            break;
    }
    
    //set real value for each biquad
    [currentInstance setOrder:order];
    //currentInstance.order = order;
    
    return currentInstance;
}

- (uint8_t) address {
    if (self.biquad0) {
        return self.biquad0.address;
    }
    return 0;
}

// getter/setter
-(BiquadLength_t) getBiquadLength
{
    if ((_biquad2) && (_biquad3)) {
        return BIQUAD_LENGTH_4;
    } else if (_biquad1){
        return BIQUAD_LENGTH_2;
    } else if (_biquad0){
        return BIQUAD_LENGTH_1;
    }
    
    return BIQUAD_LENGTH_0;
}

-(void) setOrder:(PassFilterOrder_t)order
{
    //_order  = order;
    
    //check border
    if (order > self.maxOrder) order = self.maxOrder;
    if (order < self.minOrder) order = self.minOrder;
    
    if (order > [self getBiquadLength]) order = (PassFilterOrder_t)[self getBiquadLength];

    
    //for sync all biquads freq
    [self setFreq:self.biquad0.freq];
    
    switch (order){
        case FILTER_ORDER_0:
            
            break;
        case FILTER_ORDER_2:
            self.biquad0.qFac = 0.71f;
            
            if (self.biquad1) self.biquad1.type = BIQUAD_DISABLED;
            if (self.biquad2) self.biquad2.type = BIQUAD_DISABLED;
            if (self.biquad3) self.biquad3.type = BIQUAD_DISABLED;
            break;
        case FILTER_ORDER_4:
            self.biquad0.qFac = 0.54f;
            self.biquad1.qFac = 1.31f;
            
            if (self.biquad2) self.biquad2.type = BIQUAD_DISABLED;
            if (self.biquad3) self.biquad3.type = BIQUAD_DISABLED;
            break;
        case FILTER_ORDER_8:
            self.biquad0.qFac = 0.90f;
            self.biquad1.qFac = 2.65f;
            self.biquad2.qFac = 0.51f;
            self.biquad3.qFac = 0.60f;
            break;
    }
    
}

-(PassFilterOrder_t) getOrder
{
    if (self.biquad0) {
        if ((fabs(self.biquad0.qFac - 0.71) < 0.01) && ([self getBiquadLength] >= BIQUAD_LENGTH_1)) {
            return FILTER_ORDER_2;
            
        } else if ((fabs(self.biquad0.qFac - 0.54) < 0.01) && ([self getBiquadLength] >= BIQUAD_LENGTH_2)){
            return FILTER_ORDER_4;
            
        } if ((fabs(self.biquad0.qFac - 0.90) < 0.01) && ([self getBiquadLength] == BIQUAD_LENGTH_4)) {
            return FILTER_ORDER_8;
        }
    }
    return FILTER_ORDER_0;
}
    
-(void) setType:(PassFilterType_t)type
{
    if ((type != BIQUAD_LOWPASS) || (type != BIQUAD_HIGHPASS)) type = BIQUAD_DISABLED;
    
    if (_biquad0) _biquad0.type = type;
    if (_biquad1) _biquad1.type = type;
    if (_biquad2) _biquad2.type = type;
    if (_biquad3) _biquad3.type = type;
}

-(PassFilterType_t) getType
{
    if (_biquad0) {
        return _biquad0.type;
    }
    return BIQUAD_DISABLED;
}

-(void) setFreq:(int)freq
{
    if (_biquad0) _biquad0.freq = freq;
    if (_biquad1) _biquad1.freq = freq;
    if (_biquad2) _biquad2.freq = freq;
    if (_biquad3) _biquad3.freq = freq;
}

-(int) Freq
{
    return self.biquad0.freq;
}

/*-(void) setEnabled:(BOOL)enabled
{
    if ([self isEnabled] != enabled) {
        BiquadType_t bType = (enabled) ? self.type : BIQUAD_DISABLED;
        
        [self setType:bType];
        [self sendWithResponse:YES];
    }
    
}*/

-(BOOL) isEnabled
{
    return ([self getType] != BIQUAD_DISABLED);
}

/*-(void) setPassFilter:(PassFilter *)filter
{
    [self.biquad0 setBiquad:filter.biquad0];
    [self.biquad1 setBiquad:filter.biquad1];
    
    if ((filter.biquad2) && (filter.biquad3)) {
        if (!self.biquad2) self.biquad2 = [[Biquad alloc] init];
        if (!self.biquad3) self.biquad3 = [[Biquad alloc] init];

        [self.biquad2 setBiquad:filter.biquad2];
        [self.biquad3 setBiquad:filter.biquad3];
        
    } else {
        self.biquad2 = nil;
        self.biquad3 = nil;
    }
    
    self.maxOrder = filter.maxOrder;
    self.minOrder = filter.minOrder;
    self.type = filter.type;
    self.order = filter.order;
}*/

//border setter function
- (void) setBorderMaxFreq:(int)maxFreq minFreq:(int)minFreq
{
    if (self.biquad0) [self.biquad0 setBorderMaxFreq:maxFreq minFreq:minFreq];
    if (self.biquad1) [self.biquad1 setBorderMaxFreq:maxFreq minFreq:minFreq];
    if (self.biquad2) [self.biquad2 setBorderMaxFreq:maxFreq minFreq:minFreq];
    if (self.biquad3) [self.biquad3 setBorderMaxFreq:maxFreq minFreq:minFreq];
}

- (void) setBorderMaxQfac:(double)maxQfac minQfac:(double)minQfac
{
    if (self.biquad0) [self.biquad0 setBorderMaxQfac:maxQfac minQfac:minQfac];
    if (self.biquad1) [self.biquad1 setBorderMaxQfac:maxQfac minQfac:minQfac];
    if (self.biquad2) [self.biquad2 setBorderMaxQfac:maxQfac minQfac:minQfac];
    if (self.biquad3) [self.biquad3 setBorderMaxQfac:maxQfac minQfac:minQfac];
}

- (void) setBorderMaxDbVolume:(double)maxDbVolume minDbVolume:(double)minDbVolume
{
    if (self.biquad0) [self.biquad0 setBorderMaxDbVolume:maxDbVolume minDbVolume:minDbVolume];
    if (self.biquad1) [self.biquad1 setBorderMaxDbVolume:maxDbVolume minDbVolume:minDbVolume];
    if (self.biquad2) [self.biquad2 setBorderMaxDbVolume:maxDbVolume minDbVolume:minDbVolume];
    if (self.biquad3) [self.biquad3 setBorderMaxDbVolume:maxDbVolume minDbVolume:minDbVolume];
    
    
}

- (void) setBorderMaxOrder:(PassFilterOrder_t)maxOrder minOrder:(PassFilterOrder_t)minOrder
{
    if (maxOrder > [self getBiquadLength]) maxOrder = (PassFilterOrder_t)[self getBiquadLength];
    if (minOrder > maxOrder) minOrder = maxOrder;
    
    self.maxOrder = maxOrder;
    self.minOrder = minOrder;
}

- (void) setBorderMaxFreq:(int)maxFreq minFreq:(int)minFreq
                  maxQfac:(double)maxQfac minQfac:(double)minQfac
              maxDbVolume:(double)maxDbVolume minQfac:(double)minDbVolume
                 maxOrder:(PassFilterOrder_t)maxOrder minOrder:(PassFilterOrder_t)minOrder
{
    [self setBorderMaxFreq:maxFreq minFreq:minFreq];
    [self setBorderMaxQfac:maxQfac minQfac:minQfac];
    [self setBorderMaxDbVolume:maxDbVolume minDbVolume:minDbVolume];
    [self setBorderMaxOrder:maxOrder minOrder:minOrder];
}

//get AMPL FREQ response
- (double) getAFR:(double)freqX
{
    double resultAFR = 1.0;
    
    if (self.biquad0) resultAFR *= [self.biquad0 getAFR:freqX];
    if (self.biquad1) resultAFR *= [self.biquad1 getAFR:freqX];
    if (self.biquad2) resultAFR *= [self.biquad2 getAFR:freqX];
    if (self.biquad3) resultAFR *= [self.biquad3 getAFR:freqX];
    
    return resultAFR;
}

//info string
-(NSString *)getInfo
{
    int dbOnOctave[4] = {0, 12, 24, 48};// db/oct
    int index = [self getOrder];
    return [NSString stringWithFormat:@"%ddb/oct; Freq:%dHz", dbOnOctave[index], [self Freq]];
}

//send to dsp
- (void) sendWithResponse:(BOOL)response
{
    PassFilterPacket_t packet;
    packet.addr         = [self address];
    packet.biquadLength = [self getBiquadLength];//0,1,2,3
    packet.filter.order = [self getOrder];
    packet.filter.type  = [self getType];
    packet.filter.freq  = self.Freq;
    
    //send data
    NSData *data = [[NSData alloc] initWithBytes:&packet length:sizeof(PassFilterPacket_t)];
    
    [[HiFiToyControl sharedInstance] sendDataToDsp:data withResponse:response];
}

//get binary for save to dsp
- (NSData *) getBinary
{
    NSMutableData *data = [[NSMutableData alloc] init];
    
    if (self.biquad0) [data appendData:[self.biquad0 getBinary]];
    if (self.biquad1) [data appendData:[self.biquad1 getBinary]];
    if (self.biquad2) [data appendData:[self.biquad2 getBinary]];
    if (self.biquad3) [data appendData:[self.biquad3 getBinary]];
    
    return data;
}

- (BOOL) importData:(NSData *)data
{
    if ((self.biquad0) && ([self.biquad0 importData:data] == NO)) {
        return NO;
    }
    if ((self.biquad1) && ([self.biquad1 importData:data] == NO)) {
        return NO;
    }
    if ((self.biquad2) && ([self.biquad2 importData:data] == NO)) {
        return NO;
    }
    if ((self.biquad3) && ([self.biquad3 importData:data] == NO)) {
        return NO;
    }
    
    
    NSLog(@"import filter with order = %d", [self getOrder]);
    return YES;
}

/*---------------------------- XML export/import ----------------------------------*/
-(XmlData *) toXmlData{
    XmlData * xmlData = [[XmlData alloc] init];
    [xmlData addElementWithName:@"MaxOrder" withIntValue:self.maxOrder];
    [xmlData addElementWithName:@"MinOrder" withIntValue:self.minOrder];
    
    if (self.biquad0) [xmlData addXmlData:[_biquad0 toXmlData]];
    if (self.biquad1) [xmlData addXmlData:[_biquad1 toXmlData]];
    if (self.biquad2) [xmlData addXmlData:[_biquad2 toXmlData]];
    if (self.biquad3) [xmlData addXmlData:[_biquad3 toXmlData]];
    
    XmlData * filterXmlData = [[XmlData alloc] init];
    
    int addr = [self address];
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                           [[NSNumber numberWithInt:addr] stringValue], @"Address", nil];
    
    [filterXmlData addElementWithName:@"PassFilter" withXmlValue:xmlData withAttrib:dict];
    
    return filterXmlData;
}

-(void) importFromXml:(XmlParserWrapper *)xmlParser withAttrib:(NSDictionary<NSString *, NSString *> *)attributeDict {
    count = 0;
    [xmlParser pushDelegate:self];
}

/* -------------------------------------- XmlParserDelegate ---------------------------------------*/
- (void) didFindXmlElement:(NSString *)elementName
                attributes:(NSDictionary<NSString *, NSString *> *)attributeDict
                    parser:(XmlParserWrapper *)xmlParser {
    
    //get Address of Biquad
    NSString * addrStr = [attributeDict objectForKey:@"Address"];
    if (!addrStr) return;
    int addr = [addrStr intValue];
    
    if ((self.biquad0) && (self.biquad0.address == addr)){
        [self.biquad0 importFromXml:xmlParser withAttrib:attributeDict];
        count++;
    }
    if ((self.biquad1) && (self.biquad1.address == addr)){
        [self.biquad1 importFromXml:xmlParser withAttrib:attributeDict];
        count++;
    }
    
    if ((self.biquad2) && (self.biquad3)){
        if (self.biquad2.address == addr){
            [self.biquad2 importFromXml:xmlParser withAttrib:attributeDict];
            count++;
        }
        if (self.biquad3.address == addr){
            [self.biquad3 importFromXml:xmlParser withAttrib:attributeDict];
            count++;
        }
    }
}

- (void) didFoundXmlCharacters:(NSString *)string
                    forElement:(NSString *)elementName
                        parser:(XmlParserWrapper *)xmlParser {
    if ([elementName isEqualToString:@"MaxOrder"]){
        self.maxOrder = [string intValue];
        count++;
    }
    if ([elementName isEqualToString:@"MinOrder"]){
        self.minOrder = [string intValue];
        count++;
    }
}

- (void) didEndXmlElement:(NSString *)elementName
                   parser:(XmlParserWrapper *)xmlParser {
    
    if ([elementName isEqualToString:@"PassFilter"]){
        BOOL success;
        if (self.biquad3) {
            success = (count == (4 + 2)) ? YES : NO;
            
        } else if (self.biquad2) {
            success = (count == (3 + 2)) ? YES : NO;
            
        } else if (self.biquad1) {
            success = (count == (2 + 2)) ? YES : NO;
            
        } else if (self.biquad0) {
            success = (count == (1 + 2)) ? YES : NO;
            
        } else {
            success = (count == (0 + 2)) ? YES : NO;
        }
        if (success == NO){
            xmlParser.error = [NSString stringWithFormat:
                               @"PassFilter=%@. Import from xml is not success. ",
                               [[NSNumber numberWithInt:[self address]] stringValue] ];
            
        }
        NSLog(@"%@", [self getInfo]);
        [xmlParser popDelegate];
    }
}


@end
