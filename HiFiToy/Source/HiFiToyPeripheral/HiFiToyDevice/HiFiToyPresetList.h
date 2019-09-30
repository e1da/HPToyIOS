//
//  HiFiToyPresetList.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 05/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HiFiToyPreset.h"

#define PRESET_LIST_VERSION ((uint32_t)1)

@interface HiFiToyPresetList : NSObject

//preset methods
+ (HiFiToyPresetList *)sharedInstance;

- (NSUInteger) count;

- (BOOL) isPresetExist:(NSString *)presetName;
- (void) removePresetWithName:(NSString *)presetName;

- (void) setPreset:(HiFiToyPreset *)preset;
- (HiFiToyPreset *) presetWithIndex:(NSInteger)index;
- (HiFiToyPreset *) presetWithName:(NSString *)presetName;

- (void) importPresetFromUrl:(NSURL *)url checkName:(BOOL)checkName
               resultHandler:(void (^)(NSString * presetName, NSString * error))handler;
- (void) importPresetFromUrl:(NSURL *)url checkName:(BOOL)checkName;
- (void) importPresetFromData:(NSData *)data withName:(NSString *)name
                  checkName:(BOOL)checkName resultHandler:(void (^)(NSString * presetName, NSString * error))handler;
- (void) importPresetFromData:(NSData *)data withName:(NSString *)name checkName:(BOOL)checkName;

- (void) description;


@end
