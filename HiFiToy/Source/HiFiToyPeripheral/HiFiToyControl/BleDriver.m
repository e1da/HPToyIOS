//
//  BleDriver.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 05/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "BleDriver.h"

@interface BleDriver() {
    CBCentralManager * CM;
    NSMutableArray * peripherals;
    CBPeripheral * activePeripheral;
    
    BlePacketQueue * blePacketQueue;
    NSString * nameFindingBle;
    
    BOOL needStartDiscovery;
}

@end

@implementation BleDriver

- (id) init {
    self = [super init];
    if (self) {
        CM = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        
        blePacketQueue = [[BlePacketQueue alloc] init];
        peripherals = [[NSMutableArray alloc] init];
        activePeripheral = nil;
        nameFindingBle = @"";
        
        needStartDiscovery = NO;
    }
    return self;
}

//write to CC2540
-(void) writeValue:(int)serviceUUID characteristicUUID:(int)characteristicUUID data:(NSData *)data response:(BOOL)response {
    
    CBCharacteristic * characteristic = [self getCharacteristicFromServiceUUID:serviceUUID characteristicUUID:characteristicUUID];
    if (!characteristic) return;
    
    //add new ble packet to queue (FIFO)
    //NSLog(@"write [size=%d]", blePacketQueue.size);
    
    [blePacketQueue addPacketWithCharacteristic:characteristic data:data response:response];
    //[blePacketQueue print];
    
    if ([blePacketQueue size] == 1) {
        
        BlePacket * packet = [blePacketQueue getFirstPacket];
        
        //NSLog(@"%@", [packet description]);
        [activePeripheral writeValue:packet.data forCharacteristic:packet.characteristic type:CBCharacteristicWriteWithResponse];
    }
    
}


//read from CC2540
-(void) readValue: (int)serviceUUID characteristicUUID:(int)characteristicUUID {
    
    CBCharacteristic * characteristic = [self getCharacteristicFromServiceUUID:serviceUUID characteristicUUID:characteristicUUID];
    if (!characteristic) return;
    
    [activePeripheral readValueForCharacteristic:characteristic];
}


//CC2540 enabled/disabled notification
-(void) notification:(int)serviceUUID characteristicUUID:(int)characteristicUUID on:(BOOL)on {
    
    CBCharacteristic * characteristic = [self getCharacteristicFromServiceUUID:serviceUUID characteristicUUID:characteristicUUID];
    if (!characteristic) return;
    
    [activePeripheral setNotifyValue:on forCharacteristic:characteristic];
}

-(int) findBLEPeripheralsWithName:(NSString*)name {
    needStartDiscovery = NO;
    nameFindingBle = name;
    
    [peripherals removeAllObjects];
    
    if ([self isConnected]) {
        [peripherals addObject:activePeripheral];
    }
    
    if (CM.state != CBManagerStatePoweredOn) {
        NSLog(@"CoreBluetooth not correctly initialized!");
        NSLog(@"State = %d (%s)\r\n", (int)CM.state, [self centralManagerStateToString:CM.state]);
        needStartDiscovery = YES;
        return -1;
    }

    NSLog(@"Start discovering!");
    
    CBUUID *su = [self IntToCBUUID:0xFFF0];
    [CM scanForPeripheralsWithServices:[NSArray arrayWithObject:su] options:0]; // Start scanning
    
    return 0;
}

- (void) stopFindBLEPeripherals {
    if ([CM isScanning]) {
        [CM stopScan];
        NSLog(@"Stopped discovering!");
    }
}

- (BOOL) isConnected {
    return ( (activePeripheral) && (activePeripheral.state == CBPeripheralStateConnected) );
}

//disconnect to peripheral
- (void) disconnect {
    if ([self isConnected]){
        [CM cancelPeripheralConnection:activePeripheral];
        NSLog(@"Disconnecting peripheral!");
    }
    activePeripheral = nil;
}

//connect to peripheral
- (void) connect:(CBPeripheral *)peripheral {
    if ([self isConnected]) {
        if (activePeripheral == peripheral) {
            return;
        } else {
            [self disconnect];
        }
    }
    [blePacketQueue clear];
    
    NSLog(@"Connecting to peripheral with UUID : %@", peripheral.identifier.UUIDString);
    [CM connectPeripheral:peripheral options:nil];
}

- (CBPeripheral *) findPeripheralWithUUID:(NSString *) uuid {
    for (CBPeripheral * p in peripherals) {
        if ([p.identifier.UUIDString isEqualToString:uuid]) {
            return p;
        }
    }
    return nil;
}

- (void) connectWithUUID:(NSString *)peripheralUUID {
    CBPeripheral * peripheral = [self findPeripheralWithUUID:peripheralUUID];
    if (peripheral) {
        [self connect:peripheral];
    } else {
        [self disconnect];
    }
}

//convert CentralManger state to string
- (const char *) centralManagerStateToString:(NSUInteger)state {
    switch(state) {
        case CBManagerStateUnknown:
            return "State unknown (CBCentralManagerStateUnknown)";
        case CBManagerStateResetting:
            return "State resetting (CBCentralManagerStateUnknown)";
        case CBManagerStateUnsupported:
            return "State BLE unsupported (CBCentralManagerStateResetting)";
        case CBManagerStateUnauthorized:
            return "State unauthorized (CBCentralManagerStateUnauthorized)";
        case CBManagerStatePoweredOff:
            return "State BLE powered off (CBCentralManagerStatePoweredOff)";
        case CBManagerStatePoweredOn:
            return "State powered up and ready (CBCentralManagerStatePoweredOn)";
        default:
            return "State unknown";
    }
    return "Unknown state";
}

//utility
-(UInt16) swap:(UInt16)s {
    UInt16 temp = s << 8;
    temp |= (s >> 8);
    return temp;
}

-(CBUUID *) IntToCBUUID:(UInt16)val {
    val = [self swap:val];
    NSData *d = [NSData dataWithBytes:(char *)&val length:2];
    return [CBUUID UUIDWithData:d];
}

-(UInt16) CBUUIDToInt:(CBUUID *) UUID {
    char b1[16];
    [UUID.data getBytes:b1 length:16];
    return ((b1[0] << 8) | b1[1]);
}

//Find Service and Characteristic from uuid
-(CBService *) findServiceFromUUID:(CBUUID *)UUID p:(CBPeripheral *)p {
    
    for (CBService * s in p.services) {
        if ([s.UUID.data isEqualToData:UUID.data]) return s;
    }
    return nil; //Service not found on this peripheral
}

-(CBCharacteristic *) findCharacteristicFromUUID:(CBUUID *)UUID service:(CBService*)service {
    
    for (CBCharacteristic * c in service.characteristics) {
        if ([c.UUID.data isEqualToData:UUID.data]) return c;
    }
    return nil; //Characteristic not found on this service
}

-(CBCharacteristic *) getCharacteristicFromServiceUUID:(int)serviceUUID
                                    characteristicUUID:(int)characteristicUUID {
    
    if (![self isConnected]) return nil;
    
    CBUUID *su = [self IntToCBUUID:serviceUUID];
    CBUUID *cu = [self IntToCBUUID:characteristicUUID];
    
    CBService *service = [self findServiceFromUUID:su p:activePeripheral];
    if (!service) {
        NSLog(@"Could not find service with UUID %@ on peripheral with UUID %@", su.UUIDString, activePeripheral.identifier.UUIDString);
        return nil;
    }
    CBCharacteristic *characteristic = [self findCharacteristicFromUUID:cu service:service];
    if (!characteristic) {
        NSLog(@"Could not find characteristic with UUID %@ on service with UUID %@ on peripheral with UUID %@",
              cu.UUIDString, su.UUIDString, activePeripheral.identifier.UUIDString);
        return nil;
    }
    
    return characteristic;
}

/*--------------------------- CBCentralManagerDelegate protocol methods -------------------------------------*/
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    NSLog(@"Status of CoreBluetooth central manager changed %d (%s)\r\n",
          (int)central.state,
          [self centralManagerStateToString:central.state]);
    
    if ((needStartDiscovery) && (central.state == CBManagerStatePoweredOn)) {
        [self findBLEPeripheralsWithName:nameFindingBle];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    
    NSString *peripheralAdvertName = [advertisementData valueForKey:@"kCBAdvDataLocalName"];
    if (!peripheralAdvertName) return;
    
    NSLog(@"didDiscoverPeripheral %@", peripheralAdvertName);
    
    //check DSP Name
    if (([peripheralAdvertName isEqualToString:nameFindingBle]) ||
        ([nameFindingBle isEqualToString:@"ALL_PERIPHERAL"])){
        
        //check duplicate peripheral
        if ([self findPeripheralWithUUID:peripheral.identifier.UUIDString]) {
            NSLog(@"Skip duplicate peripheral.");
            return;
        }
        
        peripheral.delegate = self;
        [peripherals addObject:peripheral];
        NSLog(@"Add new CBPeripheral");
        
        if (_communicationDelegate) [_communicationDelegate keyfobDidFound:peripheral.identifier.UUIDString];
    }
    
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"Connection to peripheral with UUID : %@ successfull", peripheral.identifier.UUIDString);
    
    activePeripheral = peripheral;
    activePeripheral.delegate = self;
    
    CBUUID *su = [self IntToCBUUID:0xFFF0];
    [activePeripheral discoverServices:[NSArray arrayWithObject:su]];
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (self.communicationDelegate){
        [self.communicationDelegate keyfobDidFailConnect];
    }
    
    activePeripheral = nil;
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (activePeripheral){//re-connect
        [self connect:activePeripheral];
        activePeripheral = nil;
    }
    
    if (self.communicationDelegate){
        [self.communicationDelegate keyfobDidDisconnected];
    }
}

/*----------------------------- CBPeripheralDelegate protocol methods ---------------------------------------------------*/
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    if (!error) {
        NSLog(@"Characteristics of service with UUID : %@ found", service.UUID.UUIDString);
        for (CBCharacteristic *c in service.characteristics) {
            NSLog(@"%@", c.UUID.UUIDString);
        }
        
        //Enable FeedBack Info notification
        [self notification:0xFFF0 characteristicUUID:0xFFF2 on:YES];
        //Enable FeedBack Param Data notification
        [self notification:0xFFF0 characteristicUUID:0xFFF3 on:YES];
        
        if (self.communicationDelegate){
            [self.communicationDelegate keyfobDidConnected];
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
        for (CBService * s in peripheral.services) {
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
        NSLog(@"%@", error.localizedDescription);
    }
    
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"updateValueForCharacteristic failed !");
        return;
    }
    
    UInt16 characteristicUUID = [self CBUUIDToInt:characteristic.UUID];
    
    if ((characteristicUUID == 0xFFF2) || (characteristicUUID == 0xFFF3)) {
        if (self.communicationDelegate){
            [self.communicationDelegate keyfobDidUpdateValue:characteristic.value];
        }
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error {
    if (error) {
        NSLog(@"did write with error: %@", error.description);
    } else {
        NSLog(@"did write");
    }
    
    if (_communicationDelegate) {
        [_communicationDelegate keyfobDidWrite:[blePacketQueue getFirstPacket]
                                         error:error];
    }
    
    if ([self CBUUIDToInt:characteristic.UUID] != 0xFFF1) return;
    
    
    [blePacketQueue removeFirstPacket];
                
    if ([blePacketQueue size] != 0){// if queue isn`t empty
        //get first packet
        BlePacket *packet = [blePacketQueue getFirstPacket];
        //send packet
        [activePeripheral writeValue:packet.data forCharacteristic:packet.characteristic type:CBCharacteristicWriteWithResponse];

    }
        
    if (self.communicationDelegate){
        [self.communicationDelegate keyfobUpdatePacketLength:[blePacketQueue size]];
    }
        
    NSLog(@"didWriteValueForCharacteristic. packet queue = %d", [blePacketQueue size]);
    

}

@end
