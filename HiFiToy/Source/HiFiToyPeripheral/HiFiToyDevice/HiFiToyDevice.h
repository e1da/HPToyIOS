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
@property NSString * name;
@property uint32_t pairingCode;

//preset property
@property (nonatomic)   NSString * activeKeyPreset;

//methods
- (void)loadDefaultDspDevice;

- (HiFiToyPreset *) getActivePreset;


@end
