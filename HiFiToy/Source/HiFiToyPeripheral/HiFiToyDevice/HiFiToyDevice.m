//
//  HiFiToyDevice.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 05/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "HiFiToyDevice.h"
#import "HiFiToyPresetList.h"
#import "DialogSystem.h"
#import "HiFiToyControl.h"

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
        self.uuid = [decoder decodeObjectForKey:@"uuid"];
        self.name = [decoder decodeObjectForKey:@"name"];
        self.pairingCode = [decoder decodeIntForKey:@"pairingCode"];
        self.activeKeyPreset = [decoder decodeObjectForKey:@"activeKeyPreset"];
        
        self.audioSource = PCM9211_USB_SOURCE;
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
    self.uuid = @"demo";
    self.name = @"Default";
    self.pairingCode = 0;
    self.activeKeyPreset = @"DefaultPreset";
    self.audioSource = PCM9211_USB_SOURCE;
}

- (HiFiToyPreset *) getActivePreset
{
    HiFiToyPreset * preset = [[HiFiToyPresetList sharedInstance] getPresetWithKey:self.activeKeyPreset];
    
    if (!preset){
        self.activeKeyPreset = @"DefaultPreset";
        preset = [[HiFiToyPresetList sharedInstance] getPresetWithKey:self.activeKeyPreset];
        
        if (!preset){
            preset = [HiFiToyPreset initDefaultPreset];
            [[HiFiToyPresetList sharedInstance] updatePreset:preset withKey:self.activeKeyPreset];
            preset = [[HiFiToyPresetList sharedInstance] getPresetWithKey:self.activeKeyPreset];
        }
    }
    return preset;
}

- (NSString *) getShortUUIDString {
    if (_uuid.length > 15) {
        return [_uuid substringFromIndex:(_uuid.length - 15)];
    }
    
    return _uuid;
}

-(void) checkPresetChecksum:(uint16_t) checksum {
    HiFiToyPreset * preset = [self getActivePreset];
    NSLog(@"Checksum app preset = %x, Peripheral preset = %x", preset.checkSum, checksum);
    
    if (preset.checkSum != checksum) {
        [[DialogSystem sharedInstance] showImportPresetDialog];
    } else {
        NSLog(@"Import and current presets are equals!");
    }
}

- (void) sendAudioSource {
 
    CommonPacket_t packet;
    packet.cmd = SET_AUDIO_SOURCE;
    packet.data[0] = _audioSource;
    
    NSData *data = [[NSData alloc] initWithBytes:&packet length:sizeof(CommonPacket_t)];
    [[HiFiToyControl sharedInstance] sendDataToDsp:data withResponse:YES];
}

- (void) updateAudioSource
{
    CommonPacket_t packet;
    
    packet.cmd = GET_AUDIO_SOURCE;
    
    NSData *data = [[NSData alloc] initWithBytes:&packet length:sizeof(CommonPacket_t)];
    [[HiFiToyControl sharedInstance] sendDataToDsp:data withResponse:YES];
}

@end
