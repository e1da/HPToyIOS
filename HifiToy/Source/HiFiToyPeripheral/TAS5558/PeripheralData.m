//
//  PeripheralData.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 28/05/2021.
//  Copyright © 2021 Kerosinn_OSX. All rights reserved.
//

#import "PeripheralData.h"
#import "TAS5558.h"

#define PERIPHERAL_CONFIG_LENGTH    0x24
#define BIQUAD_TYPE_OFFSET          0x18
#define PRESET_DATA_OFFSET          0x20

@implementation PeripheralData {
    NSArray<HiFiToyDataBuf *> * dataBufs;
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

        [self setDataBufs:[dev.preset getDataBufs]];
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
        [self setDataBufs:[preset getDataBufs]];
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

- (void) setDataBufs:(NSArray<HiFiToyDataBuf *> *)bufs {
    dataBufLength = bufs.count;
    dataBytesLength = [self calcDataBytesLength:dataBufs];
    
    dataBufs = bufs;
}

- (uint16_t) calcDataBytesLength:(NSArray<HiFiToyDataBuf *> *)dataBufs {
    uint16_t length = 0;
    
    for (HiFiToyDataBuf * db in dataBufs) {
        length += [[db binary] length];
    }
    
    return length + PERIPHERAL_CONFIG_LENGTH;

}

- (NSData *) getBinary {
    NSMutableData * data = [[NSMutableData alloc] init];
    
    //pointer to self, to PeripheralData.this
    uint8_t * headPointer = (uint8_t *)&self->i2cAddr;
    
    //append first 0x24 bytes
    [data appendBytes:headPointer length:PERIPHERAL_CONFIG_LENGTH];
    
    //append data bufs
    for (HiFiToyDataBuf * db in dataBufs) {
        [data appendData:[db binary]];
    }
    
    return data;
}

- (NSData *) getBiquadTypeBinary {
    return [[self getBinary] subdataWithRange:NSMakeRange(BIQUAD_TYPE_OFFSET, 7)];
}

- (NSData *) getPresetBinary {
    NSData * bin = [self getBinary];
    return [bin subdataWithRange:NSMakeRange(PRESET_DATA_OFFSET, bin.length - PRESET_DATA_OFFSET)];
}

- (void) export {
    HiFiToyControl * ctrl = [HiFiToyControl sharedInstance];
    
    if (![ctrl isConnected]) return;
    
    [ctrl sendBufToDsp:[self getBinary] withOffset:0];
    [ctrl sendWriteFlag:1];
    [ctrl setInitDsp];
    
}

- (void) exportPreset {
    HiFiToyControl * ctrl = [HiFiToyControl sharedInstance];
    
    if (![ctrl isConnected]) return;
    
    [ctrl sendWriteFlag:0];
    [ctrl sendBufToDsp:[self getBiquadTypeBinary] withOffset:BIQUAD_TYPE_OFFSET];
    [ctrl sendBufToDsp:[self getPresetBinary] withOffset:PRESET_DATA_OFFSET];
    [ctrl sendWriteFlag:1];
    [ctrl setInitDsp];
    
}

@end
