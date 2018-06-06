//
//  BleDriver.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 05/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "BleDriver.h"
#import "BlePacketQueue.h"

@interface BleDriver() {
    CBCentralManager *CM;
    
    BlePacketQueue * blePacketQueue;
    BOOL bleBusy;
    
    NSString * nameFindingBle;
}

@end

@implementation BleDriver

- (id) init
{
    self = [super init];
    if (self) {
        blePacketQueue = [[BlePacketQueue alloc] init];
        _state = BLE_DISCONNECTED;
        nameFindingBle = @"";
    }
    return self;
}

//write to CC2540
-(void) writeValue:(int)serviceUUID characteristicUUID:(int)characteristicUUID data:(NSData *)data response:(BOOL)response
{
    
    CBCharacteristic * characteristic = [self getCharacteristicFromServiceUUID:serviceUUID characteristicUUID:characteristicUUID];
    if (!characteristic) return;
    
    //add new ble packet to queue (FIFO)
    //NSLog(@"write [size=%d]", blePacketQueue.size);
    
    [blePacketQueue addPacketWithCharacteristic:characteristic data:data response:response];
    
    
    if (bleBusy == NO){
        
        bleBusy = YES;
        BlePacket * packet = [blePacketQueue getFirstPacket];
        
        //NSLog(@"%@", [packet description]);
        [_activePeripheral writeValue:packet.data forCharacteristic:packet.characteristic type:CBCharacteristicWriteWithResponse];
    }
    
}


//read from CC2540
-(void) readValue: (int)serviceUUID characteristicUUID:(int)characteristicUUID
{
    
    CBCharacteristic * characteristic = [self getCharacteristicFromServiceUUID:serviceUUID characteristicUUID:characteristicUUID];
    if (!characteristic) return;
    
    [_activePeripheral readValueForCharacteristic:characteristic];
}


//CC2540 enabled/disabled notification
-(void) notification:(int)serviceUUID characteristicUUID:(int)characteristicUUID on:(BOOL)on
{
    
    CBCharacteristic * characteristic = [self getCharacteristicFromServiceUUID:serviceUUID characteristicUUID:characteristicUUID];
    if (!characteristic) return;
    
    [_activePeripheral setNotifyValue:on forCharacteristic:characteristic];
}

- (NSString *) getUUIDString
{
    if ([self isConnected]){
        NSString *uuidString = self.activePeripheral.identifier.UUIDString;
        return [uuidString substringFromIndex:(uuidString.length - 15)];
    } else {
        return @"Not connected";
    }
    
    return @"Not connected";
}

- (BOOL) isConnected
{
    if (_activePeripheral == nil) return NO;
    
    if (_activePeripheral.state == CBPeripheralStateConnected) {
        return YES;
    }
    
    return NO;
}

//reset core ble manager, clear ble packet queue
- (int) resetCoreBleManager
{
    CM = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    //init ble packet system
    blePacketQueue = [[BlePacketQueue alloc] init];
    [blePacketQueue clear];
    
    bleBusy = NO;
    
    return 0;
}

//find (discovery) peripherals
-(int) findBLEPeripheralsWithName:(NSString*)name
{
    
    if (CM.state  != CBCentralManagerStatePoweredOn) {
        NSLog(@"CoreBluetooth not correctly initialized!");
        NSLog(@"State = %d (%s)\r\n", (int)self->CM.state, [self centralManagerStateToString:CM.state]);
        return -1;
    }
    
    _peripherals = nil;
    
    nameFindingBle = name;
    _state = BLE_DISCOVERING;
    
    /*NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:TRUE],CBCentralManagerScanOptionAllowDuplicatesKey, nil];*/
    
    CBUUID *su = [self IntToCBUUID:0xFFF0];
    [CM scanForPeripheralsWithServices:[NSArray arrayWithObject:su] options:0/*options*/]; // Start scanning
    
    return 0; // Started scanning OK !
}

//stop find (discovery) peripherals
- (void) stopFindBLEPeripherals
{
    if (_state == BLE_DISCOVERING) {
        _state = BLE_DISCONNECTED;
    }
    
    if ([CM isScanning]) {
        [CM stopScan];
        NSLog(@"Stopped Scanning!");
    }
}

//disconnect to peripheral
- (void) disconnectPeripheral
{
    [self stopFindBLEPeripherals];
    
    if (_activePeripheral){
        [CM cancelPeripheralConnection:_activePeripheral];
        _activePeripheral = nil;
        
        NSLog(@"Disconnecting peripheral!");
    }
    
    _state = BLE_DISCONNECTED;
}

//connect to peripheral
- (void) connectPeripheral:(CBPeripheral *)peripheral
{
    _state = BLE_CONNECTING;
    
    NSLog(@"Connecting to peripheral with UUID : %@", peripheral.identifier.UUIDString);
    [CM connectPeripheral:peripheral options:nil];
}

//convert CentralManger state to string
- (const char *) centralManagerStateToString: (int)state
{
    switch(state) {
        case CBCentralManagerStateUnknown:
            return "State unknown (CBCentralManagerStateUnknown)";
        case CBCentralManagerStateResetting:
            return "State resetting (CBCentralManagerStateUnknown)";
        case CBCentralManagerStateUnsupported:
            return "State BLE unsupported (CBCentralManagerStateResetting)";
        case CBCentralManagerStateUnauthorized:
            return "State unauthorized (CBCentralManagerStateUnauthorized)";
        case CBCentralManagerStatePoweredOff:
            return "State BLE powered off (CBCentralManagerStatePoweredOff)";
        case CBCentralManagerStatePoweredOn:
            return "State powered up and ready (CBCentralManagerStatePoweredOn)";
        default:
            return "State unknown";
    }
    return "Unknown state";
}

//utility
-(UInt16) swap:(UInt16)s
{
    UInt16 temp = s << 8;
    temp |= (s >> 8);
    return temp;
}

-(CBUUID *) IntToCBUUID:(UInt16)val
{
    val = [self swap:val];
    NSData *d = [[NSData alloc] initWithBytes:(char *)&val length:2];
    return [CBUUID UUIDWithData:d];
}

-(UInt16) CBUUIDToInt:(CBUUID *) UUID
{
    char b1[16];
    [UUID.data getBytes:b1 length:16];
    return ((b1[0] << 8) | b1[1]);
}

//Find Service and Characteristic from uuid
-(CBService *) findServiceFromUUID:(CBUUID *)UUID p:(CBPeripheral *)p
{
    for(int i = 0; i < p.services.count; i++) {
        CBService *s = [p.services objectAtIndex:i];
        if ([s.UUID.data isEqualToData:UUID.data]) return s;
    }
    return nil; //Service not found on this peripheral
}

-(CBCharacteristic *) findCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service
{
    for(int i=0; i < service.characteristics.count; i++) {
        CBCharacteristic *c = [service.characteristics objectAtIndex:i];
        if ([c.UUID.data isEqualToData:UUID.data]) return c;
    }
    return nil; //Characteristic not found on this service
}

-(CBCharacteristic *) getCharacteristicFromServiceUUID:(int)serviceUUID
                                    characteristicUUID:(int)characteristicUUID
{
    if (!_activePeripheral) return nil;
    
    CBUUID *su = [self IntToCBUUID:serviceUUID];
    CBUUID *cu = [self IntToCBUUID:characteristicUUID];
    
    CBService *service = [self findServiceFromUUID:su p:_activePeripheral];
    if (!service) {
        NSLog(@"Could not find service with UUID %@ on peripheral with UUID %@", su.UUIDString, _activePeripheral.identifier.UUIDString);
        return nil;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
    if (!characteristic) {
        NSLog(@"Could not find characteristic with UUID %@ on service with UUID %@ on peripheral with UUID %@",
              cu.UUIDString, su.UUIDString, _activePeripheral.identifier.UUIDString);
        return nil;
    }
    
    return characteristic;
}

/*--------------------------- CBCentralManagerDelegate protocol methods -------------------------------------*/
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"Status of CoreBluetooth central manager changed %d (%s)\r\n",
          (int)central.state,
          [self centralManagerStateToString:central.state]);
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    NSString *peripheralAdvertName = [advertisementData valueForKey:@"kCBAdvDataLocalName"];
    
    if (!peripheralAdvertName) return;
    NSLog(@"didDiscoverPeripheral %@", peripheralAdvertName);
    
    //check DSP Name
    if (([peripheralAdvertName compare:nameFindingBle] == NSOrderedSame) ||
        ([nameFindingBle isEqualToString:@"ALL_PERIPHERAL"])){
        peripheral.delegate = self;
        
        if (!_peripherals){ //if peripheral array empty
            _peripherals = [[NSMutableArray alloc] initWithObjects:peripheral,nil];
            
        } else { //if peripheral array > 0
            for(int i = 0; i < _peripherals.count; i++) {
                CBPeripheral *p = [_peripherals objectAtIndex:i];
                if ([p.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
                    [_peripherals replaceObjectAtIndex:i withObject:peripheral];
                    NSLog(@"Duplicate UUID found updating ...");
                    return;
                }
            }
            
            [_peripherals addObject:peripheral];
        }
        NSLog(@"New UUID, adding.");
        
        if (_communicationDelegate) [_communicationDelegate keyfobDidFound];
    }
    
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Connection to peripheral with UUID : %@ successfull", peripheral.identifier.UUIDString);
    
    //check alertdisconnected and close
    /*if (AlertDisconnected.visible){
        [AlertDisconnected dismissWithClickedButtonIndex:0 animated:YES];
    }*/
    
    _state = BLE_CONNECTED;
    
    _activePeripheral = peripheral;
    _activePeripheral.delegate = self;
    
    CBUUID *su = [self IntToCBUUID:0xFFF0];
    [self.activePeripheral discoverServices:[NSArray arrayWithObject:su]];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    /*UIAlertView *AlertFailToConnect= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", @"")
                                                                message:@"FailToConnectPeripheral"
                                                               delegate:self
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
    [AlertFailToConnect show];*/
    
    _activePeripheral = nil;
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    //deprecated must be UIAlertController
   /* AlertDisconnected= [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", @"")
                                                  message:NSLocalizedString(@"Disconnected!", @"")
                                                 delegate:self
                                        cancelButtonTitle:@"Ok"
                                        otherButtonTitles:nil];
    [AlertDisconnected show];
    
    if (self.ProgressDialog != nil){
        if (self.ProgressDialog.visible){
            [self.ProgressDialog dismissWithClickedButtonIndex:0 animated:YES];
        }
    }*/
    
    if (_activePeripheral){//re-connect
        [self connectPeripheral:self.activePeripheral];
        _activePeripheral = nil;
    }
    
    if (self.communicationDelegate){
        [self.communicationDelegate keyfobDisconnected:@"Disconnected!"];
    }
}

/*----------------------------- CBPeripheralDelegate protocol methods ---------------------------------------------------*/
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (!error) {
        NSLog(@"Characteristics of service with UUID : %@ found", service.UUID.UUIDString);
        for (int i = 0; i < service.characteristics.count; i++) {
            CBCharacteristic *c = [service.characteristics objectAtIndex:i];
            NSLog(@"%@", c.UUID.UUIDString);
        }
        
        if (self.communicationDelegate){
            [self.communicationDelegate keyfobDidPaired];
        }
        
    }
    else {
        NSLog(@"Characteristic discorvery unsuccessfull !");
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error {
    if (!error) {
        NSLog(@"Services of peripheral with UUID : %@ found", peripheral.identifier.UUIDString);
        
        //discover all characteristics
        for (int i = 0; i < peripheral.services.count; i++) {
            CBService *s = [peripheral.services objectAtIndex:i];
            NSLog(@"Fetching characteristics for service with UUID : %@\r\n", s.UUID.UUIDString);
            [peripheral discoverCharacteristics:nil forService:s];
        }
    }
    else {
        NSLog(@"Service discovery was unsuccessfull !");
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (!error) {
        NSLog(@"Updated notification state for characteristic with UUID %@ on service with  UUID %@ on peripheral with UUID %@",characteristic.UUID.UUIDString, characteristic.service.UUID.UUIDString, peripheral.identifier.UUIDString);
    }
    else {
        NSLog(@"Error in setting notification state for characteristic with UUID %@ on service with  UUID %@ on peripheral with UUID %@", characteristic.UUID.UUIDString, characteristic.service.UUID.UUIDString, peripheral.identifier.UUIDString);
        NSLog(@"Error code was %s",[[error description] cStringUsingEncoding:NSStringEncodingConversionAllowLossy]);
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"updateValueForCharacteristic failed !");
        return;
    }
    
    //UIAlertView * FeedBackAlert;
    
    UInt16 characteristicUUID = [self CBUUIDToInt:characteristic.UUID];
    
    switch(characteristicUUID){
        case 0xFFF3:
        {
            uint8_t data[9];
            [characteristic.value getBytes:&data length:9];
            TestCmd_t feedbackMsg = data[0];
            uint8_t status = data[1];
            
            switch (feedbackMsg) {
                case ESTABLISH_PAIR:
                    if (status == PAIR_YES) {
                        if (self.communicationDelegate){
                            [self.communicationDelegate keyfobPairingOk];
                        }
                        NSLog(@"PAIR_YES");
                    } else {
                        if (self.communicationDelegate){
                            [self.communicationDelegate  keyfobPairingFail];
                        }
                        NSLog(@"PAIR_NO");
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
                        
                        if (self.communicationDelegate){
                            [self.communicationDelegate keyfobFirmwareOk];
                        }
                    } else {
                        NSLog(@"CHECK_FIRMWARE_FAIL");
                        
                        if (self.communicationDelegate){
                            [self.communicationDelegate keyfobFirmwareFail];
                        }
                    }
                    break;
                    
                case GET_CHECKSUM:
                    NSLog(@"GET_CHECKSUM_OK");
                    uint16_t checksum = 0;
                    memcpy(&checksum, data + 1, 2);
                        
                    if (self.communicationDelegate){
                        [self.communicationDelegate keyfobReadyWithChecksum:checksum];
                    }
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
            break;
        }
        case 0xFFF4:
        {
            if (self.paramDataDelegate) {
                [self.paramDataDelegate getParamDataDelegate:characteristic.value];
            }
            break;
        }
        default:
            break;
          
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"%@", error.description);
        return;
    }
    
    NSLog(@"did write");
    
    UInt16 characteristicUUID = [self CBUUIDToInt:characteristic.UUID];
    
    if (characteristicUUID == 0xFFF1) {
        [blePacketQueue removeFirstPacket];
                
        if ([blePacketQueue size] != 0){// if queue isn`t empty
            
            bleBusy = YES;
            //get first packet
            BlePacket *packet = [blePacketQueue getFirstPacket];
            //send packet
            [self.activePeripheral writeValue:packet.data forCharacteristic:packet.characteristic type:CBCharacteristicWriteWithResponse];
                    
            /*if ((ProgressDialog) && (ProgressDialog.visible)) {
                ProgressDialog.message = [NSString stringWithFormat:@"Left %d packets.", [blePacketQueue size]];
            }*/
            
        } else {
            bleBusy = NO;
                    
            /*if ((ProgressDialog) && (ProgressDialog.visible)) {
                [ProgressDialog dismissWithClickedButtonIndex:0 animated:YES];
                            
                [[NSNotificationCenter defaultCenter] postNotificationName:@"CompleteDataSendNotification" object:nil];
            }*/
        }
        
        NSLog(@"didWriteValueForCharacteristic. packet queue = %d", [blePacketQueue size]);
    }

}

@end
