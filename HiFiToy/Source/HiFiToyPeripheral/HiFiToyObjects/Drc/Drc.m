//
//  Drc.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 30/05/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "Drc.h"
#import "TAS5558.h"
#import "Number523.h"
#import "IntegerUtility.h"
#import "HiFiToyControl.h"

@interface Drc(){
    int count;
}
@end

@implementation Drc

/*==========================================================================================
 Init
 ==========================================================================================*/
- (id) init {
    self = [super init];
    if (self) {
        self.coef17 = [DrcCoef initWithChannel:DRC_CH_1_7];
        self.coef8 = [DrcCoef initWithChannel:DRC_CH_8];
        self.timeConst17 = [DrcTimeConst initWithChannel:DRC_CH_1_7];
        self.timeConst8 = [DrcTimeConst initWithChannel:DRC_CH_8];
        
    }
    return self;
}

/*---------------------- create methods -----------------------------*/
+ (Drc *) initWithCoef17:(DrcCoef *)coef17
                  Coef8:(DrcCoef *)coef8
            TimeConst17:(DrcTimeConst *)timeConst17
             TimeConst8:(DrcTimeConst *)timeConst8; {
    Drc * currentInstance = [[Drc alloc] init];
    
    currentInstance.coef17 = coef17;
    currentInstance.coef8 = coef8;
    currentInstance.timeConst17 = timeConst17;
    currentInstance.timeConst8 = timeConst8;
    
    return currentInstance;
}


/*==========================================================================================
 NSCoding protocol implementation
 ==========================================================================================*/
- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.coef17 forKey:@"keyCoef17"];
    [encoder encodeObject:self.coef8 forKey:@"keyCoef8"];
    [encoder encodeObject:self.timeConst17 forKey:@"keyTimeConst17"];
    [encoder encodeObject:self.timeConst8 forKey:@"keyTimeConst8"];
    
    for (int i = 0; i < 8; i++) {
        NSString * keyStr = [NSString stringWithFormat:@"keyEvaluationCh%d", i];
        [encoder encodeInt:evaluationCh[i] forKey:keyStr];
    }
    
    for (int i = 0; i < 8; i++) {
        NSString * keyStr = [NSString stringWithFormat:@"keyEnabledCh%d", i];
        [encoder encodeFloat:enabledCh[i] forKey:keyStr];
    }
}

- (id) initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.coef17         = [decoder decodeObjectForKey:@"keyCoef17"];
        self.coef8          = [decoder decodeObjectForKey:@"keyCoef8"];
        self.timeConst17    = [decoder decodeObjectForKey:@"keyTimeConst17"];
        self.timeConst8     = [decoder decodeObjectForKey:@"keyTimeConst8"];
        
        for (int i = 0; i < 8; i++) {
            NSString * keyStr = [NSString stringWithFormat:@"keyEvaluationCh%d", i];
            evaluationCh[i] = [decoder decodeIntForKey:keyStr];
        }
        
        for (int i = 0; i < 8; i++) {
            NSString * keyStr = [NSString stringWithFormat:@"keyEnabledCh%d", i];
            enabledCh[i] = [decoder decodeFloatForKey:keyStr];
        }
    }
    return self;
}

/*==========================================================================================
 NSCopying protocol implementation
 ==========================================================================================*/
-(Drc *)copyWithZone:(NSZone *)zone {
    Drc * copyDrc = [[[self class] allocWithZone:zone] init];
    
    copyDrc.coef17          = [self.coef17 copy];
    copyDrc.coef8           = [self.coef8 copy];
    copyDrc.timeConst17     = [self.timeConst17 copy];
    copyDrc.timeConst8      = [self.timeConst8 copy];
    
    for (int i = 0; i < 8; i++){
        [copyDrc setEvaluation:evaluationCh[i] forChannel:i];
    }
    
    for (int i = 0; i < 8; i++){
        [copyDrc setEnabled:enabledCh[i] forChannel:i];
    }
    
    return copyDrc;
}

/*==========================================================================================
 isEqual implementation
 ==========================================================================================*/
- (BOOL) isEqual: (id) object {
    if ([object class] == [self class]){
        Drc * temp = object;
        if ((![self.coef17 isEqual:temp.coef17]) ||
            (![self.coef8 isEqual:temp.coef8]) ||
            (![self.timeConst17 isEqual:temp.timeConst17]) ||
            (![self.timeConst8 isEqual:temp.timeConst8])){
            
            return NO;
        }
        
        for (int i = 0; i < 8; i++){
            if (evaluationCh[i] != [temp getEvaluationChannel:i]) {
                return NO;
            }
        }
        
        for (int i = 0; i < 8; i++){
            if (fabs(enabledCh[i] - [temp getEnabledChannel:i]) > 0.02f) {
                return NO;
            }
        }
        return YES;
    }
    
    return NO;
}

//getters / setters
//enabled = 0.0 .. 1.0
-(void) setEnabled:(float)enabled forChannel:(uint8_t)channel {
    if (channel > 7) channel = 7;
    enabledCh[channel] = enabled;
}

//return enabled = 0.0 .. 1.0
-(float) getEnabledChannel:(uint8_t)channel {
    if (channel > 7) channel = 7;
    return enabledCh[channel];
}

-(void) setEvaluation:(DrcEvaluation_t)evaluation forChannel:(uint8_t)channel {
    if (channel > 7) channel = 7;
    evaluationCh[channel] = evaluation;
}

-(float) getEvaluationChannel:(uint8_t)channel {
    if (channel > 7) channel = 7;
    return evaluationCh[channel];
}

- (uint8_t) address {
    return DRC1_CONTROL_REG;
}

//info string
-(NSString *)getInfo {
    return [NSString stringWithFormat:@"Drc info"];
}

//send to dsp
- (void) sendEvaluationWithResponse:(BOOL)response {
    NSData *data = [[self getEvaluationDataBuf] binary];
    Packet_t packet;
    memcpy(&packet, data.bytes, data.length);
    
    //send data
    [[HiFiToyControl sharedInstance] sendPacketToDsp:&packet withResponse:response];
}

- (void) sendEnabledForChannel:(uint8_t)channel withResponse:(BOOL)response {
    NSData *data = [[self getEnabledDataBufForChannel:channel] binary];
    Packet_t packet;
    memcpy(&packet, data.bytes, data.length);
    
    //send data
    [[HiFiToyControl sharedInstance] sendPacketToDsp:&packet withResponse:response];
}

- (void) sendWithResponse:(BOOL)response {
    [self.coef17 sendWithResponse:response];
    [self.coef8 sendWithResponse:response];
    [self.timeConst17 sendWithResponse:response];
    [self.timeConst8 sendWithResponse:response];
    
    [self sendEvaluationWithResponse:response];
    
    for (int i = 0; i < 8; i++) {
        [self sendEnabledForChannel:i withResponse:response];
    }
}

- (HiFiToyDataBuf *) getEvaluationDataBuf {
    uint32_t data[2] = {0, 0};
    
    for (int i = 7; i >= 0; i--){
        data[0] <<= 2;
        data[0] |= evaluationCh[i] & 0x03;
    }
    data[0] = reverseUint32(data[0]);
    
    data[1] = evaluationCh[7] & 0x03;
    data[1] = reverseUint32(data[1]);
    
    return [HiFiToyDataBuf dataBufWithAddr:self.address
                                withLength:8
                                  withData:(uint8_t *)data];
}

- (HiFiToyDataBuf *) getEnabledDataBufForChannel:(uint8_t)channel {
    if (channel > 7) channel = 7;
    
    uint32_t val = reverseNumber523(0x800000 * enabledCh[channel]);
    uint32_t ival = reverseNumber523(0x800000 - 0x800000 * enabledCh[channel]);
    uint32_t data[2] = {ival, val};
    
    return [HiFiToyDataBuf dataBufWithAddr:(DRC_BYPASS1_REG + channel)
                                withLength:8
                                  withData:(uint8_t *)data];
}


- (NSArray<HiFiToyDataBuf *> *) getDataBufs {
    NSMutableArray<HiFiToyDataBuf *> * dataBufs = [[NSMutableArray alloc] init];
    
    [dataBufs addObjectsFromArray:[self.coef17 getDataBufs]];
    [dataBufs addObjectsFromArray:[self.coef8 getDataBufs]];
    [dataBufs addObjectsFromArray:[self.timeConst17 getDataBufs]];
    [dataBufs addObjectsFromArray:[self.timeConst8 getDataBufs]];
    
    [dataBufs addObject:[self getEvaluationDataBuf]];
    
    for (int i = 0; i < 8; i++) {
        [dataBufs addObject:[self getEnabledDataBufForChannel:i]];
    }
    
    return dataBufs;
}

- (BOOL) importFromDataBufs:(NSArray<HiFiToyDataBuf *> *)dataBufs {
    if ([self.coef17 importFromDataBufs:dataBufs] == NO) return NO;
    if ([self.coef8 importFromDataBufs:dataBufs] == NO) return NO;
    if ([self.timeConst17 importFromDataBufs:dataBufs] == NO) return NO;
    if ([self.timeConst8 importFromDataBufs:dataBufs] == NO) return NO;
    
    int importCount = 0;
    
    for (HiFiToyDataBuf * db in dataBufs) {
        if ((db.addr == [self address]) && (db.length == 8)){
            
            uint32_t * number = (uint32_t *)db.data.bytes;
            uint32_t d = reverseUint32(number[0]);
            
            for (int i = 0; i < 7; i++){
                evaluationCh[i] = d & 0x03;
                d >>= 2;
            }
            evaluationCh[7] = reverseUint32(number[1]) & 0x03;
            
            importCount++;
            if (importCount >= 9) break;
        }
        if ((db.addr >= DRC_BYPASS1_REG) && (db.addr < (DRC_BYPASS1_REG + 8)) &&
            (db.length == 8)){
            
            uint32_t * number = (uint32_t *)db.data.bytes;
            uint32_t val = reverseUint32(number[1]);
            
            enabledCh[db.addr - DRC_BYPASS1_REG] = _523toFloat(val);
    
            importCount++;
            if (importCount >= 9) break;
        }
    }
    
    if (importCount == 9) {
        return YES;
    }
    
    return NO;
}

/*---------------------------- XML export/import ----------------------------------*/
-(XmlData *) toXmlData {
    XmlData * xmlData = [[XmlData alloc] init];
    
    for (int i = 0; i < 8; i++){
        NSString * keyStr = [NSString stringWithFormat:@"enabledCh%d", i];
        [xmlData addElementWithName:keyStr withDoubleValue:enabledCh[i]];
    }
    for (int i = 0; i < 8; i++){
        NSString * keyStr = [NSString stringWithFormat:@"evaluationCh%d", i];
        [xmlData addElementWithName:keyStr withIntValue:evaluationCh[i]];
    }
    
    [xmlData addXmlData:[_coef17 toXmlData]];
    [xmlData addXmlData:[_coef8 toXmlData]];
    [xmlData addXmlData:[_timeConst17 toXmlData]];
    [xmlData addXmlData:[_timeConst8 toXmlData]];
    
    XmlData * drcXmlData = [[XmlData alloc] init];
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                           [[NSNumber numberWithInt:self.address] stringValue], @"Address", nil];
    
    [drcXmlData addElementWithName:@"Drc" withXmlValue:xmlData withAttrib:dict];
    
    return drcXmlData;
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
    NSString * channelStr = [attributeDict objectForKey:@"Channel"];
    if (!channelStr) return;
    DrcChannel_t channel = [channelStr intValue];
    
    if ([elementName isEqualToString:@"DrcCoef"]) {
        if (self.coef17.channel == channel){
            [self.coef17 importFromXml:xmlParser withAttrib:attributeDict];
            count++;
        }
        if (self.coef8.channel == channel){
            [self.coef8 importFromXml:xmlParser withAttrib:attributeDict];
            count++;
        }
    } else if ([elementName isEqualToString:@"DrcTimeConst"]) {
        if (self.timeConst17.channel == channel){
            [self.timeConst17 importFromXml:xmlParser withAttrib:attributeDict];
            count++;
        }
        if (self.timeConst8.channel == channel){
            [self.timeConst8 importFromXml:xmlParser withAttrib:attributeDict];
            count++;
        }
    }
    
}

- (void) didFoundXmlCharacters:(NSString *)string
                    forElement:(NSString *)elementName
                        parser:(XmlParserWrapper *)xmlParser {
    
    for (int i = 0; i < 8; i++){
        NSString * keyStr = [NSString stringWithFormat:@"enabledCh%d", i];
        if ([elementName isEqualToString:keyStr]){
            enabledCh[i] = [string doubleValue];
            count++;
        }
    }
    for (int i = 0; i < 8; i++){
        NSString * keyStr = [NSString stringWithFormat:@"evaluationCh%d", i];
        if ([elementName isEqualToString:keyStr]){
            evaluationCh[i] = [string intValue];
            count++;
        }
    }
}

- (void) didEndXmlElement:(NSString *)elementName
                   parser:(XmlParserWrapper *)xmlParser {
    
    if ([elementName isEqualToString:@"Drc"]){
        if (count != 20){
            xmlParser.error = [NSString stringWithFormat:
                               @"Drc. Import from xml is not success. " ];
            
        }
        //NSLog(@"%@", [self getInfo]);
        [xmlParser popDelegate];
    }
}


@end
