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
#import "AmMode.h"

@interface HiFiToyDevice : NSObject <NSCoding>

//main property
@property NSString * _Nonnull   uuid;
@property NSString * _Nonnull   name;
@property uint32_t              pairingCode;

//audio source
@property (nonatomic) PCM9211Source_t                           audioSource;
@property (nonatomic) EnergyConfig_t                            energyConfig;
@property (nonatomic) AdvertiseMode_t                           advertiseMode;
@property (nonatomic, readonly) HiFiToyOutputMode * _Nonnull    outputMode;
@property (nonatomic, readonly) AmMode * _Nonnull               amMode;

//preset property
@property (nonatomic) NSString * _Nonnull                   activeKeyPreset;
@property (nonatomic, readonly) HiFiToyPreset * _Nonnull    preset;

//check old or new hw
@property (getter=isPDV21Hw) BOOL                           newPDV21Hw;

//methods
- (void) setDefault;
- (NSString * _Nonnull) getShortUUIDString;

- (void) sendAudioSource;
- (void) updateAudioSource;

- (void) sendEnergyConfig;
- (void) updateEnergyConfig;

- (void) sendAdvertiseMode;
- (void) updateAdvertiseMode;

- (void) restoreFactory:(void (^ __nullable)(void))finishHandler;
- (void) importPreset:(void (^ __nullable)(void))finishHandler;

@end
