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
-(NSArray *) getValues;
-(NSArray *) getKeys;
-(void) removePresetWithKey:(NSString *)presetKey;
-(void) updatePreset:(HiFiToyPreset *)preset withKey:(NSString *)presetKey;
-(HiFiToyPreset *) getPresetWithKey:(NSString *)presetKey;
-(BOOL) isPresetExist:(NSString *)presetKey;

-(void) description;


@end
