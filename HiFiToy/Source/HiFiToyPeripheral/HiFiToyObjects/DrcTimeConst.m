//
//  DrcTimeConst.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 04/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "DrcTimeConst.h"
#import "TAS5558.h"
#import "HiFiToyControl.h"

uint32_t reverseUint32(uint32_t num) {
    uint32_t result;
    uint8_t * pSrc = (uint8_t *)&num;
    uint8_t * pDest = (uint8_t *)&result;
    
    pDest[0] = pSrc[3];
    pDest[1] = pSrc[2];
    pDest[2] = pSrc[1];
    pDest[3] = pSrc[0];
    
    return result;
}

static uint32_t timeToUint32(float time_ms) {
    return (uint32_t)(pow(M_E, -2000.0f / time_ms / TAS5558_FS) * 0x800000) & 0x007FFFFF;
}

static float uint32ToTimeMS(uint32_t time) {
    float t = (float)(reverseUint32(time) & 0x007FFFFF) / 0x800000;
    
    return (float)(-2000.0f / TAS5558_FS / log(t)); //log == ln
}

@interface DrcTimeConst(){
    int count;
}
@end

@implementation DrcTimeConst

/*==========================================================================================
 NSCoding protocol implementation
 ==========================================================================================*/
- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:self.channel forKey:@"keyChannel"];
    [encoder encodeFloat:self.energyMS forKey:@"keyEnergy"];
    [encoder encodeFloat:self.attackMS forKey:@"keyAttack"];
    [encoder encodeFloat:self.decayMS forKey:@"keyDecay"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.channel    = [decoder decodeIntForKey:@"keyChannel"];
        self.energyMS   = [decoder decodeFloatForKey:@"keyEnergy"];
        self.attackMS   = [decoder decodeFloatForKey:@"keyAttack"];
        self.decayMS    = [decoder decodeFloatForKey:@"keyDecay"];
    }
    return self;
}

/*==========================================================================================
 NSCopying protocol implementation
 ==========================================================================================*/
-(DrcTimeConst *)copyWithZone:(NSZone *)zone
{
    DrcTimeConst * copyDrcTimeConst = [[[self class] allocWithZone:zone] init];
    
    copyDrcTimeConst.channel    = self.channel;
    copyDrcTimeConst.energyMS   = self.energyMS;
    copyDrcTimeConst.attackMS   = self.attackMS;
    copyDrcTimeConst.decayMS    = self.decayMS;
    
    return copyDrcTimeConst;
}

/*==========================================================================================
 isEqual implementation
 ==========================================================================================*/
- (BOOL) isEqual: (id) object
{
    if ([object class] == [self class]){
        DrcTimeConst * temp = object;
        if ((self.channel == temp.channel) &&
            (fabs(self.energyMS - temp.energyMS) < 0.02f) &&
            (fabs(self.attackMS - temp.attackMS) < 0.02f) &&
            (fabs(self.decayMS - temp.decayMS) < 0.02f)){
            
            return YES;
        }
        
    }
    
    return NO;
}

/*---------------------- create methods -----------------------------*/
+ (DrcTimeConst *)initWithChannel:(DrcChannel_t)channel
                           Energy:(float)energyMS
                           Attack:(float)attackMS
                            Decay:(float)decayMS
{
    DrcTimeConst * currentInstance = [[DrcTimeConst alloc] init];
    
    currentInstance.channel = channel;
    currentInstance.energyMS = energyMS;
    currentInstance.attackMS = attackMS;
    currentInstance.decayMS = decayMS;
    
    return currentInstance;
}

- (uint8_t) address {
    if (self.channel == DRC_CH_8) {
        return DRC2_ENERGY_REG;
    }
    return DRC1_ENERGY_REG;
}

//info string
-(NSString *)getInfo
{
    return [NSString stringWithFormat:@"Energy=%0.1f Attack=%0.1f Decay=%0.1f",
                                    self.energyMS, self.attackMS, self.decayMS];
}

//send to dsp
- (void) sendEnergyWithResponse:(BOOL)response
{
    NSData *data = [self getEnergyBinary];
    
    //send data
    [[HiFiToyControl sharedInstance] sendDataToDsp:data withResponse:response];
}

- (void) sendAttackDecayWithResponse:(BOOL)response
{
    NSData *data = [self getAttackDecayBinary];
    
    //send data
    [[HiFiToyControl sharedInstance] sendDataToDsp:data withResponse:response];
}

- (void) sendWithResponse:(BOOL)response
{
    [self sendEnergyWithResponse:response];
    [self sendAttackDecayWithResponse:response];
}

- (NSData *) getEnergyBinary
{
    DataBufHeader_t dataBufHeader;
    dataBufHeader.addr = [self address];
    dataBufHeader.length = 8;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendBytes:&dataBufHeader length:sizeof(DataBufHeader_t)];
    
    uint32_t t = timeToUint32(self.energyMS);
    uint32_t d[2] = {reverseUint32(0x800000 - t), reverseUint32(t)};
    [data appendBytes:d length:8];
    
    return data;
}

- (NSData *) getAttackDecayBinary
{
    DataBufHeader_t dataBufHeader;
    dataBufHeader.addr = [self address] + 4; //DRCx_ATTACK_DECAY_REG
    dataBufHeader.length = 16;
    
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendBytes:&dataBufHeader length:sizeof(DataBufHeader_t)];
    
    uint32_t attack = timeToUint32(self.attackMS);
    uint32_t decay = timeToUint32(self.decayMS);
    uint32_t d[4] = {reverseUint32(0x800000 - attack), reverseUint32(attack),
                        reverseUint32(0x800000 - decay), reverseUint32(decay)};
    [data appendBytes:d length:16];
    
    return data;
}

//get binary for save to dsp
- (NSData *) getBinary
{
    NSMutableData *data = [[NSMutableData alloc] init];
    [data appendData:[self getEnergyBinary]];
    [data appendData:[self getAttackDecayBinary]];
    
    return data;
}

- (BOOL) importData:(NSData *)data
{
    int importCount = 0;
    
    HiFiToyPeripheral_t * HiFiToy = (HiFiToyPeripheral_t *) data.bytes;
    DataBufHeader_t * dataBufHeader = &HiFiToy->firstDataBuf;
    
    for (int i = 0; i < HiFiToy->dataBufLength; i++) {
        if ((dataBufHeader->addr == [self address]) && (dataBufHeader->length == 8)){
            
            uint32_t * number = (uint32_t *)((uint8_t *)dataBufHeader + sizeof(DataBufHeader_t));
            self.energyMS = uint32ToTimeMS(number[1]);
            
            importCount++;
            if (importCount >= 2) break;
        }
        if ((dataBufHeader->addr == ([self address] + 4)) && (dataBufHeader->length == 16)){
            
            uint32_t * number = (uint32_t *)((uint8_t *)dataBufHeader + sizeof(DataBufHeader_t));
            self.attackMS = uint32ToTimeMS(number[1]);
            self.decayMS = uint32ToTimeMS(number[3]);
            
            importCount++;
            if (importCount >= 2) break;
        }
        dataBufHeader += sizeof(DataBufHeader_t) + dataBufHeader->length;
    }
    
    if (importCount == 2) {
        return YES;
    }
    
    return NO;
}

/*---------------------------- XML export/import ----------------------------------*/
-(XmlData *) toXmlData{
    XmlData * xmlData = [[XmlData alloc] init];
    [xmlData addElementWithName:@"Energy" withDoubleValue:self.energyMS];
    [xmlData addElementWithName:@"Attack" withDoubleValue:self.attackMS];
    [xmlData addElementWithName:@"Decay" withDoubleValue:self.decayMS];
    
    
    XmlData * drcTimeConstXmlData = [[XmlData alloc] init];
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                           [[NSNumber numberWithInt:self.channel] stringValue], @"Channel", nil];
    
    [drcTimeConstXmlData addElementWithName:@"DrcTimeConst" withXmlValue:xmlData withAttrib:dict];
    
    return drcTimeConstXmlData;
    
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
    
    if ([elementName isEqualToString:@"Energy"]){
        self.energyMS = [string floatValue];
        count++;
    }
    if ([elementName isEqualToString:@"Attack"]){
        self.attackMS = [string floatValue];
        count++;
    }
    if ([elementName isEqualToString:@"Decay"]){
        self.decayMS = [string floatValue];
        count++;
    }
}

- (void) didEndXmlElement:(NSString *)elementName
                   parser:(XmlParserWrapper *)xmlParser {
    
    if ([elementName isEqualToString:@"DrcTimeConst"]){
        if (count != 3){
            xmlParser.error = [NSString stringWithFormat:
                               @"DrcTimeConst=%@. Import from xml is not success. ",
                               [[NSNumber numberWithInt:self.channel] stringValue] ];
        }
        //NSLog(@"%@", [self getInfo]);
        [xmlParser popDelegate];
    }
}


@end
