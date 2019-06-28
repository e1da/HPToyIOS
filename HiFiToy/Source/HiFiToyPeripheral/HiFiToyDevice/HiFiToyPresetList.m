//
//  HiFiToyPresetList.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 05/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "HiFiToyPresetList.h"

@interface HiFiToyPresetList() {
    NSMutableArray * list;
}
@end

@implementation HiFiToyPresetList

- (id) init {
    self = [super init];
    if (self) {
        list = [[NSMutableArray alloc] init];
        
        //if default preset not exists then create
        if ( (![self openPresetListFromFile]) || ([self isPresetExist:@"No processing"] == NO) ) {
            [self setPreset:[HiFiToyPreset getDefault]];
        }
    }
    return self;
}

+ (HiFiToyPresetList *)sharedInstance {
    static HiFiToyPresetList *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HiFiToyPresetList alloc] init];
    });
    return sharedInstance;
}

-(BOOL) openPresetListFromFile {
    NSString *plistPath;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    //NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    plistPath = [rootPath stringByAppendingPathComponent:@"PresetList.plist"];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:plistPath]){
        [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"PresetList" ofType:@"plist" ]toPath:plistPath error:nil];
    }
    
    //if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        
        NSData * data = [NSData dataWithContentsOfFile:plistPath];
        list = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        return YES;
    //}
    
    //return NO;
}

-(BOOL) savePresetListToFile {
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

-(BOOL) isPresetExist:(NSString *)presetName {
    for (HiFiToyPreset * preset in list) {
        if ([preset.presetName isEqualToString:presetName]) return YES;
    }
    return NO;
}

-(void) removePresetWithName:(NSString *)presetName {
    for (int i = 0 ; i < list.count; i++) {
        HiFiToyPreset * p = [list objectAtIndex:i];
        if ([p.presetName isEqualToString:presetName]) {
            [list removeObjectAtIndex:i];
            [self savePresetListToFile];
            break;
        }
    }
}

-(void) setPreset:(HiFiToyPreset *)preset {
    for (int i = 0; i < list.count; i++) {
        HiFiToyPreset * p = [list objectAtIndex:i];
        if ([p.presetName isEqualToString:preset.presetName]) {
            [list replaceObjectAtIndex:i withObject:[preset copy]];
            [self savePresetListToFile];
            return;
        }
    }
    
    [list addObject:[preset copy]];
    [self savePresetListToFile];
}

-(HiFiToyPreset *) presetWithIndex:(NSInteger)index {
    return [[list objectAtIndex:index] copy];
}

-(HiFiToyPreset *) presetWithName:(NSString *)presetName {
    for (HiFiToyPreset * preset in list) {
        if ([preset.presetName isEqualToString:presetName]) {
            return [preset copy];
        }
    }
    return nil;
}

-(void) description{
    NSLog(@"================ PresetList =======================");
    for (int i = 0; i < list.count; i++) {
        HiFiToyPreset * p = [list objectAtIndex:i];
        NSLog(@"%d %@", i, p.presetName);
    }
}

@end
