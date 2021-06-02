//
//  BassTreble.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 30/05/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "BassTreble.h"
#import "TAS5558.h"
#import "Number523.h"
#import "HiFiToyControl.h"


@interface BassTreble(){
    int count;
}
@end

@implementation BassTreble

/*==========================================================================================
 Init
 ==========================================================================================*/
- (id) init {
    self = [super init];
    if (self){
        memset(enabledCh, 0, 8); //all channels are disabled (DRY)

        self.bassTreble127 = [BassTrebleChannel initWithChannel:BASS_TREBLE_CH_127
                                                       BassFreq:BASS_FREQ_125 BassDb:0
                                                     TrebleFreq:TREBLE_FREQ_9000 TrebleDb:0
                                                      maxBassDb:12 minBassDb:-12 maxTrebleDb:12 minTrebleDb:-12];
        self.bassTreble34 = [BassTrebleChannel initWithChannel:BASS_TREBLE_CH_34];
        self.bassTreble56 = [BassTrebleChannel initWithChannel:BASS_TREBLE_CH_56];
        self.bassTreble8 = [BassTrebleChannel initWithChannel:BASS_TREBLE_CH_8];
    }
    
    return self;
}

/*---------------------- create methods -----------------------------*/
+ (BassTreble *)initWithBassTreble127:(BassTrebleChannel *)bassTreble127
                         BassTreble34:(BassTrebleChannel *)bassTreble34
                         BassTreble56:(BassTrebleChannel *)bassTreble56
                          BassTreble8:(BassTrebleChannel *)bassTreble8 {
    BassTreble *currentInstance = [[BassTreble alloc] init];
    
    if (bassTreble127) currentInstance.bassTreble127 = bassTreble127;
    if (bassTreble34) currentInstance.bassTreble34 = bassTreble34;
    if (bassTreble56) currentInstance.bassTreble56 = bassTreble56;
    if (bassTreble8) currentInstance.bassTreble8 = bassTreble8;
    
    return  currentInstance;
}

+ (BassTreble *)initWithBassTreble127:(BassTrebleChannel *)bassTreble127 {
    BassTreble *currentInstance = [[BassTreble alloc] init];
    
    if (bassTreble127) currentInstance.bassTreble127 = bassTreble127;
    return  currentInstance;
}

/*==========================================================================================
 NSCoding protocol implementation
 ==========================================================================================*/
- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.bassTreble127 forKey:@"keyBassTreble127"];
    [encoder encodeObject:self.bassTreble34 forKey:@"keyBassTreble34"];
    [encoder encodeObject:self.bassTreble56 forKey:@"keyBassTreble56"];
    [encoder encodeObject:self.bassTreble8 forKey:@"keyBassTreble8"];
    
    for (int i = 0; i < 8; i++) {
        NSString * keyStr = [NSString stringWithFormat:@"keyEnabledCh%d", i];
        [encoder encodeFloat:enabledCh[i] forKey:keyStr];
    }
    
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.bassTreble127 = [decoder decodeObjectForKey:@"keyBassTreble127"];
        self.bassTreble34 = [decoder decodeObjectForKey:@"keyBassTreble34"];
        self.bassTreble56 = [decoder decodeObjectForKey:@"keyBassTreble56"];
        self.bassTreble8 = [decoder decodeObjectForKey:@"keyBassTreble8"];
        
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
-(BassTreble *)copyWithZone:(NSZone *)zone {
    BassTreble * copyBassTreble = [[[self class] allocWithZone:zone] init];
    
    copyBassTreble.bassTreble127    = [self.bassTreble127 copy];
    copyBassTreble.bassTreble34     = [self.bassTreble34 copy];
    copyBassTreble.bassTreble56     = [self.bassTreble56 copy];
    copyBassTreble.bassTreble8      = [self.bassTreble8 copy];
    
    for (int i = 0; i < 8; i++){
        [copyBassTreble setEnabledChannel:i Enabled:enabledCh[i]];
    }
    
    return copyBassTreble;
}

/*==========================================================================================
 isEqual implementation
 ==========================================================================================*/
- (BOOL) isEqual: (id) object {
    if ([object class] == [self class]){
        BassTreble * temp = object;
        
        if (self.bassTreble127) {
            if ((!temp.bassTreble127) || (![self.bassTreble127 isEqual:temp.bassTreble127])){
                return NO;
            }
        } else if (temp.bassTreble127) {
                return NO;
        }
        
        if (self.bassTreble34) {
            if ((!temp.bassTreble34) || (![self.bassTreble34 isEqual:temp.bassTreble34])){
                return NO;
            }
        } else if (temp.bassTreble34) {
            return NO;
        }
        
        if (self.bassTreble56) {
            if ((!temp.bassTreble56) || (![self.bassTreble56 isEqual:temp.bassTreble56])){
                return NO;
            }
        } else if (temp.bassTreble56) {
            return NO;
        }
        
        if (self.bassTreble8) {
            if ((!temp.bassTreble8) || (![self.bassTreble8 isEqual:temp.bassTreble8])){
                return NO;
            }
        } else if (temp.bassTreble8) {
            return NO;
        }
        
        for (int i = 0; i < 8; i++){
            if (fabs(enabledCh[i] - [temp getEnabledChannel:i]) > 0.02f) {
                return NO;
            }
        }
        
    }
    
    return YES;
}

- (uint8_t)address {
    return BASS_FILTER_SET_REG;
}

//enabled = 0.0 .. 1.0
-(void) setEnabledChannel:(uint8_t)channel Enabled:(float)enabled {
    if (channel > 7) channel = 7;
    
    if (enabled < 0.0) enabled = 0.0;
    if (enabled > 1.0) enabled = 1.0;
    
    enabledCh[channel] = enabled;
}

//return enabled = 0.0 .. 1.0
-(float) getEnabledChannel:(uint8_t)channel {
    if (channel > 7) channel = 7;
    return enabledCh[channel];
}

//info string
-(NSString *)getInfo {
    return @"BassTreble";
}

//send to dsp
- (void) sendWithResponse:(BOOL)response {
    NSData *data = [[self getFreqDbDataBuf] binary];
    Packet_t packet;
    memcpy(&packet, data.bytes, data.length);
    
    //send data
    [[HiFiToyControl sharedInstance] sendPacketToDsp:&packet withResponse:response];
}

- (void) sendEnabledWithChannel:(uint8_t)channel withResponse:(BOOL)response {
    NSData *data = [[self getEnabledDataBufWithChannel:channel] binary];
    Packet_t packet;
    memcpy(&packet, data.bytes, data.length);
    
    //send data
    [[HiFiToyControl sharedInstance] sendPacketToDsp:&packet withResponse:response];
}

-(uint8_t) dbToTAS5558Format:(int) db {
    return 18 - db;
}

-(int) TAS5558ToDbFormat:(uint8_t) tas5558_db {
    return 18 - tas5558_db;
}

- (HiFiToyDataBuf *) getFreqDbDataBuf {
    //fill bass selection
    uint8_t valBassFreq[4] = {  _bassTreble8.bassFreq, _bassTreble56.bassFreq,
                                _bassTreble34.bassFreq, _bassTreble127.bassFreq};
    
    //fill bass db, BASS_FILTER_INDEX_REG
    uint8_t valBassDb[4] = {[self dbToTAS5558Format:_bassTreble8.bassDb],
                            [self dbToTAS5558Format:_bassTreble56.bassDb],
                            [self dbToTAS5558Format:_bassTreble34.bassDb],
                            [self dbToTAS5558Format:_bassTreble127.bassDb]};
    
    //fill treble selection, TREBLE_FILTER_SET_REG
    uint8_t valTrebleFreq[4] = {    _bassTreble8.trebleFreq, _bassTreble56.trebleFreq,
                                    _bassTreble34.trebleFreq, _bassTreble127.trebleFreq};
    
    //fill treble db, TREBLE_FILTER_INDEX_REG
    uint8_t valTrebleDb[4] = {  [self dbToTAS5558Format:_bassTreble8.trebleDb],
                                [self dbToTAS5558Format:_bassTreble56.trebleDb],
                                [self dbToTAS5558Format:_bassTreble34.trebleDb],
                                [self dbToTAS5558Format:_bassTreble127.trebleDb]};
    
    uint8_t data[16];
    memcpy(data + 0, valBassFreq, 4);
    memcpy(data + 4, valBassDb, 4);
    memcpy(data + 8, valTrebleFreq, 4);
    memcpy(data + 12, valTrebleDb, 4);
    
    return [HiFiToyDataBuf dataBufWithAddr:self.address
                                withLength:16 withData:data];
}

- (HiFiToyDataBuf *) getEnabledDataBufWithChannel:(uint8_t)channel {
    uint32_t val = reverseNumber523(0x800000 * enabledCh[channel]);
    uint32_t ival = reverseNumber523(0x800000 - 0x800000 * enabledCh[channel]);
    
    uint8_t data[8];
    memcpy(data + 0, &ival, 4);
    memcpy(data + 4, &val, 4);
    
    return [HiFiToyDataBuf dataBufWithAddr:(BASS_TREBLE_REG + channel)
                                withLength:8 withData:data];
}

- (NSArray<HiFiToyDataBuf *> *) getDataBufs {
    NSMutableArray<HiFiToyDataBuf *> * dataBufs = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < 8; i++) {
        [dataBufs addObject:[self getEnabledDataBufWithChannel:i]];
    }
    
    [dataBufs addObject:[self getFreqDbDataBuf]];
    
    return dataBufs;
}

- (BOOL) importFromDataBufs:(NSArray<HiFiToyDataBuf *> *)dataBufs {
    BOOL importFlag = NO;

    for (HiFiToyDataBuf * db in dataBufs) {
        if ((db.addr == BASS_FILTER_SET_REG) && (db.length == 16)){
            uint8_t * buf = (uint8_t *)db.data.bytes;
            
            _bassTreble8.bassFreq = buf[0];
            _bassTreble56.bassFreq = buf[1];
            _bassTreble34.bassFreq = buf[2];
            _bassTreble127.bassFreq = buf[3];
            
            _bassTreble8.bassDb = [self TAS5558ToDbFormat:buf[4]];
            _bassTreble56.bassDb = [self TAS5558ToDbFormat:buf[5]];
            _bassTreble34.bassDb = [self TAS5558ToDbFormat:buf[6]];
            _bassTreble127.bassDb = [self TAS5558ToDbFormat:buf[7]];
            
            _bassTreble8.trebleFreq = buf[8];
            _bassTreble56.trebleFreq = buf[9];
            _bassTreble34.trebleFreq = buf[10];
            _bassTreble127.trebleFreq = buf[11];
            
            _bassTreble8.trebleDb = [self TAS5558ToDbFormat:buf[12]];
            _bassTreble56.trebleDb = [self TAS5558ToDbFormat:buf[13]];
            _bassTreble34.trebleDb = [self TAS5558ToDbFormat:buf[14]];
            _bassTreble127.trebleDb = [self TAS5558ToDbFormat:buf[15]];
            
            importFlag = YES;
        }
        
        if ((db.addr >= BASS_TREBLE_REG) && (db.addr < LOUDNESS_LOG2_GAIN_REG) &&
                                                        (db.length == 8)){
        
            int32_t * e = (int32_t *)db.data.bytes;
            
            enabledCh[db.addr - BASS_TREBLE_REG] = (float)reverseNumber523(e[1]) / 0x800000;
        }
    }
    
    return importFlag;
}

/*---------------------------- XML export/import ----------------------------------*/
-(XmlData *) toXmlData {
    XmlData * xmlData = [[XmlData alloc] init];
    
    for (int i = 0; i < 8; i++){
        NSString * keyStr = [NSString stringWithFormat:@"enabledCh%d", i];
        [xmlData addElementWithName:keyStr withDoubleValue:enabledCh[i]];
        
    }
    [xmlData addXmlData:[_bassTreble127 toXmlData]];
    [xmlData addXmlData:[_bassTreble34 toXmlData]];
    [xmlData addXmlData:[_bassTreble56 toXmlData]];
    [xmlData addXmlData:[_bassTreble8 toXmlData]];
    
    XmlData * bassTrebleXmlData = [[XmlData alloc] init];
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                           [[NSNumber numberWithInt:self.address] stringValue], @"Address", nil];
    
    [bassTrebleXmlData addElementWithName:@"BassTreble" withXmlValue:xmlData withAttrib:dict];
    
    return bassTrebleXmlData;
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
    BassTrebleCh_t channel = [channelStr intValue];
    
    if (self.bassTreble127.channel == channel) {
        [self.bassTreble127 importFromXml:xmlParser withAttrib:attributeDict];
        count++;
    }
    if (self.bassTreble34.channel == channel) {
        [self.bassTreble34 importFromXml:xmlParser withAttrib:attributeDict];
        count++;
    }
    if (self.bassTreble56.channel == channel) {
        [self.bassTreble56 importFromXml:xmlParser withAttrib:attributeDict];
        count++;
    }
    if (self.bassTreble8.channel == channel) {
        [self.bassTreble8 importFromXml:xmlParser withAttrib:attributeDict];
        count++;
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
}

- (void) didEndXmlElement:(NSString *)elementName
                   parser:(XmlParserWrapper *)xmlParser {
    
    if ([elementName isEqualToString:@"BassTreble"]){
        if (count != 12){
            xmlParser.error = [NSString stringWithFormat:
                               @"BassTreble. Import from xml is not success. " ];
            
        }
        //NSLog(@"%@", [self getInfo]);
        [xmlParser popDelegate];
    }
}

@end



