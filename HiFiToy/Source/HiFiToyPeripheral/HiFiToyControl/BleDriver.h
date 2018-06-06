//
//  BleDriver.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 05/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

typedef enum {
    BLE_DISCONNECTED, BLE_DISCOVERING, BLE_CONNECTING, BLE_CONNECTED
} BleState_t;

typedef enum : uint8_t {
    ESTABLISH_PAIR = 0x0,
    SET_PAIR_CODE = 0x1,
    SET_WRITE_FLAG = 0x2,
    GET_WRITE_FLAG = 0x3,
    GET_CHECKSUM = 0x4,
    INIT_DSP = 0x5,
    
    //feedback msg
    CLIP_DETECTION = 0xFD,
    OTW_DETECTION = 0xFE,
    PARAM_CONNECTION_ENABLED = 0xFF
    
} TestCmd_t;

typedef enum : uint8_t {
    PAIR_NO, PAIR_YES
} PairStatus_t;

/*--------------------------- TIBleCommunicationDelegate Protocol ----------------------------------------*/
@protocol BleCommunicationDelegate

-(void) keyfobDidFound;

-(void) keyfobDidPaired;
-(void) keyfobPairingFail;
-(void) keyfobPairingOk;

-(void) keyfobDspVersionFail;
-(void) keyfobDspVersionOk;

-(void) keyfobFirmwareOk;
-(void) keyfobFirmwareFail;

-(void) keyfobReadyWithChecksum:(uint64_t)checksum;

-(void) keyfobDisconnected:(NSString *)causeDisconectedString;

@end

/*----------------------------- FeedBackParamDataDelegate Protocol ---------------------------------------*/
@protocol FeedBackParamDataDelegate
//nsdata length == 20
-(void) getParamDataDelegate:(NSData *)data;

@end

/*----------------------------- BleDriver Interface -----------------------------------------------------*/
@interface BleDriver : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic,assign) id <BleCommunicationDelegate> communicationDelegate;
@property (nonatomic,assign) id <FeedBackParamDataDelegate> paramDataDelegate;

@property (nonatomic, readonly) BleState_t state;

@property (nonatomic, readonly) NSMutableArray * peripherals;
@property (nonatomic, readonly) CBPeripheral * activePeripheral;

-(void) writeValue:(int)serviceUUID characteristicUUID:(int)characteristicUUID data:(NSData *)data response:(BOOL)response;
-(void) readValue: (int)serviceUUID characteristicUUID:(int)characteristicUUID;
-(void) notification:(int)serviceUUID characteristicUUID:(int)characteristicUUID on:(BOOL)on;

-(NSString *) getUUIDString;
-(BOOL) isConnected;

@end
