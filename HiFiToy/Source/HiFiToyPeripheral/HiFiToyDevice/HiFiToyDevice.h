//
//  HiFiToyDevice.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 05/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HiFiToyPreset.h"

@interface HiFiToyDevice : NSObject <NSCoding>

//main property
@property NSString * uuid;
@property NSString * name;
@property uint32_t pairingCode;

//audio source
@property (nonatomic) PCM9211Source_t audioSource;
//energy config
@property (nonatomic) EnergyConfig_t energyConfig;

//preset property
@property (nonatomic)   NSString * activeKeyPreset;

//methods
- (void) setDefault;
- (HiFiToyPreset *) getActivePreset;
- (NSString *) getShortUUIDString;

- (void) checkPresetChecksum:(uint16_t) checksum;

- (void) sendAudioSource;
- (void) updateAudioSource;

- (void) sendEnergyConfig;
- (void) updateEnergyConfig;

- (void) restoreFactory;

@end
