//
//  PeripheralData.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 28/05/2021.
//  Copyright © 2021 Kerosinn_OSX. All rights reserved.
//

#import "BiquadParam.h"
#import "HiFiToyDataBuf.h"
#import "HiFiToyDevice.h"
#import "HiFiToyControl.h"
#import "PeripheralDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface PeripheralData : NSObject {
    uint8_t             i2cAddr;            // 0x00
    uint8_t             successWriteFlag;   // 0x01
    uint16_t            version;            // 0x02
    uint32_t            pairingCode;        // 0x04
    uint8_t             initDspDelay;       // 0x08
    AdvertiseMode_t     advertiseMode;      // 0x09
    uint16_t            gainChannel3;       // 0x0A number format = 1.15 unsign
    EnergyConfig_t      energy;             // 0x0C
    BiquadType_t        biquadTypes[7];     // 0x18
    uint8_t             outputMode;         // 0x1F balance/unbalance
    
    uint16_t            dataBufLength;      // 0x20
    uint16_t            dataBytesLength;    // 0x22
    DataBufHeader_t     firstDataBuf;       // 0x24
}

- (id) init;
- (id) initWithDevice:(HiFiToyDevice *)dev;
- (id) initWithPreset:(HiFiToyPreset *)preset;

- (void) clear;

- (void) export;
- (void) exportPreset;

@end

NS_ASSUME_NONNULL_END
