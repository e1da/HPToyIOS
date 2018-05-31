//
//  PassFilter.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 30/05/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "PassFilter.h"

@interface PassFilter(){
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
    [encoder encodeInt:self.order forKey:@"keyOrder"];
    [encoder encodeInt:self.type forKey:@"keyType"];
    
    [encoder encodeObject:self.biquad0 forKey:@"keyBiquad0"];
    [encoder encodeObject:self.biquad1 forKey:@"keyBiquad1"];
    [encoder encodeObject:self.biquad2 forKey:@"keyBiquad2"];
    [encoder encodeObject:self.biquad3 forKey:@"keyBiquad3"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.biquad0 = [decoder decodeObjectForKey:@"keyBiquad0"];
        self.biquad1 = [decoder decodeObjectForKey:@"keyBiquad1"];
        self.biquad2 = [decoder decodeObjectForKey:@"keyBiquad2"];
        self.biquad3 = [decoder decodeObjectForKey:@"keyBiquad3"];
        
        self.maxOrder = [decoder decodeIntForKey:@"keyMaxOrder"];
        self.minOrder = [decoder decodeIntForKey:@"keyMinOrder"];
        self.order = [decoder decodeIntForKey:@"keyOrder"];
        self.type = [decoder decodeIntForKey:@"keyType"];
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
    copyFilter.order = self.order;
    copyFilter.type = self.type;
    
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
            (self.minOrder != temp.minOrder) ||
            (self.order != temp.order) ||
            (self.type != temp.type)){
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
    currentInstance.biquad0 = [Biquad initWithAddress:addr Order:BIQUAD_ORDER_2 Type:type
                                                 Freq:freq Qfac:0.71f dbVolume:0.0f];
    
    currentInstance.biquad1 = [Biquad initWithAddress:(addr + 1) Order:BIQUAD_ORDER_2 Type:type
                                                 Freq:freq Qfac:0.71f dbVolume:0.0f];
    
    if (biquadLength == BIQUAD_LENGTH_4) {
        currentInstance.biquad2 = [Biquad initWithAddress:(addr + 2) Order:BIQUAD_ORDER_2 Type:type
                                                     Freq:freq Qfac:0.71f dbVolume:0.0f];
        
        currentInstance.biquad3 = [Biquad initWithAddress:(addr + 3) Order:BIQUAD_ORDER_2 Type:type
                                                     Freq:freq Qfac:0.71f dbVolume:0.0f];
    }
    
    currentInstance.type = type;
    //set real value for each biquad
    currentInstance.order = order;
    
    return currentInstance;
}

- (uint8_t) address {
    return self.biquad0.address;
}

// getter/setter
-(void) setOrder:(PassFilterOrder_t)order
{
    _order  = order;
    
    if (_order > self.maxOrder) _order = self.maxOrder;
    if (_order < self.minOrder) _order = self.minOrder;
    
    
    if ((!self.biquad2) || (!self.biquad3)){
        self.biquad2 = nil;
        self.biquad3 = nil;
        if (_order > FILTER_ORDER_4){
            _order = FILTER_ORDER_4;
        }
    }
    
    //for sync all biquads freq
    [self setFreq:self.biquad0.freq];
    
    switch (_order){
        case FILTER_ORDER_2:
            self.biquad0.qFac = 0.71f;
            
            self.biquad0.type = self.type;
            self.biquad1.type = BIQUAD_DISABLED;
            if (self.biquad2) self.biquad2.type = BIQUAD_DISABLED;
            if (self.biquad3) self.biquad3.type = BIQUAD_DISABLED;
            break;
        case FILTER_ORDER_4:
            self.biquad0.qFac = 0.54f;
            self.biquad1.qFac = 1.31f;
            
            self.biquad0.type = self.type;
            self.biquad1.type = self.type;
            if (self.biquad2) self.biquad2.type = BIQUAD_DISABLED;
            if (self.biquad3) self.biquad3.type = BIQUAD_DISABLED;
            break;
        case FILTER_ORDER_8:
            self.biquad0.qFac = 0.90f;
            self.biquad1.qFac = 2.65f;
            self.biquad2.qFac = 0.51f;
            self.biquad3.qFac = 0.60f;
            
            self.biquad0.type = self.type;
            self.biquad1.type = self.type;
            self.biquad2.type = self.type;
            self.biquad3.type = self.type;
            break;
    }
    
}

-(void) setType:(PassFilterType_t)type
{
    self.biquad0.type = type;
    self.biquad1.type = type;
    
    //if we have filter with 2 phys biquads
    if ((!self.biquad2) || (!self.biquad3)) return;
    
    self.biquad2.type = type;
    self.biquad3.type = type;
}

-(void) setFreq:(int)freq
{
    self.biquad0.freq = freq;
    self.biquad1.freq = freq;
    
    //if we have filter with 2 phys biquads
    if ((!self.biquad2) || (!self.biquad3)) return;
    
    self.biquad2.freq = freq;
    self.biquad3.freq = freq;
}

-(int) Freq
{
    return self.biquad0.freq;
}

-(void) setEnabled:(BOOL)enabled
{
    if ([self isEnabled] != enabled) {
        BiquadType_t bType = (enabled) ? self.type : BIQUAD_DISABLED;
        
        self.biquad0.type = bType;
        self.biquad1.type = bType;
        
        if ((self.biquad2) && (self.biquad3)) {
            self.biquad2.type = bType;
            self.biquad3.type = bType;
        }
        
        [self sendWithResponse:YES];
    }
    
}

-(BOOL) isEnabled
{
    return (self.biquad0.type != BIQUAD_DISABLED);
}

-(void) setPassFilter:(PassFilter *)filter
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
}

//border setter function
- (void) setBorderMaxFreq:(int)maxFreq minFreq:(int)minFreq
{
    [self.biquad0 setBorderMaxFreq:maxFreq minFreq:minFreq];
    [self.biquad1 setBorderMaxFreq:maxFreq minFreq:minFreq];
    
    //if we have filter with 2 phys biquads
    if ((!self.biquad2) || (!self.biquad3)) return;
    
    [self.biquad2 setBorderMaxFreq:maxFreq minFreq:minFreq];
    [self.biquad3 setBorderMaxFreq:maxFreq minFreq:minFreq];
}

- (void) setBorderMaxQfac:(double)maxQfac minQfac:(double)minQfac
{
    [self.biquad0 setBorderMaxQfac:maxQfac minQfac:minQfac];
    [self.biquad1 setBorderMaxQfac:maxQfac minQfac:minQfac];
    
    //if we have filter with 2 phys biquads
    if ((!self.biquad2) || (!self.biquad3)) return;
    
    [self.biquad2 setBorderMaxQfac:maxQfac minQfac:minQfac];
    [self.biquad3 setBorderMaxQfac:maxQfac minQfac:minQfac];
}

- (void) setBorderMaxDbVolume:(double)maxDbVolume minDbVolume:(double)minDbVolume
{
    [self.biquad0 setBorderMaxDbVolume:maxDbVolume minDbVolume:minDbVolume];
    [self.biquad1 setBorderMaxDbVolume:maxDbVolume minDbVolume:minDbVolume];
    
    //if we have filter with 2 phys biquads
    if ((!self.biquad2) || (!self.biquad3)) return;
    
    [self.biquad2 setBorderMaxDbVolume:maxDbVolume minDbVolume:minDbVolume];
    [self.biquad3 setBorderMaxDbVolume:maxDbVolume minDbVolume:minDbVolume];
    
    
}

- (void) setBorderMaxOrder:(int)maxOrder minOrder:(double)minOrder
{
    self.maxOrder = maxOrder;
    self.minOrder = minOrder;
}

- (void) setBorderMaxFreq:(int)maxFreq minFreq:(int)minFreq
                  maxQfac:(double)maxQfac minQfac:(double)minQfac
              maxDbVolume:(double)maxDbVolume minQfac:(double)minDbVolume
                 maxOrder:(int)maxOrder minOrder:(double)minOrder
{
    [self setBorderMaxFreq:maxFreq minFreq:minFreq];
    [self setBorderMaxQfac:maxQfac minQfac:minQfac];
    [self setBorderMaxDbVolume:maxDbVolume minDbVolume:minDbVolume];
    [self setBorderMaxOrder:maxOrder minOrder:minOrder];
}

//get AMPL FREQ response
- (double) getAFR:(double)freqX
{
    double resultAFR = [self.biquad0 getAFR:freqX] * [self.biquad1 getAFR:freqX];
    
    if ((self.biquad2) && (self.biquad3)){
        resultAFR *= [self.biquad2 getAFR:freqX] * [self.biquad3 getAFR:freqX];
    }
    
    return resultAFR;
}

//info string
-(NSString *)getInfo
{
    int printOrder = 0;
    switch (self.order){
        case FILTER_ORDER_2:
            printOrder = 12;
            break;
        case FILTER_ORDER_4:
            printOrder = 24;
            break;
        case FILTER_ORDER_8:
            printOrder = 48;
            break;
    }
    return [NSString stringWithFormat:@"%ddb/oct; Freq:%dHz", printOrder, [self Freq]];
    
}

//send to dsp
- (void) sendWithResponse:(BOOL)response
{
    PassFilterPacket_t packet;
    packet.addr         = self.biquad0.address;
    packet.biquadLength = ((self.biquad2) && (self.biquad3)) ? 4 : 2;
    packet.filter.order = self.order;
    packet.filter.type  = self.type;
    packet.filter.freq  = self.Freq;
    
    //send data
    NSData *data = [[NSData alloc] initWithBytes:&packet length:sizeof(PassFilterPacket_t)];
    
    //[[DSPControl sharedInstance] sendDataToDsp:data withResponse:response];
}

//get binary for save to dsp
- (NSData *) getBinary
{
    NSMutableData *data = [[NSMutableData alloc] init];
    
    [data appendData:[self.biquad0 getBinary]];
    [data appendData:[self.biquad1 getBinary]];
    
    if ((self.biquad2) && (self.biquad3)){
        [data appendData:[self.biquad2 getBinary]];
        [data appendData:[self.biquad3 getBinary]];
    }
    
    return data;
}

- (BOOL) importData:(NSData *)data
{
    if ([self.biquad0 importData:data] == NO){
        return NO;
    }
    if ([self.biquad1 importData:data] == NO){
        return NO;
    }
    
    
    //for check order
    if ((self.biquad2) && (self.biquad3)){
        if ([self.biquad2 importData:data] == NO){
            return NO;
        }
        if ([self.biquad3 importData:data] == NO){
            return NO;
        }
        self.order = FILTER_ORDER_8;
    } else {
        self.biquad2 = nil;
        self.biquad3 = nil;
        self.Order = FILTER_ORDER_4;
    }
    
    
    NSLog(@"import filter with order = %d", self.order);
    return YES;
}

-(XmlData *) toXmlData{
    XmlData * xmlData = [[XmlData alloc] init];
    [xmlData addElementWithName:@"MaxOrder" withIntValue:self.maxOrder];
    [xmlData addElementWithName:@"MinOrder" withIntValue:self.minOrder];
    [xmlData addElementWithName:@"Type" withIntValue:self.type];
    [xmlData addElementWithName:@"Order" withIntValue:self.order];
    
    [xmlData addXmlData:[_biquad0 toXmlData]];
    [xmlData addXmlData:[_biquad1 toXmlData]];
    
    if ((self.biquad2) && (self.biquad3)){
        [xmlData addXmlData:[_biquad2 toXmlData]];
        [xmlData addXmlData:[_biquad3 toXmlData]];
    }
    
    XmlData * filterXmlData = [[XmlData alloc] init];
    
    int addr = self.biquad0.address;
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
    
    if (self.biquad0.address == addr){
        [self.biquad0 importFromXml:xmlParser withAttrib:attributeDict];
        count++;
    }
    if (self.biquad1.address == addr){
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
    if ([elementName isEqualToString:@"Type"]){
        self.type = [string intValue];
        count++;
    }
    if ([elementName isEqualToString:@"Order"]){
        self.Order = [string intValue];
        count++;
    }
}

- (void) didEndXmlElement:(NSString *)elementName
                   parser:(XmlParserWrapper *)xmlParser {
    
    if ([elementName isEqualToString:@"PassFilter"]){
        BOOL success;
        if ((self.biquad2) && (self.biquad3)){
            success = (count == (4 + 4)) ? YES : NO;
        } else {
            success = (count == (2 + 4)) ? YES : NO;
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
