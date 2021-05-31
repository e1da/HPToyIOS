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

#pragma pack(1)
typedef struct {                            // offset
    uint8_t             i2cAddr;            // 0x00
    uint8_t             successWriteFlag;   // 0x01
    uint16_t            version;            // 0x02
    uint32_t            pairingCode;        // 0x04
    PCM9211Source_t     audioSource;        // 0x08
    AdvertiseMode_t     advertiseMode;      // 0x09
    uint16_t            gainChannel3;       // 0x0A number format = 1.15 unsign
    EnergyConfig_t      energy;             // 0x0C
    BiquadType_t        biquadTypes[7];     // 0x18
    uint8_t             outputType;         // 0x1F balance/unbalance

    uint16_t            dataBufLength;      // 0x20
    uint16_t            dataBytesLength;    // 0x22
    DataBufHeader_t     firstDataBuf;       // 0x24
} HiFiToyPeripheral_t;                      // size = 38dec
#pragma options align=reset

#endif /* PeripheralDefines_h */
