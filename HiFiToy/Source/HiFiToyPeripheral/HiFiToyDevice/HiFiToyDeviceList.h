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

@property (readonly) NSString * keyActiveDevice;
@property (readonly) NSMutableDictionary *deviceList;

+ (HiFiToyDeviceList *)sharedInstance;

-(bool) openDeviceListFromFile;
-(bool) saveDeviceListToFile;

-(void)updateForUUID:(NSString*)UUIDString withDevice:(HiFiToyDevice*) device;
-(HiFiToyDevice *)findNameForUUID:(NSString*)UUIDString;

-(HiFiToyDevice *)getActiveDevice;
-(HiFiToyDevice *)setActiveDeviceWithKey:(NSString *) keyDevice;

-(void) description;

@end
