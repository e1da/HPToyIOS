//
//  HiFiToyDeviceList.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 05/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HiFiToyDevice.h"

@interface HiFiToyDeviceList : NSObject <NSCoding>

@property (readonly) NSMutableDictionary *deviceList;

+ (HiFiToyDeviceList *)sharedInstance;

-(bool) openDeviceListFromFile;
-(bool) saveDeviceListToFile;

-(void) setDevice:(HiFiToyDevice *)device withUUID:(NSString*)UUIDString;
-(HiFiToyDevice *) getDeviceWithUUID:(NSString *)UUIDString;

-(void) description;

@end
