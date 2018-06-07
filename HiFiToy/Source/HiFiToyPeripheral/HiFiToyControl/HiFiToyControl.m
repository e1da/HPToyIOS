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


@implementation HiFiToyControl

- (id) init
{
    self = [super init];
    if (self){
        bleDriver = [[BleDriver alloc] init];
        [bleDriver resetCoreBleManager];
        bleDriver.communicationDelegate = self;
    }
    
    return self;
}

+ (HiFiToyControl *)sharedInstance
{
    static HiFiToyControl *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HiFiToyControl alloc] init];
        // Do any other initialisation stuff here
        
        //sharedInstance.ProgressDialog = [[UIAlertView alloc] init];
        
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
    [bleDriver findBLEPeripheralsWithName:@"HiFiToy"];
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

- (void) sendNewPairingCode:(uint32_t) pairing_code
{
    TestPacket_t packet;
    
    packet.cmd = SET_PAIR_CODE;
    memcpy(&packet.data, &pairing_code, 4);
    
    NSData *data = [[NSData alloc] initWithBytes:&packet length:sizeof(TestPacket_t)];
    [self sendDataToDsp:data withResponse:YES];
    
}

- (void) startPairedProccess:(uint32_t) pairing_code
{
    TestPacket_t packet;
    
    packet.cmd = ESTABLISH_PAIR;
    memcpy(&packet.data, &pairing_code, 4);
    
    NSData *data = [[NSData alloc] initWithBytes:&packet length:sizeof(TestPacket_t)];
    [self sendDataToDsp:data withResponse:YES];
    
}

- (void) sendWriteFlag:(uint8_t) write_flag
{
    TestPacket_t packet;
    
    packet.cmd = SET_WRITE_FLAG;
    packet.data[0] = write_flag;
    
    NSData *data = [[NSData alloc] initWithBytes:&packet length:sizeof(TestPacket_t)];
    [self sendDataToDsp:data withResponse:YES];
}

- (void) checkFirmareWriteFlag
{
    TestPacket_t packet;
    
    packet.cmd = GET_WRITE_FLAG;
    
    NSData *data = [[NSData alloc] initWithBytes:&packet length:sizeof(TestPacket_t)];
    [self sendDataToDsp:data withResponse:YES];
}

- (void) getChecksumParamData
{
    TestPacket_t packet;
    
    packet.cmd = GET_CHECKSUM;
    
    NSData *data = [[NSData alloc] initWithBytes:&packet length:sizeof(TestPacket_t)];
    [self sendDataToDsp:data withResponse:YES];
}

- (void) sendDSPConfig:(NSData *)data
{
    /*if ([self isConnected] == NO) return;
    
    //show progress dialog
    self.ProgressDialog.title = NSLocalizedString(@"Save Configuration", @"");
    self.ProgressDialog.message = @"Left ??? packets";
    
    [[self ProgressDialog] show];*/

    
    hiFiToyConfig.i2cAddr = I2C_ADDR;
    hiFiToyConfig.successWriteFlag = 0x00; //must be assign '0' before sendFactorySettings
    hiFiToyConfig.pairingCode = 0;
    hiFiToyConfig.dataBufLength = [self getDataBufLength:data];
    
    uint16_t sendDataLength = sizeof(HiFiToyPeripheral_t) - sizeof(DataBufHeader_t) + data.length;
    uint8_t * sendData = malloc(sendDataLength);
    
    memcpy(sendData, &hiFiToyConfig, sizeof(HiFiToyPeripheral_t));
    memcpy(sendData + offsetof(HiFiToyPeripheral_t, firstDataBuf), data.bytes, data.length);
    
    
    //send data
    for (int i = 0; i < sendDataLength; i += 16){
        //send word offset and data bytes
        [self send16BytesWithOffset:(i >> 2) data:&sendData[i]];
    }
    free(sendData);
    
    //set write_flag = 1, i.e write is success
    [self sendWriteFlag:1];
}


- (void) sendDataToDsp:(NSData *) data withResponse:(BOOL)response
{
    [bleDriver writeValue:0xFFF0 characteristicUUID:0xFFF1 data:data response:response];
}

//get 20 bytes from DSP_Data[offset]
- (void) getDspDataWithOffset:(uint16_t)offset
{
    NSData * offsetData = [NSData dataWithBytes:&offset length:2];
    [self sendDataToDsp:offsetData withResponse:YES];
}

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
- (uint16_t) sendBufToDspDataWithOffset:(uint16_t)offsetInDspData data:(uint8_t*)data length:(uint16_t)length{
    //calc length between offsetInDspData
    uint16_t length0 = CC2540_PAGE_SIZE - offsetInDspData % CC2540_PAGE_SIZE;
    if (length < length0) length0 = length;
    
    /*if (length > CC2540_PAGE_SIZE){
     length = CC2540_PAGE_SIZE ;
     }*/
    
    //send to attach buf
    for (int i = 0; i < length0; i += 16){
        //send word offset and data bytes
        [self send16BytesWithOffset:((ATTACH_PAGE_OFFSET + i) >> 2) data:&data[i]];
    }
    
    //move attach pg -> dsp data
    [self moveAttachPgToDspData:offsetInDspData length:length0];
    
    if (length0 < length){//send second part data(to second cc2540 memory pg)
        //send to attach buf
        for (int i = 0; i < (length - length0); i += 16){
            //send word offset and data bytes
            [self send16BytesWithOffset:((ATTACH_PAGE_OFFSET + i) >> 2) data:&data[length0 + i]];
        }
        
        //move attach pg -> dsp data
        [self moveAttachPgToDspData:(offsetInDspData + length0) length:(length - length0)];
    }
    
    return length;
}



/*--------------------------------Private Service Function------------------------------------*/
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

-(void) keyfobDidConnected
{
    NSLog(@"keyfobDidConnected");
    
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

-(void) keyfobDidDisconnected
{
    //show alert
    
}

-(void) keyfobDidWriteValue:(uint)remainPacketLength
{
    if (remainPacketLength != 0){// if queue isn`t empty
        /*if ((ProgressDialog) && (ProgressDialog.visible)) {
         ProgressDialog.message = [NSString stringWithFormat:@"Left %d packets.", [blePacketQueue size]];
         }*/
    } else {
        /*if ((ProgressDialog) && (ProgressDialog.visible)) {
         [ProgressDialog dismissWithClickedButtonIndex:0 animated:YES];
         
         [[NSNotificationCenter defaultCenter] postNotificationName:@"CompleteDataSendNotification" object:nil];
         }*/
    }
}

-(void) keyfobDidUpdateValue:(NSData *) value
{
    if (value.length == 9) {
        uint8_t data[9];
        [value getBytes:&data length:9];
        
        TestCmd_t feedbackMsg = data[0];
        uint8_t status = data[1];
        
        switch (feedbackMsg) {
            case ESTABLISH_PAIR:
                if (status == PAIR_YES) {
                    NSLog(@"PAIR_YES");
                    
                    [self checkFirmareWriteFlag];
                } else {
                    
                    NSLog(@"PAIR_NO");
                    //show input pair alert
                }
                break;
                
            case SET_PAIR_CODE:
                if (status) {
                    /*FeedBackAlert = [[UIAlertView alloc] initWithTitle:@"Confirm"
                     message:NSLocalizedString(@"Change Pairing code is successful!", @"")
                     delegate:self
                     cancelButtonTitle:@"Ok"
                     otherButtonTitles:nil];
                     [FeedBackAlert show];*/
                } else {
                    NSLog(@"SET_PAIR_CODE_FAIL");
                }
                
                break;
                
            case GET_WRITE_FLAG:
                if (status) {
                    NSLog(@"CHECK_FIRMWARE_OK");
                    
                    [self getChecksumParamData];
                } else {
                    NSLog(@"CHECK_FIRMWARE_FAIL");
                    
                    /*UIAlertView * FirmwarefailAlert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                 message:NSLocalizedString(@"Dsp Firmware is corrupted! Press 'Restore Factory Seetings' for solving problem!", @"")
                                                                                delegate:self
                                                                       cancelButtonTitle:@"Ok"
                                                                       otherButtonTitles:nil];
                    [FirmwarefailAlert show];*/
                }
                break;
                
            case GET_CHECKSUM:
                NSLog(@"GET_CHECKSUM_OK");
                uint16_t checksum = 0;
                memcpy(&checksum, data + 1, 2);
                
                
                break;
            case CLIP_DETECTION:
                
                break;
            case OTW_DETECTION:
                
                break;
            case PARAM_CONNECTION_ENABLED:
                NSLog(@"PARAM_CONNECTION_ENABLED");
                break;
            default:
                break;
        }
    } else if (value.length == 20) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GetDataNotification" object:value];
    }
}

/*------------- completeDataSendNotification: implementation ------------------*/
- (void) completeDataSendNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    /*UIAlertView *Alert= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", @"")
                                                   message:NSLocalizedString(@"Please reboot DSP!", @"")
                                                  delegate:self
                                         cancelButtonTitle:@"Ok"
                                         otherButtonTitles:nil];
    
    [Alert show];*/
}

@end
