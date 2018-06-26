//
//  BlePacketQueue.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 05/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BlePacket.h"

@interface BlePacketQueue : NSObject{
    NSMutableArray *blePacketsArray;
    
}

- (void) clear;
- (int) size;

- (void) addPacket:(BlePacket*)blePacket;
- (void) addPacketWithCharacteristic:(CBCharacteristic*)characteristic
                                data:(NSData *)data
                            response:(BOOL)response;



- (BlePacket *) getFirstPacket;
- (void) removeFirstPacket;

- (void) print;

//- (void) testModule;

@end
