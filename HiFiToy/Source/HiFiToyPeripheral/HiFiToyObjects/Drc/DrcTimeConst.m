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
#import "IntegerUtility.h"

@interface DrcTimeConst(){
    int count;
}
@end

@implementation DrcTimeConst

/*==========================================================================================
 Init
 ==========================================================================================*/
- (id) init {
    self = [super init];
    if (self) {
        self.channel = DRC_CH_1_7;
        self.energyMS = 0.1f;
        self.attackMS = 10.0f;
        self.decayMS = 100.f;
    }
    return self;
}

/*---------------------- create methods -----------------------------*/
+ (DrcTimeConst *)initWithChannel:(DrcChannel_t)channel {
    DrcTimeConst * currentInstance = [[DrcTimeConst alloc] init];
    
    currentInstance.channel = channel;
    return currentInstance;
}

+ (DrcTimeConst *)initWithChannel:(DrcChannel_t)channel
                           Energy:(float)energyMS
                           Attack:(float)attackMS
                            Decay:(float)decayMS {
    DrcTimeConst * currentInstance = [[DrcTimeConst alloc] init];
    
    currentInstance.channel = channel;
    currentInstance.energyMS = energyMS;
    currentInstance.attackMS = attackMS;
    currentInstance.decayMS = decayMS;
    
    return currentInstance;
}

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
-(DrcTimeConst *)copyWithZone:(NSZone *)zone {
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
- (BOOL) isEqual: (id) object {
    if ( (object) && ([object class] == [self class]) ) {
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

//setters getters
- (void) setEnergyMS:(float)energyMS {
    if (energyMS < 0.05) {
        _energyMS = 0.05;
    } else if (energyMS < 0.1) {
        _energyMS = (int)(energyMS / 0.05) * 0.05;
    } else if (energyMS < 1) {
        _energyMS = (int)(energyMS / 0.1) * 0.1;
    } else if (energyMS < 10){
        _energyMS = (int)energyMS;
    } else {
        _energyMS = (int)(energyMS / 10) * 10;
    }
}

//time utilityies
- (uint32_t) timeToUint32:(float)time_ms {
    return (uint32_t)(pow(M_E, -2000.0f / time_ms / TAS5558_FS) * 0x800000) & 0x007FFFFF;
}

- (float) uint32ToTimeMS:(uint32_t)time {
    float t = (float)(reverseUint32(time) & 0x007FFFFF) / 0x800000;
    
    return (float)(-2000.0f / TAS5558_FS / log(t)); //log == ln
}

//HiFiToyObject protocol implements
- (uint8_t) address {
    if (self.channel == DRC_CH_8) {
        return DRC2_ENERGY_REG;
    }
    return DRC1_ENERGY_REG;
}

//info string
-(NSString *)getInfo {
    return [NSString stringWithFormat:@"Energy=%0.1f Attack=%0.1f Decay=%0.1f",
                                    self.energyMS, self.attackMS, self.decayMS];
}

- (NSString *) getEnergyDescription {
    if (_energyMS < 0.1) {
        return [NSString stringWithFormat:@"%dus", (int)(_energyMS * 1000)];
    } else if (_energyMS < 1) {
        return [NSString stringWithFormat:@"%0.1fms", _energyMS];
    }
    return [NSString stringWithFormat:@"%dms", (int)_energyMS];
}

//send to dsp
- (void) sendEnergyWithResponse:(BOOL)response {
    NSData *data = [[self getEnergyDataBuf] binary];
    Packet_t packet;
    memcpy(&packet, data.bytes, data.length);
    data = [NSData dataWithBytes:&packet length:sizeof(Packet_t)];
    
    //send data
    [[HiFiToyControl sharedInstance] sendDataToDsp:data withResponse:response];
}

- (void) sendAttackDecayWithResponse:(BOOL)response {
    NSData *data = [[self getAttackDecayDataBuf] binary];
    Packet_t packet;
    memcpy(&packet, data.bytes, data.length);
    data = [NSData dataWithBytes:&packet length:sizeof(Packet_t)];
    
    //send data
    [[HiFiToyControl sharedInstance] sendDataToDsp:data withResponse:response];
}

- (void) sendWithResponse:(BOOL)response {
    [self sendEnergyWithResponse:response];
    [self sendAttackDecayWithResponse:response];
}

- (HiFiToyDataBuf *) getEnergyDataBuf {
    uint32_t t = [self timeToUint32:self.energyMS];
    uint32_t data[2] = {reverseUint32(0x800000 - t), reverseUint32(t)};
    
    return [HiFiToyDataBuf dataBufWithAddr:self.address
                                withLength:8
                                  withData:(uint8_t *)data];
}

- (HiFiToyDataBuf *) getAttackDecayDataBuf {
    uint32_t attack     = [self timeToUint32:self.attackMS];
    uint32_t decay      = [self timeToUint32:self.decayMS];
    uint32_t data[4]    = {reverseUint32(0x800000 - attack), reverseUint32(attack),
                            reverseUint32(0x800000 - decay), reverseUint32(decay)};
    
    return [HiFiToyDataBuf dataBufWithAddr:(self.address + 4)
                                withLength:16
                                  withData:(uint8_t *)data];
}

- (NSArray<HiFiToyDataBuf *> *) getDataBufs {
    return @[[self getEnergyDataBuf], [self getAttackDecayDataBuf]];
}

- (BOOL) importData:(NSData *)data {
    int importCount = 0;
    
    HiFiToyPeripheral_t * HiFiToy = (HiFiToyPeripheral_t *) data.bytes;
    DataBufHeader_t * dataBufHeader = &HiFiToy->firstDataBuf;
    
    for (int i = 0; i < HiFiToy->dataBufLength; i++) {
        if ((dataBufHeader->addr == [self address]) && (dataBufHeader->length == 8)){
            
            uint32_t * number = (uint32_t *)((uint8_t *)dataBufHeader + sizeof(DataBufHeader_t));
            self.energyMS = [self uint32ToTimeMS:number[1]];
            
            importCount++;
            if (importCount >= 2) break;
        }
        if ((dataBufHeader->addr == ([self address] + 4)) && (dataBufHeader->length == 16)){
            
            uint32_t * number = (uint32_t *)((uint8_t *)dataBufHeader + sizeof(DataBufHeader_t));
            self.attackMS = [self uint32ToTimeMS:number[1]];
            self.decayMS = [self uint32ToTimeMS:number[3]];
            
            importCount++;
            if (importCount >= 2) break;
        }
        dataBufHeader = (DataBufHeader_t *)((uint8_t *)dataBufHeader + sizeof(DataBufHeader_t) + dataBufHeader->length);
    }
    
    if (importCount == 2) {
        return YES;
    }
    
    return NO;
}

/*---------------------------- XML export/import ----------------------------------*/
-(XmlData *) toXmlData {
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
