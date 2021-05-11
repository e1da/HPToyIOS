//
//  HiFiToyPresetList.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 05/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "HiFiToyPresetList.h"
#import "DialogSystem.h"

@interface HiFiToyPresetList() {
    NSMutableArray * list;
    void (^didImportHandler)(NSString * presetName, NSString * error);
}
@end

@implementation HiFiToyPresetList

- (id) init {
    self = [super init];
    if (self) {
        [self openPresetListFromFile];
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

- (void) openPresetListFromFile {
    NSString * rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    NSString * plistPath = [rootPath stringByAppendingPathComponent:@"PresetList.plist"];
    
    list = [[NSMutableArray alloc] init];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath]){
        NSData * data = [NSData dataWithContentsOfFile:plistPath];
        list = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    
    if ([self isPresetExist:@"No processing"] == NO) {
        NSMutableArray * tempList = [list copy];
        
        [list addObject:[HiFiToyPreset getDefault]];
        [list addObjectsFromArray:[tempList copy]];
    }
    
    if ([self isFirstLaunchAfterUpdate]) {
        [self addOfficialPresets];
    }
    
}

-(BOOL) savePresetListToFile {
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    NSString *plistPath = [rootPath stringByAppendingPathComponent:@"PresetList.plist"];
    
    // write back to file
    return [NSKeyedArchiver archiveRootObject:list toFile:plistPath];
}

- (NSString *) getOfficialPresetPath {
    NSString * resourcePath = [[NSBundle mainBundle] resourcePath];
    return [resourcePath stringByAppendingPathComponent:@"official_presets"];
}

-(NSArray *) listOfficialPresets {
    NSString * path = [self getOfficialPresetPath];
    NSError * error;
    NSArray * directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
    
    NSMutableArray * presetNameArray = [[NSMutableArray alloc] init];
    
    if (error) {
        NSLog(@"%@", error.description);
        
    } else {
    
        //get preset name in alphabet order
        NSArray * sortedStrings = [directoryContents sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        for (int i = 0; i < sortedStrings.count; i++) {
            NSString * presetName = [sortedStrings objectAtIndex:i];
            [presetNameArray addObject:[[presetName componentsSeparatedByString:@"."] objectAtIndex:0]];
        }
        
        NSLog(@"%@", presetNameArray.description);
    }
    
    return presetNameArray;
}

- (void) addOfficialPresets {
    NSArray * presetNameArray = [self listOfficialPresets];
    
    if ((presetNameArray) && (presetNameArray.count > 0)) {
        for (NSString * presetName in presetNameArray) {
            
            //NOTE: app rewrites exist presets
            NSString * path = [NSString stringWithFormat:@"%@/%@.tpr", [self getOfficialPresetPath], presetName];
                
            if ([[NSFileManager defaultManager] fileExistsAtPath:path]){
                NSData * data = [NSData dataWithContentsOfFile:path];
                [self importPresetFromData:data withName:presetName checkName:NO resultHandler:nil];
                    
            } else {
                NSLog(@"%@ file not found", path);
            }
                
            
        }
    }
}

- (BOOL) isFirstLaunchAfterUpdate {
    NSString * s = [NSString stringWithFormat:@"presetListVersion_%d", PRESET_LIST_VERSION];
    
    if (![[NSUserDefaults standardUserDefaults] valueForKey:s]) {
        [[NSUserDefaults standardUserDefaults] setValue:@YES forKey:s];
        
        return YES;
    }
    return NO;
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

- (void) importPresetFromUrl:(NSURL *)url checkName:(BOOL)checkName
               resultHandler:(void (^)(NSString * presetName, NSString * error))handler {
    didImportHandler = handler;
    
    void (^h)(HiFiToyPreset *, NSString *) = ^(HiFiToyPreset * p, NSString * error) {
        if (error){
            NSLog(@"Add %@ official preset is not success.", p.presetName);
                            
        } else {
            [self setPreset:p];
            NSLog(@"Added %@ official preset.", p.presetName);
        }
        
        if (self->didImportHandler) self->didImportHandler(p.presetName, error);
    };
    
    HiFiToyPreset * preset = [HiFiToyPreset getDefault];
    [preset importFromXml:url checkName:checkName resultHandler:h];

}

- (void) importPresetFromUrl:(NSURL *)url checkName:(BOOL)checkName {
    [self importPresetFromUrl:url checkName:checkName resultHandler:^(NSString *presetName, NSString *error) {
        NSString * msg;
        
        if (error){
            msg = [NSString stringWithFormat:@"Import preset is not success. %@ error", error ];
            
        } else {
            msg = [NSString stringWithFormat:@"'%@' preset was successfully added.", presetName];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PresetImportXmlNotification" object:nil];
        }
        [[DialogSystem sharedInstance] showAlert:msg];
    }];
}

- (void) importPresetFromData:(NSData *)data withName:(NSString *)name
                  checkName:(BOOL)checkName resultHandler:(void (^)(NSString * presetName, NSString * error))handler {
    didImportHandler = handler;
    
    void (^h)(HiFiToyPreset *, NSString *) = ^(HiFiToyPreset * p, NSString * error) {
        if (error){
            NSLog(@"Add %@ official preset is not success.", name);
                            
        } else {
            [self setPreset:p];
            NSLog(@"Added %@ official preset.", name);
        }
        
        if (self->didImportHandler) self->didImportHandler(p.presetName, error);
    };
    
    HiFiToyPreset * preset = [HiFiToyPreset getDefault];
    [preset importFromXmlWithData:data withName:name checkName:checkName resultHandler:h];
 
}

- (void) importPresetFromData:(NSData *)data withName:(NSString *)name checkName:(BOOL)checkName {
    [self importPresetFromData:data withName:name checkName:checkName resultHandler:^(NSString *presetName, NSString *error) {
        NSString * msg;
        if (error){
            msg = [NSString stringWithFormat:@"Import preset is not success. %@ error", error ];
        } else {
            msg = [NSString stringWithFormat:@"'%@' preset was successfully added.", presetName];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PresetImportXmlNotification" object:nil];
                    
        }
        [[DialogSystem sharedInstance] showAlert:msg];
    }];
}

-(void) description{
    NSLog(@"================ PresetList =======================");
    for (int i = 0; i < list.count; i++) {
        HiFiToyPreset * p = [list objectAtIndex:i];
        NSLog(@"%d %@", i, p.presetName);
    }
}

@end
