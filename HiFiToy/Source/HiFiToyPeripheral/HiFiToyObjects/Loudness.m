//
//  Loudness.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 30/05/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "Loudness.h"
#import "TAS5558.h"
#import "Number923.h"
#import "Number523.h"
#import "HiFiToyControl.h"
#import "FloatUtility.h"

@interface Loudness(){
    int count;
}
@end

@implementation Loudness

/*==========================================================================================
 Init
 ==========================================================================================*/
- (id) init {
    self = [super init];
    if (self){
        _LG = -0.5;
        _LO = 0;
        _gain = 0;
        _offset = 0;
        
        _biquad = [Biquad initWithAddress:LOUDNESS_BIQUAD_REG];
        _biquad.type = BIQUAD_BANDPASS;
        
        [_biquad.biquadParam setBorderMaxFreq:200 minFreq:30];
        _biquad.biquadParam.freq = 60;
        _biquad.biquadParam.qFac = 0;
        _biquad.biquadParam.dbVolume = 0;
    }
    
    return self;
}

+ (Loudness *)initWithOrder:(Biquad *)biquad LG:(float)LG LO:(float)LO
                       Gain:(float)gain Offset:(float)offset {
    Loudness *currentInstance = [[Loudness alloc] init];
    
    currentInstance.biquad = biquad;
    currentInstance.LG = LG;
    currentInstance.LO = LO;
    currentInstance.gain = gain;
    currentInstance.offset = offset;
    
    return currentInstance;
}

/*==========================================================================================
 NSCoding protocol implementation
 ==========================================================================================*/
- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.biquad forKey:@"keyBiquad"];
    [encoder encodeFloat:self.LG forKey:@"keyLG"];
    [encoder encodeFloat:self.LO forKey:@"keyLO"];
    [encoder encodeFloat:self.gain forKey:@"keyGain"];
    [encoder encodeFloat:self.offset forKey:@"keyOffset"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.biquad = [decoder decodeObjectForKey:@"keyBiquad"];
        self.LG = [decoder decodeFloatForKey:@"keyLG"];
        self.LO = [decoder decodeFloatForKey:@"keyLO"];
        self.gain = [decoder decodeFloatForKey:@"keyGain"];
        self.offset = [decoder decodeFloatForKey:@"keyOffset"];
    }
    return self;
}

/*==========================================================================================
 NSCopying protocol implementation
 ==========================================================================================*/
-(Loudness *)copyWithZone:(NSZone *)zone {
    Loudness * copyLoudness= [[[self class] allocWithZone:zone] init];
    
    //copyFilter.numberBiquads = self.numberBiquads;
    copyLoudness.biquad = [self.biquad copy];
    copyLoudness.LG = self.LG;
    copyLoudness.LO = self.LO;
    copyLoudness.gain = self.gain;
    copyLoudness.offset = self.offset;
    
    return copyLoudness;
}

/*==========================================================================================
 isEqual implementation
 ==========================================================================================*/
- (BOOL) isEqual: (id) object {
    if ([object class] == [self class]){
        Loudness * temp = object;
        
        if ((![self.biquad isEqual:temp.biquad]) ||
            (!isFloatDiffLessThan(self.LG, temp.LG, 0.02f)) ||
            (!isFloatDiffLessThan(self.LO, temp.LO, 0.02f)) ||
            (!isFloatDiffLessThan(self.gain, temp.gain, 0.02f)) ||
            (!isFloatDiffLessThan(self.offset, temp.offset, 0.02f)) ) {
            
            return NO;
        }
        
        return YES;
    }
    return NO;
}

- (uint8_t) address {
    return LOUDNESS_LOG2_GAIN_REG;
}

//info string
-(NSString *)getFreqInfo {
    return [NSString stringWithFormat:@"%dHz", _biquad.biquadParam.freq];
}

-(NSString *)getInfo {
    return [NSString stringWithFormat:@"%d%%", (int)(self.gain * 100)];
}

//send to dsp
- (void) sendWithResponse:(BOOL)response {
    NSData * data = [[self getMainDataBuf] binary];
    Packet_t packet;
    memcpy(&packet, data.bytes, data.length);
    
    //send data
    [[HiFiToyControl sharedInstance] sendPacketToDsp:&packet withResponse:response];
}

- (HiFiToyDataBuf *) getMainDataBuf {
    Number923_t number[4] = {to523Reverse(_LG), to923Reverse(_LO),
                                to523Reverse(_gain), to923Reverse(_offset)};
    
    return [HiFiToyDataBuf dataBufWithAddr:self.address
                                withLength:16
                                  withData:(uint8_t *)number];
}

- (NSArray<HiFiToyDataBuf *> *) getDataBufs {
    NSMutableArray<HiFiToyDataBuf *> * dataBufs = [[NSMutableArray alloc] init];
    [dataBufs addObject:[self getMainDataBuf]];
    [dataBufs addObjectsFromArray:[self.biquad getDataBufs]];
    
    return dataBufs;
}

- (BOOL) importData:(NSData *)data {
    if ([self.biquad importData:data] == NO){
        return NO;
    }
    
    HiFiToyPeripheral_t * HiFiToy = (HiFiToyPeripheral_t *) data.bytes;
    DataBufHeader_t * dataBufHeader = &HiFiToy->firstDataBuf;
    
    for (int i = 0; i < HiFiToy->dataBufLength; i++) {
        if ((dataBufHeader->addr == [self address]) && (dataBufHeader->length == 16)){
            
            int32_t * number = (int32_t *)((uint8_t *)dataBufHeader + sizeof(DataBufHeader_t));
            self.LG     = _523toFloat(reverseNumber523(number[0]));
            self.LO     = _923toFloat(reverseNumber923(number[1]));
            self.gain   = _523toFloat(reverseNumber523(number[2]));
            self.offset = _923toFloat(reverseNumber923(number[3]));
            
            NSLog(@"import loudness");
            return YES;
        }
        dataBufHeader = (DataBufHeader_t *)((uint8_t *)dataBufHeader + sizeof(DataBufHeader_t) + dataBufHeader->length);
    }
    
    return NO;
}

/*---------------------------- XML export/import ----------------------------------*/
-(XmlData *) toXmlData {
    XmlData * xmlData = [[XmlData alloc] init];
    [xmlData addElementWithName:@"LG" withDoubleValue:self.LG];
    [xmlData addElementWithName:@"LO" withDoubleValue:self.LO];
    [xmlData addElementWithName:@"Gain" withDoubleValue:self.gain];
    [xmlData addElementWithName:@"Offset" withDoubleValue:self.offset];
    
    [xmlData addXmlData:[_biquad toXmlData]];

    XmlData * loudnessXmlData = [[XmlData alloc] init];
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                           [[NSNumber numberWithInt:self.address] stringValue], @"Address", nil];
    
    [loudnessXmlData addElementWithName:@"Loudness" withXmlValue:xmlData withAttrib:dict];
    
    return loudnessXmlData;
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
    
    if ([self.biquad address] == addr){
        [self.biquad importFromXml:xmlParser withAttrib:attributeDict];
        count++;
    }
}

- (void) didFoundXmlCharacters:(NSString *)string
                    forElement:(NSString *)elementName
                        parser:(XmlParserWrapper *)xmlParser {
    if ([elementName isEqualToString:@"LG"]){
        self.LG = [string doubleValue];
        count++;
    }
    if ([elementName isEqualToString:@"LO"]){
        self.LO = [string doubleValue];
        count++;
    }
    if ([elementName isEqualToString:@"Gain"]){
        self.gain = [string doubleValue];
        count++;
    }
    if ([elementName isEqualToString:@"Offset"]){
        self.offset = [string doubleValue];
        count++;
    }
}

- (void) didEndXmlElement:(NSString *)elementName
                   parser:(XmlParserWrapper *)xmlParser {
    
    if ([elementName isEqualToString:@"Loudness"]){

        if (count != 5){
            xmlParser.error = [NSString stringWithFormat:
                               @"Loudness. Import from xml is not success. " ];
            
        }
        NSLog(@"%@", [self getInfo]);
        [xmlParser popDelegate];
    }
}

@end
