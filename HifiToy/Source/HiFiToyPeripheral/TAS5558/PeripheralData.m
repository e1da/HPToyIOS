//
//  PeripheralData.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 28/05/2021.
//  Copyright © 2021 Kerosinn_OSX. All rights reserved.
//

#import "PeripheralData.h"
#import "HiFiToyControl.h"
#import "DialogSystem.h"

#define PERIPHERAL_CONFIG_LENGTH    0x24
#define BIQUAD_TYPE_OFFSET          0x18
#define PRESET_DATA_OFFSET          0x20

@implementation PeripheralData {
    NSArray<HiFiToyDataBuf *> * dataBufs;
    NSMutableData * importData;
    
    void (^finishHandler)(void);
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
        
        header.pairingCode     = dev.pairingCode;
        header.advertiseMode   = dev.advertiseMode;
        
        header.gainChannel3    = [dev.outputMode getGainCh3];
        header.energy          = dev.energyConfig;
        
        BiquadType_t types[7];
        [dev.preset.filters getBiquadTypes:types]; // get 7 BiquadTypes
        memcpy(header.biquadTypes, types, 7 * sizeof(BiquadType_t));
        
        header.outputMode      = [dev.outputMode isUnbalance] ? 1 : 0;
        
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
        memcpy(header.biquadTypes, types, 7 * sizeof(BiquadType_t));
        
        HiFiToyDevice * dev = [[HiFiToyControl sharedInstance] activeHiFiToyDevice];
        header.outputMode   = [dev.outputMode isUnbalance] ? 1 : 0;
        
        //appendAmModeDataBuf(dataBufs, dev.getAmMode(), dev.isNewPDV21Hw());
        [self setDataBufs:[preset getDataBufs]];
    }
    return self;
}

- (void) clear {
    header.i2cAddr          = I2C_ADDR;
    header.successWriteFlag = 0;
    header.version          = PERIPHERAL_VERSION;
    header.pairingCode      = 0;
    header.initDspDelay     = INIT_DSP_DELAY;
    header.advertiseMode    = ADVERTISE_ALWAYS_ENABLED;

    HiFiToyOutputMode * om  = [[HiFiToyOutputMode alloc] init];
    header.gainChannel3     = [om getGainCh3]; // 0x4000
    
    header.energy.highThresholdDb = ENERGY_CORRECT_HIGH_THRES_COEF;    // 0
    header.energy.lowThresholdDb  = -55;  // -55
    header.energy.auxTimeout120ms = 2500; // 2500 * 120ms = 300s = 5min
    header.energy.usbTimeout120ms = 0;    // not used
    
    // all biquads = PARAMETRIC
    memset(header.biquadTypes, BIQUAD_PARAMETRIC, sizeof(header.biquadTypes));
    header.outputMode = [om isUnbalance] ? 1 : 0;

    header.dataBufLength   = 0;
    header.dataBytesLength = 0;
    
    dataBufs = [[NSMutableArray alloc] init];
}

- (void) setDataBufs:(NSArray<HiFiToyDataBuf *> *)bufs {
    header.dataBufLength = bufs.count;
    header.dataBytesLength = [self calcDataBytesLength:dataBufs];
    
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
        
    //append first 0x24 bytes
    [data appendBytes:&header length:PERIPHERAL_CONFIG_LENGTH];
    
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

- (void) exportAll {
    HiFiToyControl * ctrl = [HiFiToyControl sharedInstance];
    
    if (![ctrl isConnected]) return;
    
    [ctrl sendBufToDsp:[self getBinary] withOffset:0];
    [ctrl sendWriteFlag:1];
    [ctrl setInitDsp];
    
}

- (void) exportWithDialog:(NSString *)title {
    if (![[HiFiToyControl sharedInstance] isConnected]) return;
    
    [[DialogSystem sharedInstance] showProgressDialog:title];
    [self exportAll];
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

- (void) exportPresetWithDialog:(NSString *)title {
    if (![[HiFiToyControl sharedInstance] isConnected]) return;
    
    [[DialogSystem sharedInstance] showProgressDialog:title];
    [self exportPreset];
}

- (void) importHeader:(void (^ __nullable)(void))finishHandler {
    HiFiToyControl * ctrl = [HiFiToyControl sharedInstance];
    
    if (![ctrl isConnected]) return;
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(didGetHeaderData:)
                                                 name: @"GetDataNotification"
                                               object: finishHandler];
    importData = [[NSMutableData alloc] init];
    [ctrl getDspDataWithOffset:0];
}


- (void) didGetHeaderData:(NSNotification*)notification {
    //get 20 byte portion and append
    NSData * data = (NSData *)[notification object];
    [importData appendData:data];
    
    if (importData.length == 40) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        if (![self parseHeader:importData]) {
            header.dataBytesLength = 0;
        }
        
        finishHandler = notification.object;
        if (finishHandler) finishHandler();
        
    } else {
        [[HiFiToyControl sharedInstance] getDspDataWithOffset:20];
    }
}

- (BOOL) parseHeader:(NSData *)data {
    if (data.length < PERIPHERAL_CONFIG_LENGTH) {
        return NO;
    }
    memcpy(&header, data.bytes, PERIPHERAL_CONFIG_LENGTH);
    
    return YES;
}

- (void) import:(void (^ __nullable)(void))finishHandler {
    [self importHeader:^() {
        if (self->header.dataBytesLength == 0) {
            [[DialogSystem sharedInstance] showAlert:@"Import preset is not success."];
            return;
        }
        
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(didGetData:)
                                                     name: @"GetDataNotification"
                                                   object: finishHandler];
        
        self->importData = [[NSMutableData alloc] init];
        [[HiFiToyControl sharedInstance] getDspDataWithOffset:PERIPHERAL_CONFIG_LENGTH];
    }];
}

- (void) didGetData:(NSNotification*)notification {
    //get 20 byte portion and append
    NSData * data = (NSData *)[notification object];
    [importData appendData:data];
    
    if (importData.length >= header.dataBufLength) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        [self parseDataBufs:importData];
        
        finishHandler = notification.object;
        if (finishHandler) finishHandler();
        
    } else {
        [[HiFiToyControl sharedInstance] getDspDataWithOffset:PERIPHERAL_CONFIG_LENGTH + importData.length];
    }
}

- (void) parseDataBufs:(NSData *)data {
    DataBufHeader_t * buf = (DataBufHeader_t *)data.bytes;
    
    NSMutableArray<HiFiToyDataBuf *> * dataBufs = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < header.dataBufLength; i++) {
        NSData * d = [[NSData alloc] initWithBytes:buf length:(buf->length + 2)];
        buf = (DataBufHeader_t *)((uint8_t *)buf + sizeof(DataBufHeader_t) + buf->length);
        
        [dataBufs addObject:[[HiFiToyDataBuf alloc] initWithData:d]];
    }
    
    [self setDataBufs:dataBufs];
}

@end
