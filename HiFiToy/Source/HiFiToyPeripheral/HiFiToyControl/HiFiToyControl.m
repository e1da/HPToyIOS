//
//  HiFiToyControl.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 06/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "HiFiToyControl.h"
#import "TAS5558.h"
#import "HiFiToyDeviceList.h"
#import "DialogSystem.h"
#import "PeripheralData.h"
#import "Checksummer.h"


@implementation HiFiToyControl {
    BleDriver * bleDriver;
}

- (id) init
{
    self = [super init];
    if (self){
        bleDriver = [[BleDriver alloc] init];
        bleDriver.communicationDelegate = self;
        
        _foundHiFiToyDevices = [[NSMutableArray alloc] init];
        _activeHiFiToyDevice = [[HiFiToyDeviceList sharedInstance] getDeviceWithUUID:@"demo"];
    }
    
    return self;
}

+ (HiFiToyControl *)sharedInstance
{
    static HiFiToyControl *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HiFiToyControl alloc] init];
        
    });
    return sharedInstance;
}

- (BOOL) isConnected
{
    return ( (_activeHiFiToyDevice) && ([bleDriver isConnected]) );
}

- (void) startDiscovery
{
    [_foundHiFiToyDevices removeAllObjects];

    if ([bleDriver isConnected]) {
        [_foundHiFiToyDevices addObject:_activeHiFiToyDevice];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SetupOutletsNotification" object:nil];
    }
    
    [bleDriver findBLEPeripherals];
}

- (void) stopDiscovery
{
    [bleDriver stopFindBLEPeripherals];
}

- (void) connect:(HiFiToyDevice *) device
{
    _activeHiFiToyDevice = device;
    [bleDriver connectWithUUID:device.uuid];
}

- (void) demoConnect
{
    [self connect:[[HiFiToyDeviceList sharedInstance] getDeviceWithUUID:@"demo"]];
}

- (void) disconnect
{
    _activeHiFiToyDevice = [[HiFiToyDeviceList sharedInstance] getDeviceWithUUID:@"demo"];
    [bleDriver disconnect];
}

//base send command
- (void) sendDataToDsp:(NSData *) data withResponse:(BOOL)response
{
    [bleDriver writeValue:0xFFF0 characteristicUUID:0xFFF1 data:data response:response];
}

- (void) sendPacketToDsp:(Packet_t *)packet withResponse:(BOOL)response
{
    NSData *data = [[NSData alloc] initWithBytes:packet length:sizeof(Packet_t)];
    [self sendDataToDsp:data withResponse:response];
}

- (void) sendCommonPacketToDsp:(CommonPacket_t *)packet
{
    NSData *data = [[NSData alloc] initWithBytes:packet length:sizeof(CommonPacket_t)];
    [self sendDataToDsp:data withResponse:YES];
}

//this method used attach page
- (void) sendBufToDsp:(const uint8_t *)data withLength:(uint16_t)length withOffset:(uint16_t)offsetInDspData
{    
    //init vars
    uint16_t l = CC2540_PAGE_SIZE - offsetInDspData % CC2540_PAGE_SIZE;
    if (length < l) l = length;
    
    uint16_t offset = 0;
    
    do {
        //send to attach buf
        for (int i = 0; i < l; i += 16){
            //send word offset and data bytes
            [self send16BytesWithOffset:((ATTACH_PAGE_OFFSET + i) >> 2) data:&data[offset + i]];
        }
        //move attach pg -> dsp data
        [self moveAttachPgToDspData:(offset + offsetInDspData) length:l];
        
        //update
        offset += l;
        l = length - offset;
        if (l > CC2540_PAGE_SIZE) l = CC2540_PAGE_SIZE;
        
        //condition
    } while (offset < length);
}

- (void) sendBufToDsp:(NSData *)data withOffset:(uint16_t)offsetInDspData
{
    [self sendBufToDsp:data.bytes withLength:data.length withOffset:offsetInDspData];
}

//get 20 bytes from DSP_Data[offset]
- (void) getDspDataWithOffset:(uint16_t)offset
{
    NSData * offsetData = [NSData dataWithBytes:&offset length:2];
    [self sendDataToDsp:offsetData withResponse:YES];
}

//sys command
- (void) sendNewPairingCode:(uint32_t) pairing_code
{
    CommonPacket_t packet;
    
    packet.cmd = SET_PAIR_CODE;
    memcpy(&packet.data, &pairing_code, 4);
    
    [self sendCommonPacketToDsp:&packet];
}

- (void) startPairedProccess:(uint32_t) pairing_code
{
    CommonPacket_t packet;
    
    packet.cmd = ESTABLISH_PAIR;
    memcpy(&packet.data, &pairing_code, 4);
    
    [self sendCommonPacketToDsp:&packet];
}

- (void) sendWriteFlag:(uint8_t) write_flag
{
    CommonPacket_t packet;
    
    packet.cmd = SET_WRITE_FLAG;
    packet.data[0] = write_flag;
    
    [self sendCommonPacketToDsp:&packet];
}

- (void) checkFirmareWriteFlag
{
    CommonPacket_t packet;
    packet.cmd = GET_WRITE_FLAG;
    
    [self sendCommonPacketToDsp:&packet];
}

- (void) getVersion
{
    CommonPacket_t packet;
    packet.cmd = GET_VERSION;
    
    [self sendCommonPacketToDsp:&packet];
}

- (void) getChecksumParamData
{
    CommonPacket_t packet;
    packet.cmd = GET_CHECKSUM;
    
    [self sendCommonPacketToDsp:&packet];
}

- (void) setInitDsp
{
    CommonPacket_t packet;
    packet.cmd = INIT_DSP;
    
    [self sendCommonPacketToDsp:&packet];
}

/*--------------------------------Private Service Function------------------------------------*/

//send 16 bytes to DSP_Data[offset]
- (void) send16BytesWithOffset:(uint16_t)offset data:(const uint8_t *)data{
    uint8_t packet18[18];

    memcpy(packet18, &offset, 2);
    memcpy(packet18 + 2, data, 16);
    
    NSData *sendData = [[NSData alloc] initWithBytes:packet18 length:18];
    [self sendDataToDsp:sendData withResponse:YES];
    
}

- (void) moveAttachPgToDspData:(uint16_t)offset length:(uint16_t)length{
    uint8_t packet4[4];
    
    memcpy(packet4 + 0, &offset, 2);
    memcpy(packet4 + 2, &length, 2);
    
    NSData * data = [[NSData alloc] initWithBytes:packet4 length:4];
    [self sendDataToDsp:data withResponse:YES];
}

/*------------------------------- Peripheral filter methods -----------------------------------*/
- (BOOL) isPeripheralSupported:(NSString *)peripheralName {
    NSArray<NSString *> * ps = @[@"HiFiToyPeripheral", @"HPToyPeripheral", @"PDV21Peripheral"];
    for (NSString * s in ps) {
        if ([peripheralName isEqualToString:s]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL) isNewPDV2Peripheral:(NSString *)peripheralName {
    return ([peripheralName isEqualToString:@"PDV21Peripheral"]);
}

/*------------------------------- BleCommunication delegate -----------------------------------*/
-(void) keyfobDidFound:(NSString * _Nonnull)peripheralUUID name:(NSString * _Nonnull)peripheralName {
    if ( ![self isPeripheralSupported:peripheralName] ) {
        return;
    }
    
    HiFiToyDevice *device = [[HiFiToyDeviceList sharedInstance] getDeviceWithUUID:peripheralUUID];
    if (!device){
        device = [[HiFiToyDevice alloc] init];
        device.uuid = peripheralUUID;
        device.name = [device getShortUUIDString];
        [[HiFiToyDeviceList sharedInstance] setDevice:device withUUID:device.uuid];
    }
    device.newPDV21Hw = [self isNewPDV2Peripheral:peripheralName];
    
    [_foundHiFiToyDevices addObject:device];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SetupOutletsNotification" object:nil];
}

-(void) keyfobDidConnected
{
    NSLog(@"keyfobDidConnected");
    
    //check alertdisconnected and close
    DialogSystem * dialog = [DialogSystem sharedInstance];
    if (([dialog isAlertVisible]) &&
        ([dialog.alertController.message isEqualToString:NSLocalizedString(@"Disconnected!", @"")])){
        
        [[DialogSystem sharedInstance] dismissAlert];
    }
    
    //send pairing code
    [self startPairedProccess:_activeHiFiToyDevice.pairingCode];
}

-(void) keyfobDidFailConnect
{
    NSLog(@"keyfobDidFailConnect");
    [[DialogSystem sharedInstance] showAlert:NSLocalizedString(@"Fail connect to peripheral!", @"")];
    
}

-(void) keyfobDidDisconnected
{
    [[DialogSystem sharedInstance] dismissProgressDialog]; // if visible then dismiss
    
    //show alert
    [[DialogSystem sharedInstance] showAlert:NSLocalizedString(@"Disconnected!", @"")];
}

- (void) keyfobDidWrite:(BlePacket *)p error:(NSError *)error {
    /*NSLog(@"keyfobMacAddrError ");
    [[DialogSystem sharedInstance] showAlert:NSLocalizedString(@"Mac address is not correct and device is not certified! Please contact your distributor.", @"")];
     */
    
    if (p.data.length == sizeof(CommonPacket_t)) {
        uint8_t * data = (uint8_t *)p.data.bytes;
        uint8_t cmd = data[0];
        
        if ((cmd >= SET_TAS5558_CH3_MIXER) && (cmd <= GET_OUTPUT_MODE)) {
            if (error) {
                NSLog(@"Output Mode is unsupported.");
                [_activeHiFiToyDevice.outputMode setHwSupported:NO];
                
            } else {
                [_activeHiFiToyDevice.outputMode setHwSupported:YES];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SetupOutletsNotification" object:nil];
        }
    }
    
}

-(void) keyfobDidUpdateValue:(NSData *) value
{
    if (value.length == 13) { // get energy config
        uint8_t data[value.length];
        [value getBytes:&data length:value.length];
        
        CommonCmd_t feedbackMsg = data[0];
        if (feedbackMsg == GET_ENERGY_CONFIG) {
            NSLog(@"GET_ENERGY_CONFIG");
            
            EnergyConfig_t * energy = (EnergyConfig_t *)&data[1];
            _activeHiFiToyDevice.energyConfig = *energy;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SetupOutletsNotification" object:nil];
        }
    }
    
    if (value.length == 4) {
        uint8_t data[4];
        [value getBytes:&data length:4];
        
        CommonCmd_t feedbackMsg = data[0];
        uint8_t status = data[1];
        
        switch (feedbackMsg) {
            case ESTABLISH_PAIR:
                if (status == PAIR_YES) {
                    NSLog(@"PAIR_YES");
                    
                    [self checkFirmareWriteFlag];
                } else {
                    
                    NSLog(@"PAIR_NO");
                    //show input pair alert
                    [[DialogSystem sharedInstance] showPairCodeInput];
                }
                break;
                
            case SET_PAIR_CODE:
                if (status) {
                    NSLog(@"SET_PAIR_CODE_SUCCESS");
                    [[DialogSystem sharedInstance] showAlert:NSLocalizedString(@"Change Pairing code is successful!", @"")];
                    
                } else {
                    NSLog(@"SET_PAIR_CODE_FAIL");
                }
                
                break;
                
            case GET_WRITE_FLAG:
                if (status) {
                    NSLog(@"CHECK_FIRMWARE_OK");
                    
                    [self getVersion];
                } else {
                    NSLog(@"CHECK_FIRMWARE_FAIL");
                    
                    /*[[DialogSystem sharedInstance] showAlert:NSLocalizedString(@"Dsp Firmware is corrupted! Press 'Restore Factory Settings' for solving problem!", @"")];*/
                    [_activeHiFiToyDevice restoreFactory];
                    
                }
                break;
            case GET_VERSION:
            {
                uint16_t version;
                memcpy(&version, data + 1, sizeof(uint16_t));
                
                if (version == PERIPHERAL_VERSION) {
                    NSLog(@"GET_VERSION_OK");
                    [_activeHiFiToyDevice updateAudioSource];
                } else {
                    NSLog(@"GET_VERSION_FAIL");
                    [_activeHiFiToyDevice restoreFactory];
                }
                break;
            }
            case GET_CHECKSUM:
            {
                NSLog(@"GET_CHECKSUM");
                __block uint16_t checksum;
                memcpy(&checksum, data + 1, 2);
                
                //need update checksum if AmMode reg exists
                //first we need get data bytes length
                PeripheralData * pd = [[PeripheralData alloc] init];
                [pd importHeader:^() {
                    NSLog(@"Data buf length = %d", [pd bufBytesLength]);
                    
                    HiFiToyDevice * dev = self->_activeHiFiToyDevice;
                    
                    //update checksum. subtract amMode data
                    if ([dev.amMode isEnabled]) {
                        HiFiToyDataBuf * amModeDataBuf = [dev.amMode getDataBufs][0];
                        checksum = [Checksummer subtractDataFrom:checksum
                                                  originalLength:[pd bufBytesLength]
                                                            data:amModeDataBuf.data];
                        
                    }
                    
                    //next compare updated checksum with current preset checksum
                    NSLog(@"Checksum app preset = %x, Peripheral preset = %x",
                          dev.preset.checkSum, checksum);
                    
                    if (dev.preset.checkSum != checksum) {
                        [[DialogSystem sharedInstance] showImportPresetDialog];
                    } else {
                        NSLog(@"Import and current presets are equals!");
                    }
                    
                }];
                break;
            }
            case GET_AUDIO_SOURCE:
            {
                _activeHiFiToyDevice.audioSource = data[1];
                NSLog(@"GET_AUDIO_SOURCE %d", _activeHiFiToyDevice.audioSource);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"SetupOutletsNotification" object:nil];
                
                [_activeHiFiToyDevice.amMode importFromPeripheral:^() {
                    NSLog(@"GET_AM_MODE: %@ %@",
                          [self->_activeHiFiToyDevice.amMode isEnabled] ? @"Enabled" : @"Disabled",
                          [self->_activeHiFiToyDevice.amMode getInfo]);
                    
                    [self getChecksumParamData];
                }];
                break;
            }
            case GET_ADVERTISE_MODE:
            {
                _activeHiFiToyDevice.advertiseMode = data[1];
                NSLog(@"GET_ADVERTISE_MODE %d", _activeHiFiToyDevice.advertiseMode);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"SetupOutletsNotification" object:nil];
                break;
            }
            case GET_OUTPUT_MODE: //WARNING: not uses. bug on HW side
                NSLog(@"GET_OUTPUT_MODE %d", status);
                break;
            
            case GET_TAS5558_CH3_MIXER: //WARNING: not uses. bug on HW side in GET_OUTPUT_MODE cmd
            {
                uint16_t val = data[1] + (uint16_t)(data[2] << 8);
                NSLog(@"GET_TAS5558_CH3_MIXER %d", val);
                break;
            }
            case CLIP_DETECTION:
            {
                NSNumber * clip = [NSNumber numberWithInt:status];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ClipDetectionNotification" object:clip];
                break;
            }
            case OTW_DETECTION:
                
                break;
            case PARAM_CONNECTION_ENABLED:
                NSLog(@"PARAM_CONNECTION_ENABLED");
                break;
            default:
                break;
        }
    }
    
    if (value.length == 20) { // Get data from storage
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetDataNotification" object:value];
    }
}

-(void) keyfobUpdatePacketLength:(uint)remainPacketLength
{
    DialogSystem * dialog = [DialogSystem sharedInstance];
    
    if (remainPacketLength != 0){// if queue isn`t empty
        if (([dialog isProgressDialogVisible]) &&
            (![dialog.progressController.title isEqualToString:NSLocalizedString(@"Import Preset...", @"")])) {
            dialog.progressController.message = [NSString stringWithFormat:@"Left %d packets.", remainPacketLength];
        }
    } else {
        [dialog dismissProgressDialog];
    }
}

@end
    
