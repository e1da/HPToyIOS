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
        [[NSNotificationCenter defaultCenter] postNotificationName:@"KeyfobDidFoundNotification" object:nil];
    }
    [bleDriver findBLEPeripheralsWithName:@"HiFiToyPeripheral"];
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

//this method used attach page
- (void) sendBufToDsp:(uint8_t*)data withLength:(uint16_t)length withOffset:(uint16_t)offsetInDspData; {
    
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

/*------------------------------- BleCommunication delegate -----------------------------------*/
-(void) keyfobDidFound:(NSString *)peripheralUUID
{
    HiFiToyDevice *device = [[HiFiToyDeviceList sharedInstance] getDeviceWithUUID:peripheralUUID];
    if (!device){
        device = [[HiFiToyDevice alloc] init];
        device.uuid = peripheralUUID;
        device.name = [device getShortUUIDString];
        [[HiFiToyDeviceList sharedInstance] setDevice:device withUUID:device.uuid];
    }
    
    [_foundHiFiToyDevices addObject:device];
    
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
    if (value.length == 13) { // get energy config
        uint8_t data[value.length];
        [value getBytes:&data length:value.length];
        
        CommonCmd_t feedbackMsg = data[0];
        if (feedbackMsg == GET_ENERGY_CONFIG) {
            NSLog(@"GET_ENERGY_CONFIG");
            
            EnergyConfig_t * energy = (EnergyConfig_t *)&data[1];
            _activeHiFiToyDevice.energyConfig = *energy;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateEnergyConfigNotification" object:nil];
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
                
                if (version == HIFI_TOY_VERSION) {
                    NSLog(@"GET_VERSION_OK");
                    [_activeHiFiToyDevice updateAudioSource];
                } else {
                    NSLog(@"GET_VERSION_FAIL");
                    [_activeHiFiToyDevice restoreFactory];
                }
                break;
            }
            case GET_CHECKSUM:
                NSLog(@"GET_CHECKSUM");
                uint16_t checksum = 0;
                memcpy(&checksum, data + 1, 2);
                
                [_activeHiFiToyDevice checkPresetChecksum:checksum];
                break;
            case GET_AUDIO_SOURCE:
            {
                _activeHiFiToyDevice.audioSource = data[1];
                NSLog(@"GET_AUDIO_SOURCE %d", _activeHiFiToyDevice.audioSource);
                [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateAudioSourceNotification" object:nil];
                
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
    }
    
    if (value.length == 20) { // Get data from storage
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetDataNotification" object:value];
    }
}

@end
