//
//  HiFiToyPresetList.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 05/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HiFiToyPreset.h"

@interface HiFiToyPresetList : NSObject <NSCoding>

//preset property
@property (nonatomic) NSMutableDictionary *list;


//preset methods
+ (HiFiToyPresetList *)sharedInstance;

-(bool) openPresetListFromFile;
-(bool) savePresetListToFile;

-(NSUInteger) count;
-(void) removePresetWithKey:(NSString *)presetKey;
-(void) updatePreset:(HiFiToyPreset *)preset withKey:(NSString *)presetKey;
-(HiFiToyPreset *) getPresetWithKey:(NSString *)presetKey;

-(void) description;


@end
