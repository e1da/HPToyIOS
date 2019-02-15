//
//  HiFiToyPresetList.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 05/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "HiFiToyPresetList.h"

@implementation HiFiToyPresetList

/*==========================================================================================
 NSCoding protocol implementation
 ==========================================================================================*/
- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.list forKey:@"keyPresetList"];
    
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        _list = [decoder decodeObjectForKey:@"keyPresetList"];
    }
    return self;
}


-(bool) openPresetListFromFile
{
    NSString *plistPath;
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    //NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    plistPath = [rootPath stringByAppendingPathComponent:@"PresetList.plist"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath]) {
        
        NSData * data = [NSData dataWithContentsOfFile:plistPath];
        HiFiToyPresetList * presetListTemp = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        _list = presetListTemp.list;
        
        return YES;
    } else {
        /*UIAlertView *FeedBackAlert = [[UIAlertView alloc] initWithTitle:@"Confirm"
         message:@"Data No Exist!"
         delegate:self
         cancelButtonTitle:@"Ok"
         otherButtonTitles:nil];
         [FeedBackAlert show];*/
        
        
        return NO;
        
    }
    return YES;
}

-(bool) savePresetListToFile
{
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"PresetList.plist"];
    
    if(![[NSFileManager defaultManager] fileExistsAtPath:plistPath]){
        [[NSFileManager defaultManager] copyItemAtPath:[[NSBundle mainBundle] pathForResource:@"PresetList" ofType:@"plist" ]toPath:plistPath error:nil];
    }
    
    // write back to file
    BOOL result = [NSKeyedArchiver archiveRootObject:self toFile:plistPath];
    
    return result;
}



/*---------------------------------------------------------------------------------------
 PUBLIC METHODS
 --------------------------------------------------------------------------------------*/
+ (HiFiToyPresetList *)sharedInstance
{
    static HiFiToyPresetList *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HiFiToyPresetList alloc] init];
        // Do any other initialisation stuff here
        [sharedInstance openPresetListFromFile];
    });
    return sharedInstance;
}

-(NSUInteger) count
{
    return self.list.count;
}

-(void) removePresetWithKey:(NSString *)presetKey
{
    [self.list removeObjectForKey:presetKey];
    [self savePresetListToFile];
}

-(void) updatePreset:(HiFiToyPreset *)preset withKey:(NSString *)presetKey
{
    if (!self.list){
        self.list = [NSMutableDictionary dictionaryWithObject:[preset copy] forKey:presetKey];
    } else {
        [self.list setObject:[preset copy] forKey:presetKey];
    }
    
    [self savePresetListToFile];
}

-(HiFiToyPreset *) getPresetWithKey:(NSString *)presetKey{
    if (!self.list) [self openPresetListFromFile];

    return (HiFiToyPreset*)[self.list objectForKey:presetKey];
}

-(void) description{
    NSLog(@"================ PresetList =======================");
    NSArray *keys = _list.allKeys;
    for (int i = 0; i < _list.count; i++){
        HiFiToyPreset *preset = [_list objectForKey:[keys objectAtIndex:i]];
        
        NSLog(@"%@ %@", (NSString *)[keys objectAtIndex:i], preset.presetName);
        
    }
}

@end
