//
//  HiFiToyDevice.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 05/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "HiFiToyDevice.h"
#import "HiFiToyPresetList.h"

@implementation HiFiToyDevice

/*==========================================================================================
 NSCoding protocol implementation
 ==========================================================================================*/
- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeInt:self.pairingCode forKey:@"pairingCode"];
    [encoder encodeObject:self.activeKeyPreset forKey:@"activeKeyPreset"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    if (self) {
        self.name = [decoder decodeObjectForKey:@"name"];
        self.pairingCode = [decoder decodeIntForKey:@"pairingCode"];
        self.activeKeyPreset = [decoder decodeObjectForKey:@"activeKeyPreset"];
    }
    return self;
}

- (void) loadDefaultDspDevice{
    self.name = @"Default";
    self.pairingCode = 0;
    self.activeKeyPreset = @"DefaultPreset";
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


@end
