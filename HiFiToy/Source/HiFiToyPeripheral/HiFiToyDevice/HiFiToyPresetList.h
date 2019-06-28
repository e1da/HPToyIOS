//
//  HiFiToyPresetList.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 05/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HiFiToyPreset.h"

@interface HiFiToyPresetList : NSObject

//preset methods
+ (HiFiToyPresetList *)sharedInstance;

-(NSUInteger) count;

-(BOOL) isPresetExist:(NSString *)presetName;
-(void) removePresetWithName:(NSString *)presetName;

-(void) setPreset:(HiFiToyPreset *)preset;
-(HiFiToyPreset *) presetWithIndex:(NSInteger)index;
-(HiFiToyPreset *) presetWithName:(NSString *)presetName;

-(void) description;


@end
