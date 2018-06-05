//
//  BlePacket.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 05/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "BlePacket.h"

@implementation BlePacket

+ (BlePacket *)initWithPacket:(CBCharacteristic*)characteristic data:(NSData*)data response:(BOOL)response
{
    BlePacket *blePacket = [[BlePacket alloc] init];
    blePacket.characteristic = characteristic;
    blePacket.data = data;
    blePacket.response = response;
    
    return blePacket;
}


- (NSString*)description
{
    return [NSString stringWithFormat:@"Ble Packet with characteristic UUID %@ and data %@ and response = %d",
            self.characteristic.description,
            self.data.description,
            (int)self.response];
}

@end
