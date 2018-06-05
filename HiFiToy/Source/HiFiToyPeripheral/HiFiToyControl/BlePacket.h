//
//  BlePacket.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 05/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface BlePacket : NSObject

@property CBCharacteristic* characteristic;
@property NSData*           data;
@property BOOL              response;

+ (BlePacket*) initWithPacket:(CBCharacteristic*)characteristic data:(NSData*)data response:(BOOL)response;

- (NSString*)description;

@end
