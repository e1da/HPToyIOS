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


@implementation HiFiToyControl

- (id) init
{
    self = [super init];
    if (self){
        bleDriver = [[BleDriver alloc] init];
        [bleDriver resetCoreBleManager];
        bleDriver.communicationDelegate = self;
        _audioSource = AUTO;
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

- (NSMutableArray *) getPeripherals
{
    return bleDriver.peripherals;
}

- (BOOL) isConnected
{
    return [bleDriver isConnected];
}

- (void) startDiscovery
{
    if ([bleDriver isConnected]) {
        [bleDriver disconnectPeripheral];

    }
    [bleDriver findBLEPeripheralsWithName:@"HiFiToyPeripheral"];
}

- (void) stopDiscovery
{
    [bleDriver stopFindBLEPeripherals];
}

- (void) connect:(CBPeripheral *)p
{
    [bleDriver connectPeripheral:p];
}

- (void) disconnect
{
    [bleDriver disconnectPeripheral];
}

//base send command
- (void) sendDataToDsp:(NSData *) data withResponse:(BOOL)response
{
    [bleDriver writeValue:0xFFF0 characteristicUUID:0xFFF1 data:data response:response];
}

//sys command
- (void) sendNewPairingCode:(uint32_t) pairing_code
{
    CommonPacket_t packet;
    
    packet.cmd = SET_PAIR_CODE;
    memcpy(&packet.data, &pairing_code, 4);
    
    NSData *data = [[NSData alloc] initWithBytes:&packet length:sizeof(CommonPacket_t)];
    [self sendDataToDsp:data withResponse:YES];
    
}

- (void) startPairedProccess:(uint32_t) pairing_code
{
    CommonPacket_t packet;
    
    packet.cmd = ESTABLISH_PAIR;
    memcpy(&packet.data, &pairing_code, 4);
    
    NSData *data = [[NSData alloc] initWithBytes:&packet length:sizeof(CommonPacket_t)];
    [self sendDataToDsp:data withResponse:YES];
    
}

- (void) sendWriteFlag:(uint8_t) write_flag
{
    CommonPacket_t packet;
    
    packet.cmd = SET_WRITE_FLAG;
    packet.data[0] = write_flag;
    
    NSData *data = [[NSData alloc] initWithBytes:&packet length:sizeof(CommonPacket_t)];
    [self sendDataToDsp:data withResponse:YES];
}

- (void) checkFirmareWriteFlag
{
    CommonPacket_t packet;
    
    packet.cmd = GET_WRITE_FLAG;
    
    NSData *data = [[NSData alloc] initWithBytes:&packet length:sizeof(CommonPacket_t)];
    [self sendDataToDsp:data withResponse:YES];
}

- (void) getVersion
{
    CommonPacket_t packet;
    
    packet.cmd = GET_VERSION;
    
    NSData *data = [[NSData alloc] initWithBytes:&packet length:sizeof(CommonPacket_t)];
    [self sendDataToDsp:data withResponse:YES];
}

- (void) getChecksumParamData
{
    CommonPacket_t packet;
    
    packet.cmd = GET_CHECKSUM;
    
    NSData *data = [[NSData alloc] initWithBytes:&packet length:sizeof(CommonPacket_t)];
    [self sendDataToDsp:data withResponse:YES];
}

- (void) setInitDsp
{
    CommonPacket_t packet;
    
    packet.cmd = INIT_DSP;
    
    NSData *data = [[NSData alloc] initWithBytes:&packet length:sizeof(CommonPacket_t)];
    [self sendDataToDsp:data withResponse:YES];
}

- (void) setAudioSource:(AudioSource_t)audioSource
{
    _audioSource = audioSource;
    
    CommonPacket_t packet;
    packet.cmd = SET_AUDIO_SOURCE;
    packet.data[0] = audioSource;
    
    NSData *data = [[NSData alloc] initWithBytes:&packet length:sizeof(CommonPacket_t)];
    [self sendDataToDsp:data withResponse:YES];
}

- (void) updateAudioSource
{
    CommonPacket_t packet;
    
    packet.cmd = GET_AUDIO_SOURCE;
    
    NSData *data = [[NSData alloc] initWithBytes:&packet length:sizeof(CommonPacket_t)];
    [self sendDataToDsp:data withResponse:YES];
}

- (void) sendEnergyConfig:(EnergyConfig_t)energy
{
    NSData *data = [[NSData alloc] initWithBytes:&energy length:sizeof(EnergyConfig_t)];
    [self sendDataToDsp:data withResponse:YES];
}

//async request. need GetDataNotification implement
- (void) getEnergyConfig
{
    uint16_t offset = offsetof(HiFiToyPeripheral_t, energy);
    [self getDspDataWithOffset:offset];
}

//adv command (save/restore to/from storage)
- (void) restoreFactorySettings
{
    if (![self isConnected]) return;
    
    //show progress dialog
    [[DialogSystem sharedInstance] showProgressDialog:NSLocalizedString(@"Save Configuration", @"")];
    
    //get default preset data
    HiFiToyDevice * device = [[HiFiToyDeviceList sharedInstance] getActiveDevice];
    [device setActiveKeyPreset:@"DefaultPreset"];
    HiFiToyPreset * preset = [device getActivePreset];
    
    [[HiFiToyDeviceList sharedInstance] saveDeviceListToFile];
    
    //[preset saveToHiFiToyPeripheral];
    NSData * defaultPresetData = [preset getBinary];
    
    //fill HiFiToyConfig_t structure
    hiFiToyConfig.i2cAddr           = I2C_ADDR;
    hiFiToyConfig.successWriteFlag  = 0x00; //must be assign '0' before sendFactorySettings
    hiFiToyConfig.version           = HIFI_TOY_VERSION;
    hiFiToyConfig.pairingCode       = [[HiFiToyDeviceList sharedInstance] getActiveDevice].pairingCode;
    hiFiToyConfig.audioSource       = _audioSource;
    
    hiFiToyConfig.energy.highThresholdDb    = 0;    // 0
    hiFiToyConfig.energy.lowThresholdDb     = -55;  // -55
    hiFiToyConfig.energy.auxTimeout120ms    = 2500; // 2500 * 120ms = 300s = 5min
    hiFiToyConfig.energy.usbTimeout120ms    = 0;    // not used
    
    BiquadType_t * types = [preset.filters getBiquadTypes];
    memcpy(&hiFiToyConfig.biquadTypes, types, 7 * sizeof(BiquadType_t));
    free(types);
    
    hiFiToyConfig.dataBufLength     = [self getDataBufLength:defaultPresetData];
    hiFiToyConfig.dataBytesLength   = sizeof(HiFiToyPeripheral_t) - sizeof(DataBufHeader_t) + defaultPresetData.length;
    
    NSLog(@"Restore factory L=%dbytes, B=%dbufs", hiFiToyConfig.dataBytesLength, hiFiToyConfig.dataBufLength);
    
    uint8_t * sendData = malloc(hiFiToyConfig.dataBytesLength);
    
    //fill binary data
    memcpy(sendData, &hiFiToyConfig, sizeof(HiFiToyPeripheral_t));
    memcpy(sendData + offsetof(HiFiToyPeripheral_t, firstDataBuf), defaultPresetData.bytes, defaultPresetData.length);
    
    
    //send data
    for (int i = 0; i < hiFiToyConfig.dataBytesLength; i += 16){
        //send word offset and data bytes
        [self send16BytesWithOffset:(i >> 2) data:&sendData[i]];
        
        /*for (int u = 0; u < 16; u++){
         printf("%02x ", sendData[i + u]);
         
         }
         printf("\n");*/
    }
    free(sendData);
    
    //set write_flag = 1, i.e write is success
    [self sendWriteFlag:1];
    //
    [self setInitDsp];
}
    
- (void) storePresetToDSP:(HiFiToyPreset *) preset
{
    if (![self isConnected]) return;
    
    //show progress dialog
    [[DialogSystem sharedInstance] showProgressDialog:NSLocalizedString(@"Save Configuration", @"")];
    
    NSData * data = [preset getBinary];
    
    //fill biquqad types
    BiquadType_t * types = [preset.filters getBiquadTypes];
    memcpy(&hiFiToyConfig.biquadTypes, types, 7 * sizeof(BiquadType_t));
    free(types);
    
    //fill buf and bytes length
    hiFiToyConfig.dataBufLength     = [self getDataBufLength:data];
    hiFiToyConfig.dataBytesLength   = sizeof(HiFiToyPeripheral_t) - sizeof(DataBufHeader_t) + data.length;
    
    uint8_t typesLength = 8; // 7 biquads + 1 reserved byte
    uint16_t length = data.length + sizeof(hiFiToyConfig.dataBufLength) + sizeof(hiFiToyConfig.dataBytesLength) + typesLength;
    uint16_t offset = offsetof(HiFiToyPeripheral_t, biquadTypes);
    
    NSLog(@"Send DSP Config L=%dbytes, B=%dbufs", hiFiToyConfig.dataBytesLength, hiFiToyConfig.dataBufLength);
    
    uint8_t * sendData = malloc(length);
    memcpy(sendData, &hiFiToyConfig.biquadTypes, 12);
    memcpy(sendData + 12, data.bytes, data.length);
    
    /*for (int i = 0; i < length; i+=4) {
        printf("%2.2x %2.2x %2.2x %2.2x ", sendData[i + 0], sendData[i + 1], sendData[i + 2], sendData[i + 3]);
    }*/
    
    [self sendWriteFlag:0];

    //send data (used ATTACH_PAGE)
    [self sendBufToDspDataWithOffset:offset data:sendData length:length];
    free(sendData);
    
    //set write_flag = 1, i.e write is success
    [self sendWriteFlag:1];
    //
    [self setInitDsp];
}

//get 20 bytes from DSP_Data[offset]
- (void) getDspDataWithOffset:(uint16_t)offset
{
    NSData * offsetData = [NSData dataWithBytes:&offset length:2];
    [self sendDataToDsp:offsetData withResponse:YES];
}

/*--------------------------------Private Service Function------------------------------------*/

//send 16 bytes to DSP_Data[offset]
- (void) send16BytesWithOffset:(uint16_t)offset data:(uint8_t*)data{
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

//this method used attach page
//return real send length of buf
- (void) sendBufToDspDataWithOffset:(uint16_t)offsetInDspData data:(uint8_t*)data length:(uint16_t)length{
    
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

-(uint16_t) getDataBufLength:(NSData *)data
{
    DataBufHeader_t * dataBufHeader = (DataBufHeader_t *)data.bytes;
    
    uint16_t counter = 0;
    
    while (((uint8_t *)dataBufHeader -  (uint8_t *)data.bytes) < data.length) {
        dataBufHeader = (DataBufHeader_t *)((uint8_t *)dataBufHeader + dataBufHeader->length + sizeof(DataBufHeader_t));
        counter++;
    }
    
    return counter;
}

/*------------------------------- BleCommunication delegate -----------------------------------*/
-(void) keyfobDidFound
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KeyfobDidFoundNotification" object:nil];
}

- (void) keyfobMacAddrError {
    NSLog(@"keyfobMacAddrError ");
    [[DialogSystem sharedInstance] showAlert:NSLocalizedString(@"Mac address is not correct and device is not certified! Please contact your distributor.", @"")];
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
    
    
    //Enable FeedBack Info notification
    [bleDriver notification:0xFFF0 characteristicUUID:0xFFF3 on:YES];
    
    //Enable FeedBack Param Data notification
    [bleDriver notification:0xFFF0 characteristicUUID:0xFFF4 on:YES];
    
    //Enable Volume detector notification
    [bleDriver notification:0xFFF0 characteristicUUID:0xFFF2 on:YES];
    
    //send pairing code
    HiFiToyDevice * device = [[HiFiToyDeviceList sharedInstance] getActiveDevice];
    [self startPairedProccess:device.pairingCode];
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

-(void) keyfobDidWriteValue:(uint)remainPacketLength
{
    DialogSystem * dialog = [DialogSystem sharedInstance];
    
    if (remainPacketLength != 0){// if queue isn`t empty
        if (([dialog isProgressDialogVisible]) &&
            (![dialog.progressController.title isEqualToString:NSLocalizedString(@"Import Preset...", @"")])) {
            dialog.progressController.message = [NSString stringWithFormat:@"Left %d packets.", remainPacketLength];
        }
    } else {
        if ([dialog isProgressDialogVisible]) {
            [dialog dismissProgressDialog];
         
            //[[NSNotificationCenter defaultCenter] postNotificationName:@"CompleteDataSendNotification" object:nil];
        }
    }
}

-(void) keyfobDidUpdateValue:(NSData *) value
{
    if (value.length == 9) {
        uint8_t data[9];
        [value getBytes:&data length:9];
        
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
                    [self restoreFactorySettings];
                    
                }
                break;
            case GET_VERSION:
            {
                uint16_t version;
                memcpy(&version, data + 1, sizeof(uint16_t));
                
                if (version == HIFI_TOY_VERSION) {
                    NSLog(@"GET_VERSION_OK");
                    [self updateAudioSource];
                } else {
                    NSLog(@"GET_VERSION_FAIL");
                    /*HiFiToyPreset * preset = [[[HiFiToyDeviceList sharedInstance] getActiveDevice] getActivePreset];
                    [preset saveToHiFiToyPeripheral];*/
                    [self restoreFactorySettings];
                }
                break;
            }
            case GET_CHECKSUM:
                NSLog(@"GET_CHECKSUM");
                uint16_t checksum = 0;
                memcpy(&checksum, data + 1, 2);
                
                [self comparePreset:checksum];
                
                break;
            case GET_AUDIO_SOURCE:
            {
                _audioSource = data[1];
                NSLog(@"GET_AUDIO_SOURCE %d", _audioSource);
                [self getChecksumParamData];
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
    } else if (value.length == 20) { // Get data from storage
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetDataNotification" object:value];
    }
}

-(void) comparePreset:(uint16_t) checksum
{
    HiFiToyPreset * preset = [[[HiFiToyDeviceList sharedInstance] getActiveDevice] getActivePreset];
    NSLog(@"Checksum app preset = %x, Peripheral preset = %x", preset.checkSum, checksum);
    
    if (preset.checkSum != checksum) {
        [[DialogSystem sharedInstance] showImportPresetDialog];
    } else {
        NSLog(@"Import and current presets are equals!");
    }
}

@end
