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
#import "TAS5558.h"


@interface HiFiToyPreset(){
    XmlParserWrapper * xmlParser;
    int count;
    
    int paramAddress;
}

- (void) getParamData:(NSNotification*)notification;

@end

@implementation HiFiToyPreset

- (void) initCharacteristicsPointer
{
    _characteristics = [NSArray arrayWithObjects:_param, _masterVolume, _bassTreble, _loudness, _drc, nil];
}

//NSCoding protocol implementation
- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.presetName forKey:@"presetName"];
    [encoder encodeInt64:self.checkSum forKey:@"checkSum"];
    
    //Characteristics
    [encoder encodeObject:self.param forKey:@"Parametric"];
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
        self.param = [decoder decodeObjectForKey:@"Parametric"];
        self.masterVolume = [decoder decodeObjectForKey:@"MasterVolume"];
        self.bassTreble = [decoder decodeObjectForKey:@"BassTreble"];
        self.loudness = [decoder decodeObjectForKey:@"Loudness"];
        self.drc = [decoder decodeObjectForKey:@"Drc"];
        
        [self initCharacteristicsPointer];
        
    }
    return self;
}


//NSCopying protocol implementation
-(HiFiToyPreset *)copyWithZone:(NSZone *)zone
{
    HiFiToyPreset * copyPreset = [[[self class] allocWithZone:zone] init];
    
    NSLog(@"%lu", (unsigned long)copyPreset.characteristics.count);
    
    copyPreset.presetName = [self.presetName copy];
    copyPreset.checkSum = self.checkSum;
    
    copyPreset.param = [self.param copy];
    copyPreset.masterVolume = [self.masterVolume copy];
    copyPreset.bassTreble = [self.bassTreble copy];
    copyPreset.loudness = [self.loudness copy];
    copyPreset.drc = [self.drc copy];
    
    [copyPreset initCharacteristicsPointer];
    
    return copyPreset;
}

//isEqual implementation
- (BOOL) isEqual: (id) object
{
    if ([object class] == [self class]){
        HiFiToyPreset * temp = object;
        
        if (([self.param isEqual:temp.param] == NO) ||
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
- (void) loadDefaultPreset{
    self.presetName = @"DefaultPreset";
    
    //Parametric biquads
    if (!self.param){
        self.param = [[ParamFilterContainer alloc] init];
    } else {
        [self.param clear];
    }
    
    for (uint i = 0; i < 7; i++){
        ParamFilter * param = [ParamFilter initWithAddress0:BIQUAD_FILTER_REG + i
                                                    Address1:BIQUAD_FILTER_REG + 7 + i
                                                        Freq:100 Qfac:1.41 dbVolume:0.0
                                                     Enabled:(i == 0) ? YES : NO];
        [param setBorderMaxFreq:20000 minFreq:20];
        
        [self.param addParam:param];
    }
    
    //Master Volume
    self.masterVolume = [Volume initWithAddress:MASTER_VOLUME_REG dbValue:0.0 maxDb:0.0 minDb:MUTE_VOLUME];
    
    //Bass Treble
    BassTrebleChannel * bassTreble12 = [BassTrebleChannel initWithChannel:BASS_TREBLE_CH_127
                                                                 BassFreq:BASS_FREQ_125 BassDb:0
                                                               TrebleFreq:TREBLE_FREQ_9000 TrebleDb:0
                                                                maxBassDb:12 minBassDb:-12
                                                              maxTrebleDb:12 minTrebleDb:-12];
    self.bassTreble = [BassTreble initWithBassTreble127:bassTreble12
                                           BassTreble34:nil
                                           BassTreble56:nil
                                            BassTreble8:nil];
    
    [self.bassTreble setEnabledChannel:0 Enabled:1.0];
    [self.bassTreble setEnabledChannel:1 Enabled:1.0];
    
    //Loudness
    Biquad * loudnessBiquad = [Biquad initWithAddress:LOUDNESS_BIQUAD_REG Order:BIQUAD_ORDER_2 Type:BIQUAD_BANDPASS
                                                 Freq:60 Qfac:0.0 dbVolume:0.0];
    [loudnessBiquad setBorderMaxFreq:150 minFreq:30];
    
    self.loudness = [Loudness initWithOrder:loudnessBiquad LG:-0.5 LO:0.0 Gain:0.0 Offset:0.0];
    
    
    //Drc
    DrcCoef * drcCoef17 = [DrcCoef initWithChannel:DRC_CH_1_7
                                            Point0:initDrcPoint(POINT0_INPUT_DB, -120)
                                            Point1:initDrcPoint(-72, -72)
                                            Point2:initDrcPoint(-24, -24)
                                            Point3:initDrcPoint(POINT3_INPUT_DB, -24)];
    DrcCoef * drcCoef8 = [drcCoef17 copy];
    drcCoef8.channel = DRC_CH_8;
    
    DrcTimeConst * drcTimeConst17 = [DrcTimeConst initWithChannel:DRC_CH_1_7 Energy:0.1f Attack:10.0f Decay:100.0f];
    DrcTimeConst * drcTimeConst8 = [drcTimeConst17 copy];
    drcTimeConst8.channel = DRC_CH_8;
    
    self.drc = [Drc initWithCoef17:drcCoef17 Coef8:drcCoef8 TimeConst17:drcTimeConst17 TimeConst8:drcTimeConst8];
    
    [self.drc setEvaluation:POST_VOLUME_EVAL forChannel:0];
    [self.drc setEvaluation:POST_VOLUME_EVAL forChannel:1];
    [self.drc setEnabled:0.0 forChannel:0];
    [self.drc setEnabled:0.0 forChannel:1];
    
    [self initCharacteristicsPointer];
    [self updateChecksum];
}

+ (HiFiToyPreset *) initDefaultPreset
{
    HiFiToyPreset * currentInstance = [[HiFiToyPreset alloc] init];
    [currentInstance loadDefaultPreset];
    
    return currentInstance;
}

- (uint8_t)address {
    return 0;
}

- (BOOL)rename:(NSString *)newName
{
    if ([self.presetName isEqualToString:newName]){
        return NO;
    }
    
    if ([[HiFiToyPresetList sharedInstance] getPresetWithKey:newName]){
        [[DialogSystem sharedInstance] showAlert:NSLocalizedString(@"Preset is not renamed! Because preset with the same name does exists!", @"")];

        return NO;
    }
    
    NSString * tempName = [self.presetName copy];
    self.presetName = [newName copy];
    
    [[HiFiToyPresetList sharedInstance] updatePreset:self withKey:self.presetName];
    [[HiFiToyPresetList sharedInstance] removePresetWithKey:tempName];
    
    return YES;
}

//send preset to HiFiToyPeripheral, response always YES
- (void) sendWithResponse:(BOOL)response
{
    if (![[HiFiToyControl sharedInstance] isConnected]) return;
    
    //init progress dialog
    [[DialogSystem sharedInstance] showProgressDialog:NSLocalizedString(@"Send Dsp Parameters...", @"")];
    
    if (!self.characteristics) [self initCharacteristicsPointer];
    
    //send all dspCharacteristics to dsp
    for (int i = 0; i < self.characteristics.count; i++){
        [[self.characteristics objectAtIndex:i] sendWithResponse:YES];
    }
    
}

-(NSString *)getInfo
{
    return self.presetName;
}

//save preset
-(void)saveToHiFiToyPeripheral
{
    HiFiToyControl * hiFiToyControl = [HiFiToyControl sharedInstance];
    
    [hiFiToyControl sendDSPConfig:[self getBinary]];
}

//get binary for save to dsp
- (NSData *) getBinary
{
    NSMutableData *data = [[NSMutableData alloc] init];
    
    if (!self.characteristics) [self initCharacteristicsPointer];
    
    //get binary of all dspCharacteristics
    for (int i = 0; i < self.characteristics.count; i++){
        [data appendData:[[self.characteristics objectAtIndex:i] getBinary]];
    }
    
    return data;
}

- (void) importFromHiFiToyPeripheral
{
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(getParamData:)
                                                 name: @"GetDataNotification"
                                               object: nil];
    
    //show import dialog
    [[DialogSystem sharedInstance] showProgressDialog:NSLocalizedString(@"Import Preset...", @"")];
    
    paramAddress = 0;
    [[HiFiToyControl sharedInstance] getDspDataWithOffset:paramAddress];
}

- (void) getParamData:(NSNotification*)notification
{
    static uint8_t * data;
    static int length = 0;
    
    NSData * paramData = (NSData *)[notification object];
    
    if (paramData.length != 20) {
        [[DialogSystem sharedInstance] showAlert:@"Import preset is not success."];
        return;
    }
    
    if (paramAddress == 0) {
        HiFiToyPeripheral_t * hiFiToyConfig = (HiFiToyPeripheral_t *)paramData.bytes;
        length = hiFiToyConfig->dataBytesLength;
        
        if (data) free(data);
        data = malloc(length);
    }
    
    if (length > 20) {
        memcpy(&data[paramAddress], paramData.bytes, 20);
        paramAddress += 20;
    } else {
        memcpy(&data[paramAddress], paramData.bytes, length);
        paramAddress += length;
    }
    
    DialogSystem * dialog = [DialogSystem sharedInstance];
    if ([dialog isProgressDialogVisible]) {
        dialog.progressController.message = [NSString stringWithFormat:@"Left %d packets.", length / 20];
    }
    
    length -= 20;
    if (length > 0) {
        
        [[HiFiToyControl sharedInstance] getDspDataWithOffset:paramAddress];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        if ([dialog isProgressDialogVisible]) {
            [dialog dismissProgressDialog];
        }
        
        NSData * d = [NSData dataWithBytes:data length:paramAddress];
        [self importData:d];
        free(data);
    }
  
}

- (BOOL)importData:(NSData *)data {
    BOOL importResult = YES;
    
    for (int i = 0; i < self.characteristics.count; i++){
        if ([[self.characteristics objectAtIndex:i] importData:data] == YES){
            NSLog(@"import new char");
        } else {
            NSLog(@"import data is not full for this dsp characteristic!");
            importResult = NO;
            break;
        }
    }
    
    //import progress dialog close
    [[DialogSystem sharedInstance] dismissProgressDialog];
    
    if (importResult){
        //get data without HiFiToyPeripheral header
        uint8_t * params = (uint8_t *)data.bytes + offsetof(HiFiToyPeripheral_t, firstDataBuf);
        NSData * paramData = [NSData dataWithBytes:params length:(data.length - offsetof(HiFiToyPeripheral_t, firstDataBuf))];
        //update checksum preset
        [self updateChecksumWithParamData:paramData];
        
        //add new import preset to list and save
        [[HiFiToyPresetList sharedInstance] openPresetListFromFile];
        [[HiFiToyPresetList sharedInstance] updatePreset:self withKey:self.presetName];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PresetImportNotification" object:self];
        
    } else {
        [[DialogSystem sharedInstance] showAlert:@"Import preset is not success!"];
    }
    
    return importResult;
}

- (void) updateChecksum
{
    [self updateChecksumWithParamData:[self getBinary]];
}

- (void) updateChecksumWithParamData:(NSData *)data
{
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
-(XmlData *) toXmlData{
    XmlData * xmlData = [[XmlData alloc] init];
    for (int i = 0; i < self.characteristics.count; i++){
        XmlData * tempXmlData = [[self.characteristics objectAtIndex:i] toXmlData];
        [xmlData addXmlData:tempXmlData];
    }

    XmlData * presetXmlData = [[XmlData alloc] init];
    NSDictionary * dict = [[NSDictionary alloc] initWithObjectsAndKeys:
                           @"HiFiToy", @"Type",
                           @"1.0", @"Version",
                           [NSString stringWithFormat:@"%d", self.checkSum], @"Checksum", nil];
    
    [presetXmlData addElementWithName:@"Preset" withXmlValue:xmlData withAttrib:dict];
    
    return presetXmlData;
}

-(void) importFromXml:(XmlParserWrapper *)xmlParser withAttrib:(NSDictionary<NSString *, NSString *> *)attributeDict {
    /*count = 0;
    [xmlParser pushDelegate:self];*/
}


-(BOOL) importFromXml:(NSURL *)url {
    
    ///get name for preset
    NSArray * fileNameArray = [url.lastPathComponent componentsSeparatedByString:@"."];
    NSString * fileName = [fileNameArray objectAtIndex:0];
    self.presetName = fileName;
    
    //start xml parser
    count = 0;
    xmlParser = [[XmlParserWrapper alloc] init];
    [xmlParser startParsingWithUrl:url withDelegate:self];
    
    return NO;
}

/* -------------------------------------- XmlParserDelegate ---------------------------------------*/
- (void) didFindXmlElement:(NSString *)elementName
                attributes:(NSDictionary<NSString *, NSString *> *)attributeDict
                    parser:(XmlParserWrapper *)xmlParser {
    
    //check version and type of DspPreset file
    if ([elementName isEqualToString:@"Preset"]){
        NSString * type = [attributeDict objectForKey:@"Type"];
        NSString * version = [attributeDict objectForKey:@"Version"];
        NSString * checkSumStr = [attributeDict objectForKey:@"Checksum"];
        
        if ((!type) || (![type isEqualToString:@"HiFiToy"]) ||
            (!version) || (![version isEqualToString:@"1.0"]) || (!checkSumStr)){
            //[parser abortParsing];
            [xmlParser stop];
            NSLog(@"DspPreset xml file is not correct. See \"Type\", \"Version\" or \"Checksum\" fields.");
            return;
        }
        
        //get checksum from NSString
        self.checkSum =  atoi([checkSumStr UTF8String]);
        NSLog(@"import checksum = %@", [NSString stringWithFormat:@"%d", self.checkSum ]);
    }
    
    //get DspAddress of DspElement
    NSString * addrStr = [attributeDict objectForKey:@"Address"];
    if (!addrStr) return;
    int addr = [addrStr intValue];
    
    NSLog(@"addr=%@", addrStr);
    
    //parse hiFiToyObjects
    for (int i = 0; i < self.characteristics.count; i++){
        id <HiFiToyObject> hiFiToyObject = [self.characteristics objectAtIndex:i];
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
    if (error){
        NSString * errorString = [NSString stringWithFormat:@"Import preset is not success. %@", error ];
        [[DialogSystem sharedInstance] showAlert:errorString];
        
    } else {
        [self updateChecksum];
        [[HiFiToyPresetList sharedInstance] updatePreset:self withKey:self.presetName];
        
        NSString * msg = [NSString stringWithFormat:@"Add %@ preset", self.presetName];
        [[DialogSystem sharedInstance] showAlert:msg];
        
    }
}

@end
