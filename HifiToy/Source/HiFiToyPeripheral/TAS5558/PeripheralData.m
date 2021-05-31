//
//  PeripheralData.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 28/05/2021.
//  Copyright © 2021 Kerosinn_OSX. All rights reserved.
//

#import "PeripheralData.h"
#import "TAS5558.h"

@implementation PeripheralData {
    NSMutableArray * dataBufs;
}

- (id) init {
    self = [super init];
    if (self) {
        [self clear];
    }
    return self;
}

- (id) initWithDevice:(HiFiToyDevice *) dev {
    self = [super init];
    if (self) {
        [self clear];
        
        pairingCode     = dev.pairingCode;
        advertiseMode   = dev.advertiseMode;
        
        gainChannel3    = [dev.outputMode getGainCh3];
        energy          = dev.energyConfig;
        
        BiquadType_t types[7];
        [dev.preset.filters getBiquadTypes:types]; // get 7 BiquadTypes
        memcpy(biquadTypes, types, 7 * sizeof(BiquadType_t));
        
        outputMode      = [dev.outputMode isUnbalance] ? 1 : 0;
        
        //List<HiFiToyDataBuf> dataBufs = device.getActivePreset().getDataBufs();
        //appendAmModeDataBuf(dataBufs, device.getAmMode(), device.isNewPDV21Hw());

        //setDataBufs(dataBufs);
    }
    return self;
}

- (id) initWithPreset:(HiFiToyPreset *) preset {
    self = [super init];
    if (self) {
        [self clear];
        
        BiquadType_t types[7];
        [preset.filters getBiquadTypes:types]; // get 7 BiquadTypes
        memcpy(biquadTypes, types, 7 * sizeof(BiquadType_t));
        
        HiFiToyDevice * dev = [[HiFiToyControl sharedInstance] activeHiFiToyDevice];
        outputMode          = [dev.outputMode isUnbalance] ? 1 : 0;
        
        
        //appendAmModeDataBuf(dataBufs, dev.getAmMode(), dev.isNewPDV21Hw());

        //setDataBufs(dataBufs);
    }
    return self;
}

- (void) clear {
    i2cAddr             = I2C_ADDR;
    successWriteFlag    = 0;
    version             = PERIPHERAL_VERSION;
    pairingCode         = 0;
    initDspDelay        = INIT_DSP_DELAY;
    advertiseMode       = ADVERTISE_ALWAYS_ENABLED;

    HiFiToyOutputMode * om = [[HiFiToyOutputMode alloc] init];
    gainChannel3        = [om getGainCh3]; // 0x4000
    
    energy.highThresholdDb = ENERGY_CORRECT_HIGH_THRES_COEF;    // 0
    energy.lowThresholdDb  = -55;  // -55
    energy.auxTimeout120ms = 2500; // 2500 * 120ms = 300s = 5min
    energy.usbTimeout120ms = 0;    // not used
    
    memset(biquadTypes, BIQUAD_PARAMETRIC, sizeof(biquadTypes)); // all biquads = PARAMETRIC
    outputMode = [om isUnbalance] ? 1 : 0;

    dataBufLength   = 0;
    dataBytesLength = 0;
    
    dataBufs = [[NSMutableArray alloc] init];
}


@end
