//
//  PeripheralDefines.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 28/05/2021.
//  Copyright © 2021 Kerosinn_OSX. All rights reserved.
//

#ifndef PeripheralDefines_h
#define PeripheralDefines_h

#import "HiFiToyDataBuf.h"
#import "BiquadParam.h"
#import "TAS5558.h"

#define PERIPHERAL_VERSION      11
#define INIT_DSP_DELAY          32; // 32 << 3 = 256ms

typedef enum : uint8_t {
    PCM9211_SPDIF_SOURCE, PCM9211_USB_SOURCE, PCM9211_BT_SOURCE,
} PCM9211Source_t;

typedef enum : uint8_t {
    ADVERTISE_ALWAYS_ENABLED, ADVERTISE_AFTER_1MIN_DISABLED
} AdvertiseMode_t;

#define ENERGY_CORRECT_HIGH_THRES_COEF 4.8f

#pragma pack(1)
typedef struct {
    float       highThresholdDb;
    float       lowThresholdDb;
    uint16_t    auxTimeout120ms;
    uint16_t    usbTimeout120ms;
} EnergyConfig_t;
#pragma options align=reset

#endif /* PeripheralDefines_h */
