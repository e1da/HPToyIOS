//
//  HiFiToyDeviceList.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 05/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "HiFiToyDeviceList.h"

@implementation HiFiToyDeviceList

- (id) init {
    self = [super init];
    if (self) {
        if ([self openDeviceListFromFile]) {
            if (![self getDeviceWithUUID:@"demo"]) {
                HiFiToyDevice * device = [[HiFiToyDevice alloc] init];
                [self setDevice:device withUUID:device.uuid];
            }
        } else {
            HiFiToyDevice * device = [[HiFiToyDevice alloc] init];
            [self setDevice:device withUUID:device.uuid];
        }
    }
    
    return self;
}
/*==========================================================================================
 NSCoding protocol implementation
 ==========================================================================================*/
- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.deviceList forKey:@"keyDeviceList"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
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
    if (![[NSFileManager defaultManager] fileExistsAtPath:plistPath]) return NO;
        
    NSData * data = [NSData dataWithContentsOfFile:plistPath];
    HiFiToyDeviceList * deviceListTemp = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    _deviceList = deviceListTemp.deviceList;

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
    });
    return sharedInstance;
}

-(void) setDevice:(HiFiToyDevice *)device withUUID:(NSString*)UUIDString
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
-(HiFiToyDevice *)getDeviceWithUUID:(NSString*)UUIDString
{
    return (HiFiToyDevice*)[_deviceList objectForKey:UUIDString];
    
}

-(void) description{
    NSLog(@"================ DeviceList =======================");
    NSArray *keys = _deviceList.allKeys;
    for (int i = 0; i < _deviceList.count; i++){
        HiFiToyDevice *device = [_deviceList objectForKey:[keys objectAtIndex:i]];
        
        NSLog(@"%@ %@ %x", (NSString *)[keys objectAtIndex:i], device.name, device.pairingCode);
        
    }
}


@end
