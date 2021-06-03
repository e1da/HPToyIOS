//
//  HiFiToyDevice.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 05/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "HiFiToyDevice.h"
#import "HiFiToyPresetList.h"
#import "HiFiToyDeviceList.h"
#import "DialogSystem.h"
#import "HiFiToyControl.h"
#import "TAS5558.h"
#import "PeripheralData.h"

@implementation HiFiToyDevice

/*==========================================================================================
 NSCoding protocol implementation
 ==========================================================================================*/
- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.uuid forKey:@"uuid"];
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeInt:self.pairingCode forKey:@"pairingCode"];
    [encoder encodeObject:self.activeKeyPreset forKey:@"activeKeyPreset"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        [self setDefault];
        
        self.uuid               = [decoder decodeObjectForKey:@"uuid"];
        self.name               = [decoder decodeObjectForKey:@"name"];
        self.pairingCode        = [decoder decodeIntForKey:@"pairingCode"];
        self.activeKeyPreset    = [decoder decodeObjectForKey:@"activeKeyPreset"];
    }
    return self;
}

-(id) init {
    self = [super init];
    if (self) {
        [self setDefault];
    }
    return self;
}

- (void) setDefault {
    self.uuid               = @"demo";
    self.name               = @"Default";
    self.pairingCode        = 0;
    self.activeKeyPreset    = @"No processing";
    self.audioSource        = PCM9211_USB_SOURCE;
    self.advertiseMode      = ADVERTISE_ALWAYS_ENABLED;
    [self setDefaultEnergyConfig];
    _outputMode             = [[HiFiToyOutputMode alloc] init];
    self.newPDV21Hw         = NO;
}

- (void) setDefaultEnergyConfig {
    _energyConfig.highThresholdDb = 0;
    _energyConfig.lowThresholdDb = -55;
    _energyConfig.auxTimeout120ms = 2500; // 2500 * 120ms = 300s = 5min
    _energyConfig.usbTimeout120ms = 0;
}

- (void) setActiveKeyPreset:(NSString *)activeKeyPreset {
    _activeKeyPreset = activeKeyPreset;
    
    _preset = [[HiFiToyPresetList sharedInstance] presetWithName:_activeKeyPreset];
    
    if (!_preset){
        _activeKeyPreset = @"No processing";
        _preset = [[HiFiToyPresetList sharedInstance] presetWithName:_activeKeyPreset];
        
        [[HiFiToyDeviceList sharedInstance] saveDeviceListToFile];
    }
    
}

- (NSString *) getShortUUIDString {
    if (_uuid.length > 15) {
        return [_uuid substringFromIndex:(_uuid.length - 15)];
    }
    
    return _uuid;
}

- (void) sendAudioSource {
    CommonPacket_t packet;
    packet.cmd = SET_AUDIO_SOURCE;
    packet.data[0] = _audioSource;
    
    [[HiFiToyControl sharedInstance] sendCommonPacketToDsp:&packet];
}

- (void) updateAudioSource {
    CommonPacket_t packet;
    packet.cmd = GET_AUDIO_SOURCE;
    
    [[HiFiToyControl sharedInstance] sendCommonPacketToDsp:&packet];
}

- (void) sendEnergyConfig {
    NSData *data = [[NSData alloc] initWithBytes:&_energyConfig length:sizeof(EnergyConfig_t)];
    [[HiFiToyControl sharedInstance] sendDataToDsp:data withResponse:YES];
}

//async request. need GetDataNotification implement
- (void) updateEnergyConfig {
    CommonPacket_t packet;
    packet.cmd = GET_ENERGY_CONFIG;
    
    [[HiFiToyControl sharedInstance] sendCommonPacketToDsp:&packet];
}

- (void) sendAdvertiseMode {
    CommonPacket_t packet;
    packet.cmd = SET_ADVERTISE_MODE;
    packet.data[0] = _advertiseMode;
    
    [[HiFiToyControl sharedInstance] sendCommonPacketToDsp:&packet];
}

- (void) updateAdvertiseMode {
    CommonPacket_t packet;
    packet.cmd = GET_ADVERTISE_MODE;
    
    [[HiFiToyControl sharedInstance] sendCommonPacketToDsp:&packet];
}

- (void) restoreFactory {
    //set default preset and save to file
    self.pairingCode        = 0;
    self.activeKeyPreset    = @"No processing";
    self.audioSource        = PCM9211_USB_SOURCE;
    self.advertiseMode      = ADVERTISE_ALWAYS_ENABLED;
    [self setDefaultEnergyConfig];
    _outputMode             = [[HiFiToyOutputMode alloc] init];
    
    [[HiFiToyDeviceList sharedInstance] saveDeviceListToFile];
    
    //store to peripheral
    PeripheralData * pd = [[PeripheralData alloc] initWithDevice:self];
    [pd exportWithDialog:NSLocalizedString(@"Restore factory", @"")];
}

- (void) importPreset:(void (^ __nullable)(void))finishHandler  {
    PeripheralData * pd = [[PeripheralData alloc] init];
    [pd importWithDialog:NSLocalizedString(@"Import Preset...", @"")
                 handler:^() {
        HiFiToyPreset * preset = [[HiFiToyPreset alloc] init];
        preset.presetName = [[NSDate date] descriptionWithLocale:[NSLocale systemLocale]];
        
        if ([preset importFromDataBufs:pd.dataBufs
                           biquadsType:[pd getBiquadTypeBinary]]) {
            
            //add new import preset to list and save
            [[HiFiToyPresetList sharedInstance] setPreset:preset];
            //set new active preset and save device
            self.activeKeyPreset = preset.presetName;
            [[HiFiToyDeviceList sharedInstance] saveDeviceListToFile];
            
        } else {
            [[DialogSystem sharedInstance] showAlert:@"Import preset is not success!"];
        }
        
        if (finishHandler) finishHandler();
    }];
}

@end
