//
//  HiFiToyDevice.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 05/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HiFiToyPreset.h"
#import "HiFiToyOutputMode.h"
#import "PeripheralDefines.h"

@interface HiFiToyDevice : NSObject <NSCoding>

//main property
@property NSString *    uuid;
@property NSString *    name;
@property uint32_t      pairingCode;

//audio source
@property (nonatomic) PCM9211Source_t               audioSource;
@property (nonatomic) EnergyConfig_t                energyConfig;
@property (nonatomic) AdvertiseMode_t               advertiseMode;
@property (nonatomic, readonly) HiFiToyOutputMode * outputMode;


//preset property
@property (nonatomic)               NSString        * activeKeyPreset;
@property (nonatomic, readonly)     HiFiToyPreset   * preset;

//methods
- (void) setDefault;
- (NSString *) getShortUUIDString;

- (void) changeKeyPreset:(NSString *)key;

- (void) checkPresetChecksum:(uint16_t) checksum;

- (void) sendAudioSource;
- (void) updateAudioSource;

- (void) sendEnergyConfig;
- (void) updateEnergyConfig;

- (void) sendAdvertiseMode;
- (void) updateAdvertiseMode;

- (void) restoreFactory;

@end
