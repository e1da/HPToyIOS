//
//  BleDriver.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 05/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef enum : uint8_t {
    ESTABLISH_PAIR      = 0x00,
    SET_PAIR_CODE       = 0x01,
    SET_WRITE_FLAG      = 0x02,
    GET_WRITE_FLAG      = 0x03,
    GET_VERSION         = 0x04,
    GET_CHECKSUM        = 0x05,
    INIT_DSP            = 0x06,
    SET_AUDIO_SOURCE    = 0x07,
    GET_AUDIO_SOURCE    = 0x08,
    
    //feedback msg
    CLIP_DETECTION              = 0xFD,
    OTW_DETECTION               = 0xFE,
    PARAM_CONNECTION_ENABLED    = 0xFF
    
} CommonCmd_t;

typedef struct {
    uint8_t cmd;
    uint8_t data[4];
} CommonPacket_t;

typedef struct {
    uint8_t addr;
    uint8_t length;
    uint8_t data[18];
} Packet_t;

typedef enum : uint8_t {
    PAIR_NO, PAIR_YES
} PairStatus_t;

/*--------------------------- TIBleCommunicationDelegate Protocol ----------------------------------------*/
@protocol BleCommunicationDelegate

-(void) keyfobDidFound;

- (void) keyfobMacAddrError;

-(void) keyfobDidConnected;
-(void) keyfobDidFailConnect;
-(void) keyfobDidDisconnected;

-(void) keyfobDidWriteValue:(uint)remainPacketLength;
-(void) keyfobDidUpdateValue:(NSData *) value;

@end


/*----------------------------- BleDriver Interface -----------------------------------------------------*/
@interface BleDriver : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic,assign) id <BleCommunicationDelegate> communicationDelegate;

@property (nonatomic, readonly) NSMutableArray * peripherals;
@property (nonatomic, readonly) CBPeripheral * activePeripheral;

-(void) writeValue:(int)serviceUUID characteristicUUID:(int)characteristicUUID data:(NSData *)data response:(BOOL)response;
-(void) readValue: (int)serviceUUID characteristicUUID:(int)characteristicUUID;
-(void) notification:(int)serviceUUID characteristicUUID:(int)characteristicUUID on:(BOOL)on;

-(int)  findBLEPeripheralsWithName:(NSString*)name;
-(void) stopFindBLEPeripherals;

-(void) connectPeripheral:(CBPeripheral *)peripheral;
-(void) disconnectPeripheral;

-(BOOL) isConnected;

@end
