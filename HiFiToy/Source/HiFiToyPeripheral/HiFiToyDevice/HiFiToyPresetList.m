//
//  HiFiToyPresetList.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 05/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "HiFiToyPresetList.h"

@interface HiFiToyPresetList() {
    NSMutableDictionary *list;
}
@end

@implementation HiFiToyPresetList

- (id) init {
    self = [super init];
    if (self) {
        list = [[NSMutableDictionary alloc] init];
        
        //if default preset not exists then create
        if ( (![self openPresetListFromFile]) || (![self getPresetWithKey:@"DefaultPreset"]) ) {
            HiFiToyPreset * p = [HiFiToyPreset getDefault];
            [self updatePreset:p withKey:@"DefaultPreset"];
        }
    }
    return self;
}

+ (HiFiToyPresetList *)sharedInstance
{
    static HiFiToyPresetList *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HiFiToyPresetList alloc] init];
    });
    return sharedInstance;
}

-(BOOL) openPresetListFromFile
{
    NSString *plistPath;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    //NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    plistPath = [rootPath stringByAppendingPathComponent:@"PresetList.plist"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        
        NSData * data = [NSData dataWithContentsOfFile:plistPath];
        list = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return YES;
    }
    
    return NO;
}

-(BOOL) savePresetListToFile
{
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"PresetList.plist"];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:plistPath]){
        [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"PresetList" ofType:@"plist" ]toPath:plistPath error:nil];
    }
    
    // write back to file
    BOOL result = [NSKeyedArchiver archiveRootObject:list toFile:plistPath];
    
    return result;
}



/*---------------------------------------------------------------------------------------
 PUBLIC METHODS
 --------------------------------------------------------------------------------------*/
-(NSUInteger) count {
    return list.count;
}

-(NSArray *) getValues {
    return list.allValues;
}

-(NSArray *) getKeys {
    return list.allKeys;
}

-(void) removePresetWithKey:(NSString *)presetKey
{
    [self openPresetListFromFile];
    [list removeObjectForKey:presetKey];
    [self savePresetListToFile];
}

-(void) updatePreset:(HiFiToyPreset *)preset withKey:(NSString *)presetKey {
    [self openPresetListFromFile];
    [list setObject:[preset copy] forKey:presetKey];
    [self savePresetListToFile];
}

-(HiFiToyPreset *) getPresetWithKey:(NSString *)presetKey{
    return [list objectForKey:presetKey];
}

-(void) description{
    NSLog(@"================ PresetList =======================");
    NSArray *keys = list.allKeys;
    for (int i = 0; i < list.count; i++){
        HiFiToyPreset *preset = [list objectForKey:[keys objectAtIndex:i]];
        
        NSLog(@"%@ %@", (NSString *)[keys objectAtIndex:i], preset.presetName);
    }
}

@end
