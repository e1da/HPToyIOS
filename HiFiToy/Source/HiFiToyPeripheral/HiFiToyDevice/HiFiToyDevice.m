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

-(void) checkPresetChecksum:(uint16_t) checksum {
    NSLog(@"Checksum app preset = %x, Peripheral preset = %x", self.preset.checkSum, checksum);
    
    if (self.preset.checkSum != checksum) {
        [[DialogSystem sharedInstance] showImportPresetDialog];
    } else {
        NSLog(@"Import and current presets are equals!");
    }
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
    self.activeKeyPreset = @"No processing";
    [[HiFiToyDeviceList sharedInstance] saveDeviceListToFile];
    
    if (![[HiFiToyControl sharedInstance] isConnected]) return;
    
    //show progress dialog
    [[DialogSystem sharedInstance] showProgressDialog:NSLocalizedString(@"Restore factory", @"")];

    //fill HiFiToyConfig_t structure
    HiFiToyPeripheral_t hiFiToyConfig;
    hiFiToyConfig.i2cAddr           = I2C_ADDR;
    hiFiToyConfig.successWriteFlag  = 0x00; //must be assign '0' before sendFactorySettings
    hiFiToyConfig.version           = PERIPHERAL_VERSION;
    hiFiToyConfig.pairingCode       = _pairingCode;
    hiFiToyConfig.audioSource       = _audioSource = PCM9211_USB_SOURCE;
    hiFiToyConfig.advertiseMode     = _advertiseMode = ADVERTISE_ALWAYS_ENABLED;
    
    [self setDefaultEnergyConfig];
    hiFiToyConfig.energy = _energyConfig;
    
    //TODO: fix this stupid code
    _outputMode = [[HiFiToyOutputMode alloc] init];
    hiFiToyConfig.outputType = (self.outputMode.value == BALANCE_OUT_MODE) ?
                                                        BALANCE_OUT_MODE : UNBALANCE_OUT_MODE;
    hiFiToyConfig.gainChannel3 = (self.outputMode.value == UNBALANCE_BOOST_OUT_MODE) ? 0x40 : 0;
    
    
    
    //store to peripheral first pat of HiFiToyPeripheral_t
    [[HiFiToyControl sharedInstance] sendBufToDsp:(uint8_t *)&hiFiToyConfig
                                       withLength:offsetof(HiFiToyPeripheral_t, biquadTypes)
                                       withOffset:0];
    
    //store second part of HiFiToyPeripheral_t and preset and setInitDsp
    [self.preset storeToPeripheral];
}

@end
