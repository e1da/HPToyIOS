//
//  HiFiToyDeviceList.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 05/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "HiFiToyDeviceList.h"

@implementation HiFiToyDeviceList

/*==========================================================================================
 NSCoding protocol implementation
 ==========================================================================================*/
- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.keyActiveDevice forKey:@"keyActiveDevice"];
    [encoder encodeObject:self.deviceList forKey:@"keyDeviceList"];
    
    
    
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _keyActiveDevice = [decoder decodeObjectForKey:@"keyActiveDevice"];
        _deviceList = [decoder decodeObjectForKey:@"keyDeviceList"];
    }
    return self;
}


-(bool) openDeviceListFromFile
{
    NSString *plistPath;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    plistPath = [rootPath stringByAppendingPathComponent:@"DeviceList.plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        
        NSData * data = [NSData dataWithContentsOfFile:plistPath];
        HiFiToyDeviceList * deviceListTemp = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        _keyActiveDevice = deviceListTemp.keyActiveDevice;
        _deviceList = deviceListTemp.deviceList;
        
        return YES;
    } else {
        
        return NO;
        
    }
    return YES;
}

-(bool) saveDeviceListToFile
{
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"DeviceList.plist"];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:plistPath]){
        [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"DeviceList" ofType:@"plist" ]toPath:plistPath error:nil];
    }
    
    // write back to file
    BOOL result = [NSKeyedArchiver archiveRootObject:self toFile:plistPath];
    
    return result;
}



/*------------------------------------- create method ----------------------------------*/
+ (HiFiToyDeviceList *)sharedInstance
{
    static HiFiToyDeviceList *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HiFiToyDeviceList alloc] init];
        // Do any other initialisation stuff here
        [sharedInstance openDeviceListFromFile];
    });
    return sharedInstance;
}

-(void)updateForUUID:(NSString*)UUIDString withDevice:(HiFiToyDevice*) device
{
    if (!_deviceList){
        _deviceList = [NSMutableDictionary dictionaryWithObject:device forKey:UUIDString];
    } else {
        [_deviceList setObject:device forKey:UUIDString];
    }
    
    [self saveDeviceListToFile];
    [self description];
}

/* return (null) if not exist */
-(HiFiToyDevice *)findNameForUUID:(NSString*)UUIDString
{
    return (HiFiToyDevice*)[_deviceList objectForKey:UUIDString];
    
}

-(HiFiToyDevice *)getActiveDevice
{
    return (HiFiToyDevice*)[_deviceList objectForKey:_keyActiveDevice];
}

-(HiFiToyDevice *)setActiveDeviceWithKey:(NSString *) keyDevice
{
    _keyActiveDevice = keyDevice;
    return [self getActiveDevice];
}

-(void) description{
    NSLog(@"================ DeviceList =======================");
    NSArray *keys = _deviceList.allKeys;
    for (int i = 0; i < _deviceList.count; i++){
        HiFiToyDevice *device = [_deviceList objectForKey:[keys objectAtIndex:i]];
        
        NSLog(@"%@ %@ %x", (NSString *)[keys objectAtIndex:i], device.name, device.pairingCode);
        
    }
}

- (NSString *) getActiveDeviceInfo
{
    if (_keyActiveDevice) {
        if (_keyActiveDevice.length > 15) {
            return [_keyActiveDevice substringFromIndex:(_keyActiveDevice.length - 15)];
        }
        return _keyActiveDevice;
    }
    return @"";
}


@end
