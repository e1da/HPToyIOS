//
//  HiFiToyPreset.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 04/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "HiFiToyPreset.h"
#import "HiFiToyPresetList.h"
#import "HiFiToyControl.h"
#import "DialogSystem.h"
#import "PeripheralData.h"


@interface HiFiToyPreset() {
    XmlParserWrapper * xmlParser;
    int count;
    
    void (^xmlImportResultHandler)(HiFiToyPreset * preset, NSString * error);
    
}

@end

@implementation HiFiToyPreset

- (id) init {
    self = [super init];
    if (self) {
        [self setDefault];
    }
    return self;
}

+ (HiFiToyPreset *) getDefault {
    return [[HiFiToyPreset alloc] init];
}

- (NSArray<id<HiFiToyObject>> *) characteristics {
    return @[_filters, _masterVolume, _bassTreble, _loudness, _drc];
}

//NSCoding protocol implementation
- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.presetName forKey:@"presetName"];
    [encoder encodeInt64:self.checkSum forKey:@"checkSum"];
    
    //Characteristics
    [encoder encodeObject:self.filters forKey:@"Filters"];
    [encoder encodeObject:self.masterVolume forKey:@"MasterVolume"];
    [encoder encodeObject:self.bassTreble forKey:@"BassTreble"];
    [encoder encodeObject:self.loudness forKey:@"Loudness"];
    [encoder encodeObject:self.drc forKey:@"Drc"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [self init];
    if (self) {
        self.presetName = [decoder decodeObjectForKey:@"presetName"];
        self.checkSum = [decoder decodeInt64ForKey:@"checkSum"];
        
        //Characteristics
        self.filters = [decoder decodeObjectForKey:@"Filters"];
        self.masterVolume = [decoder decodeObjectForKey:@"MasterVolume"];
        self.bassTreble = [decoder decodeObjectForKey:@"BassTreble"];
        self.loudness = [decoder decodeObjectForKey:@"Loudness"];
        self.drc = [decoder decodeObjectForKey:@"Drc"];
    }
    return self;
}


//NSCopying protocol implementation
-(HiFiToyPreset *)copyWithZone:(NSZone *)zone {
    HiFiToyPreset * copyPreset = [[[self class] allocWithZone:zone] init];
    
    //NSLog(@"%lu", (unsigned long)copyPreset.characteristics.count);
    
    copyPreset.presetName = [self.presetName copy];
    copyPreset.checkSum = self.checkSum;
    
    copyPreset.filters = [self.filters copy];
    copyPreset.masterVolume = [self.masterVolume copy];
    copyPreset.bassTreble = [self.bassTreble copy];
    copyPreset.loudness = [self.loudness copy];
    copyPreset.drc = [self.drc copy];
    
    return copyPreset;
}

//isEqual implementation
- (BOOL) isEqual: (id) object {
    if ([object class] == [self class]){
        HiFiToyPreset * temp = object;
        
        if (([self.filters isEqual:temp.filters] == NO) ||
            ([self.masterVolume isEqual:temp.masterVolume] == NO) ||
            ([self.bassTreble isEqual:temp.bassTreble] == NO) ||
            ([self.loudness isEqual:temp.loudness] == NO) ||
            ([self.drc isEqual:temp.drc] == NO)) {
            
            return NO;
        }
        
        return YES;
    }
    return NO;
}

//creation method
- (void) setDefault {
    self.presetName = @"No processing";
    
    //Filters
    self.filters = [Filters initDefaultWithAddr0:BIQUAD_FILTER_REG withAddr1:(BIQUAD_FILTER_REG + 7)];
    
    
    //Master Volume
    self.masterVolume = [Volume initWithAddress:MASTER_VOLUME_REG dbValue:0.0 maxDb:0.0 minDb:MUTE_VOLUME];
    
    //Bass Treble
    BassTrebleChannel * bassTreble12 = [BassTrebleChannel initWithChannel:BASS_TREBLE_CH_127
                                                                 BassFreq:BASS_FREQ_125 BassDb:0
                                                               TrebleFreq:TREBLE_FREQ_9000 TrebleDb:0
                                                                maxBassDb:12 minBassDb:-12
                                                              maxTrebleDb:12 minTrebleDb:-12];
    self.bassTreble = [BassTreble initWithBassTreble127:bassTreble12];
    
    [self.bassTreble setEnabledChannel:0 Enabled:1.0];
    [self.bassTreble setEnabledChannel:1 Enabled:1.0];
    
    //Loudness: LG = -0.5, LO = Gain = Offset = 0, Biquad=(BANDPASS, 140Hz = (30..200Hz))
    self.loudness = [[Loudness alloc] init];
    
    //Drc
    self.drc = [[Drc alloc] init];
    [self.drc setEvaluation:POST_VOLUME_EVAL forChannel:0];
    [self.drc setEvaluation:POST_VOLUME_EVAL forChannel:1];
    [self.drc setEnabled:0.0 forChannel:0];
    [self.drc setEnabled:0.0 forChannel:1];
    
    [self updateChecksum];
}

- (uint8_t)address {
    return 0;
}

- (BOOL)rename:(NSString *)newName {
    if ([self.presetName isEqualToString:newName]){
        return NO;
    }
    
    if ([[HiFiToyPresetList sharedInstance] isPresetExist:newName]){
        [[DialogSystem sharedInstance] showAlert:NSLocalizedString(@"Preset is not renamed! Because preset with the same name does exists!", @"")];

        return NO;
    }
    
    NSString * tempName = self.presetName;
    self.presetName = [newName copy];
    
    [[HiFiToyPresetList sharedInstance] setPreset:self];
    [[HiFiToyPresetList sharedInstance] removePresetWithName:tempName];
    
    
    return YES;
}

//send preset to HiFiToyPeripheral, response always YES
- (void) sendWithResponse:(BOOL)response {
    if (![[HiFiToyControl sharedInstance] isConnected]) return;
    
    //init progress dialog
    [[DialogSystem sharedInstance] showProgressDialog:NSLocalizedString(@"Send Dsp Parameters...", @"")];
    
    //send all dspCharacteristics to dsp
    for (int i = 0; i < self.characteristics.count; i++){
        [[self.characteristics objectAtIndex:i] sendWithResponse:YES];
    }
    
}

-(NSString *)getInfo {
    return self.presetName;
}

- (NSArray<HiFiToyDataBuf *> *) getDataBufs {
    NSMutableArray<HiFiToyDataBuf *> * dataBufs = [[NSMutableArray alloc] init];
    
    //get binary of all dspCharacteristics
    for (int i = 0; i < self.characteristics.count; i++){
        [dataBufs addObjectsFromArray:[self.characteristics[i] getDataBufs]];
    }
    return dataBufs;
}

- (NSData *) getBinary {
    NSArray<HiFiToyDataBuf *> * dataBufs = [self getDataBufs];
    NSMutableData * data = [[NSMutableData alloc] init];
    
    for (HiFiToyDataBuf * db in dataBufs) {
        [data appendData:[db binary]];
    }
    
    return data;
}

//store and import to/from peripheral
- (void) storeToPeripheral {
    PeripheralData * pd = [[PeripheralData alloc] initWithPreset:self];
    [pd exportPresetWithDialog:NSLocalizedString(@"Sending Preset", @"")];
}

- (void) importFromPeripheral {
    PeripheralData * pd = [[PeripheralData alloc] init];
    [pd importWithDialog:NSLocalizedString(@"Import Preset...", @"")
                 handler:^() {
        
        if ([self importFromDataBufs:pd.dataBufs]){
            //update checksum preset
            [self updateChecksumWithParamData:[pd getDataBufBinary]];
            
            //add new import preset to list and save
            [[HiFiToyPresetList sharedInstance] setPreset:self];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PresetImportNotification" object:self];
            
        } else {
            [[DialogSystem sharedInstance] showAlert:@"Import preset is not success!"];
        }
        
    }];
}

- (BOOL) importFromDataBufs:(NSArray<HiFiToyDataBuf *> *)dataBufs {
    for (id<HiFiToyObject> o in self.characteristics){
        if ([o importFromDataBufs:dataBufs] == YES){
            NSLog(@"import new char");
        } else {
            NSLog(@"import data is not full for this dsp characteristic!");
            return NO;;
        }
    }
    
    return YES;
}

- (void) updateChecksum {
    [self updateChecksumWithParamData:[self getBinary]];
}

- (void) updateChecksumWithParamData:(NSData *)data {
    uint8_t * d = (uint8_t *)data.bytes;
    
    uint8_t sum = 0;
    uint8_t fibonacci = 0;
    
    for (int i = 0; i < data.length; i++) {
        sum += d[i];
        fibonacci += sum;
        
        //printf("%d %x %x\n", i, sum, fibonacci);
    }
    
    _checkSum = sum & 0xFF;
    _checkSum |= ((uint16_t)fibonacci << 8) & 0xFF00;    
}

/*---------------------------- XML export/import ----------------------------------*/
-(XmlData *) toXmlData {
    XmlData * xmlData = [[XmlData alloc] init];
    for (int i = 0; i < self.characteristics.count; i++){
        XmlData * tempXmlData = [[self.characteristics objectAtIndex:i] toXmlData];
        [xmlData addXmlData:tempXmlData];
    }

    XmlData * presetXmlData = [[XmlData alloc] init];
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                           @"HiFiToy", @"Type",
                           @"1.0", @"Version", nil];
    
    [presetXmlData addElementWithName:@"Preset" withXmlValue:xmlData withAttrib:dict];
    
    return presetXmlData;
}

-(void) importFromXml:(XmlParserWrapper *)xmlParser withAttrib:(NSDictionary<NSString *, NSString *> *)attributeDict {
    /*count = 0;
    [xmlParser pushDelegate:self];*/
}

- (NSString *) checkPresetName:(NSString *)name {
    if ([[[[HiFiToyControl sharedInstance] activeHiFiToyDevice] activeKeyPreset] isEqualToString:name]) {
        NSString * msg = [NSString stringWithFormat:@"Preset %@ is exist and active. Import is not success.", name];
        [[DialogSystem sharedInstance] showAlert:msg];
        return nil;
    }
    
    if ([[HiFiToyPresetList sharedInstance] presetWithName:name]) {
        int index = 1;
        NSString * modifyName;
        do {
            modifyName = [name stringByAppendingString:[NSString stringWithFormat:@"_%d", index++]];
        } while ([[HiFiToyPresetList sharedInstance] presetWithName:modifyName]);
        
        
        /*NSString * msg = [NSString stringWithFormat:@"Preset %@ is exist and active. And we saved it with %@ name", name, modifyName];
        [[DialogSystem sharedInstance] showAlert:msg];*/
        return modifyName;
    }
    return name;
}

-(BOOL) importFromXml:(NSURL *)url checkName:(BOOL)checkName
        resultHandler:(void (^)(HiFiToyPreset *, NSString *))resultHandler {
    
    ///get name for preset
    NSArray * fileNameArray = [url.lastPathComponent componentsSeparatedByString:@"."];
    NSString * fileName = [fileNameArray objectAtIndex:0];
    
    if (checkName) {
        fileName = [self checkPresetName:fileName];
    }
    if (!fileName) return NO;
    self.presetName = fileName;
    xmlImportResultHandler = resultHandler;
    
    //start xml parser
    count = 0;
    xmlParser = [[XmlParserWrapper alloc] init];
    [xmlParser startParsingWithUrl:url withDelegate:self];
    
    return YES;
}

-(BOOL) importFromXmlWithData:(NSData *)data
                     withName:(NSString *)name
                    checkName:(BOOL)checkName
                resultHandler:(void (^)(HiFiToyPreset *, NSString *))resultHandler {
    if ((!name) || (!data)) return NO;
    if (checkName) {
        name = [self checkPresetName:name];
        if (!name) return NO;
    }
    self.presetName = name;
    xmlImportResultHandler = resultHandler;
    
    //start xml parser
    count = 0;
    xmlParser = [[XmlParserWrapper alloc] init];
    [xmlParser startParsingWithData:data withDelegate:self];
    
    return YES;
}

/* -------------------------------------- XmlParserDelegate ---------------------------------------*/
- (void) didFindXmlElement:(NSString *)elementName
                attributes:(NSDictionary<NSString *, NSString *> *)attributeDict
                    parser:(XmlParserWrapper *)xmlParser {
    
    //check version and type of DspPreset file
    if ([elementName isEqualToString:@"Preset"]){
        NSString * type = [attributeDict objectForKey:@"Type"];
        NSString * version = [attributeDict objectForKey:@"Version"];
        
        if ((!type) || (![type isEqualToString:@"HiFiToy"]) ||
            (!version) || (![version isEqualToString:@"1.0"])){
            //[parser abortParsing];
            [xmlParser stop];
            NSLog(@"DspPreset xml file is not correct. See \"Type\", \"Version\" fields.");
            return;
        }
        
    }
    
    //get DspAddress of DspElement
    NSString * addrStr = [attributeDict objectForKey:@"Address"];
    if (!addrStr) return;
    int addr = [addrStr intValue];
    
    NSLog(@"addr=%@", addrStr);
    
    //parse hiFiToyObjects
    for (int i = 0; i < self.characteristics.count; i++){
        id <HiFiToyObject> hiFiToyObject = self.characteristics[i];
        if ([hiFiToyObject address] == addr){
            [hiFiToyObject importFromXml:xmlParser withAttrib:attributeDict];
            count++;
        }
    }
}

- (void) didFoundXmlCharacters:(NSString *)characters
                    forElement:(NSString *)elementName
                        parser:(XmlParserWrapper *)xmlParser {

}

- (void) didEndXmlElement:(NSString *)elementName
                   parser:(XmlParserWrapper *)xmlParser {
    if ([elementName isEqualToString:@"Preset"]){
        
        if (count == self.characteristics.count){
            NSLog(@"Xml parsing is success complete.");
        } else {
            NSLog(@"Xml parsing is not success complete.");
            xmlParser.error = @"Preset is not full.";
        }
    }
}

- (void) finishedParsing:(NSString *)error {
    if (!error) {
        [self updateChecksum];
    }
    
    if (xmlImportResultHandler) {
        xmlImportResultHandler(self, error);
    }
}

@end
