//
//  BleDriver.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 05/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "BlePacketQueue.h"

/*--------------------------- TIBleCommunicationDelegate Protocol ----------------------------------------*/
@protocol BleCommunicationDelegate

-(void) keyfobDidFound:(NSString *)peripheralUUID;

-(void) keyfobDidConnected;
-(void) keyfobDidFailConnect;
-(void) keyfobDidDisconnected;

-(void) keyfobDidWrite:(BlePacket *)p error:(NSError *)error;
-(void) keyfobDidUpdateValue:(NSData *)value;

-(void) keyfobUpdatePacketLength:(uint)remainPacketLength;

@end


/*----------------------------- BleDriver Interface -----------------------------------------------------*/
@interface BleDriver : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (nonatomic,assign) id <BleCommunicationDelegate> communicationDelegate;

-(void) writeValue:(int)serviceUUID characteristicUUID:(int)characteristicUUID data:(NSData *)data response:(BOOL)response;
-(void) readValue: (int)serviceUUID characteristicUUID:(int)characteristicUUID;
-(void) notification:(int)serviceUUID characteristicUUID:(int)characteristicUUID on:(BOOL)on;

-(int)  findBLEPeripheralsWithName:(NSString*)name;
-(void) stopFindBLEPeripherals;

-(void) disconnect;
-(void) connectWithUUID:(NSString *)peripheralUUID;

-(BOOL) isConnected;

@end
