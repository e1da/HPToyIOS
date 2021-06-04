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
#import "BinaryOperation.h"


#define BIQUAD_TYPE_OFFSET          0x18
#define PRESET_DATA_OFFSET          0x20

@implementation PeripheralData

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
        
        //append AMMode reg for fix whistles bug in PDV2.1
        NSArray<HiFiToyDataBuf *> * updBufs = [self appendAmModeDataBuf:[dev.preset getDataBufs]
                                                                 amMode:dev.amMode
                                                                  newHW:dev.isPDV21Hw];

        [self setDataBufs:updBufs];
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
        
        //append AMMode reg for fix whistles bug in PDV2.1
        NSArray<HiFiToyDataBuf *> * updBufs = [self appendAmModeDataBuf:[preset getDataBufs]
                                                                 amMode:dev.amMode
                                                                  newHW:dev.isPDV21Hw];
        [self setDataBufs:updBufs];
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
    
    _dataBufs = [[NSMutableArray alloc] init];
}

/* ----------------- utility methods ---------------- */
- (void) setDataBufs:(NSArray<HiFiToyDataBuf *> *)bufs {
    header.dataBufLength = bufs.count;
    header.dataBytesLength = [self calcDataBytesLength:bufs];
    
    _dataBufs = bufs;
}

- (uint16_t) calcDataBytesLength:(NSArray<HiFiToyDataBuf *> *)dataBufs {
    uint16_t length = 0;
    
    for (HiFiToyDataBuf * db in dataBufs) {
        length += [[db binary] length];
    }
    
    return length + PERIPHERAL_CONFIG_LENGTH;

}

- (NSData *) getDataBufBinary {
    return [BinaryOperation getDataBufBinary:self.dataBufs];
}

- (uint16_t) bufBytesLength {
    return header.dataBytesLength - PERIPHERAL_CONFIG_LENGTH;
}

- (NSData *) getBinary {
    NSMutableData * data = [[NSMutableData alloc] init];
        
    //append first 0x24 bytes
    [data appendBytes:&header length:PERIPHERAL_CONFIG_LENGTH];
    //append data bufs
    [data appendData:[self getDataBufBinary]];
    
    return data;
}

- (NSData *) getBiquadTypeBinary {
    return [[self getBinary] subdataWithRange:NSMakeRange(BIQUAD_TYPE_OFFSET, 7)];
}

- (NSData *) getPresetBinary {
    NSData * bin = [self getBinary];
    return [bin subdataWithRange:NSMakeRange(PRESET_DATA_OFFSET, bin.length - PRESET_DATA_OFFSET)];
}

- (HiFiToyDataBuf *) findDataBufWithAddr:(uint8_t)addr
                              inDataBufs:(NSArray<HiFiToyDataBuf *> *)bufs {
    for (HiFiToyDataBuf * b in bufs) {
        if (b.addr == addr) {
            return b;
        }
    }
    return nil;
}

- (void) restrictBassFilterGain:(NSArray<HiFiToyDataBuf *> *)bufs {
    HiFiToyDataBuf * bassFilterBuf = [self findDataBufWithAddr:BASS_FILTER_SET_REG inDataBufs:bufs];
    
    if (bassFilterBuf) {
        uint8_t * bassFilterData = (uint8_t *)bassFilterBuf.data.bytes;
        uint8_t * bassFilterGain = &bassFilterData[7];
        
        if (*bassFilterGain < 0x12) {
            *bassFilterGain = 0x12;
            NSData * updBassFilterData = [NSData dataWithBytes:bassFilterData
                                                        length:bassFilterBuf.data.length];
            
            bassFilterBuf.data = updBassFilterData;
        }
    }
}

- (NSArray<HiFiToyDataBuf *> *) appendAmModeDataBuf:(NSArray<HiFiToyDataBuf *> *)bufs
                      amMode:(AmMode *)amMode
                       newHW:(BOOL)newHW {
    //set AMMode reg for fix whistles bug in PDV2.1
    if ([amMode isEnabled]) {
        NSMutableArray<HiFiToyDataBuf *> * updBufs = [NSMutableArray arrayWithArray:bufs];
        [updBufs insertObject:[amMode getDataBufs][0] atIndex:0];
        
        //and delete bass filter buf for fix bug incorrect launch hw for old hw
        if (!newHW) {
            [self restrictBassFilterGain:updBufs];
        }
        
        return updBufs;
    }
    
    return bufs;
}

/* -------------- export/import methods ------------- */
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
    if (![[HiFiToyControl sharedInstance] isConnected]) return;
    
    NSMutableData * importData = [[NSMutableData alloc] init];
    
    __block __weak id observer;
    observer = [[NSNotificationCenter defaultCenter] addObserverForName:@"GetDataNotification"
                                                                 object:nil
                                                                  queue:nil
                                                             usingBlock:^(NSNotification * note) {
        //get 20 byte portion and append
        NSData * data = (NSData *)[note object];
        [importData appendData:data];
        
        if (importData.length == 40) {
            [[NSNotificationCenter defaultCenter] removeObserver:observer];
            
            if (![self parseHeader:importData]) {
                self->header.dataBytesLength = 0;
            }
            
            if (finishHandler) finishHandler();
            
        } else {
            [[HiFiToyControl sharedInstance] getDspDataWithOffset:20];
        }
    }];
    
    [[HiFiToyControl sharedInstance] getDspDataWithOffset:0];
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
        
        NSMutableData * importData = [[NSMutableData alloc] init];
        
        __block __weak id observer;
        observer = [[NSNotificationCenter defaultCenter] addObserverForName:@"GetDataNotification"
                                                                     object:nil
                                                                      queue:nil
                                                                 usingBlock:^(NSNotification * note) {
            // get 20bytes and append
            [importData appendData:(NSData *)[note object]];
            
            //update dialog view
            DialogSystem * dialog = [DialogSystem sharedInstance];
            if ([dialog isProgressDialogVisible]) {
                float progress = (float)importData.length / (self->header.dataBytesLength - PERIPHERAL_CONFIG_LENGTH) * 100;
                if (progress > 100) progress = 100;
                
                dialog.progressController.message = [NSString stringWithFormat:@"Progress %d%%", (int)progress];
            }
            
            //check is all data imported
            if (importData.length >= self->header.dataBytesLength) { // if finished
                [[NSNotificationCenter defaultCenter] removeObserver:observer];
                [self parseDataBufs:importData];
                
                //close dialog view
                [dialog dismissProgressDialog];
                
                if (finishHandler) finishHandler();
                
            } else {
                [[HiFiToyControl sharedInstance] getDspDataWithOffset:PERIPHERAL_CONFIG_LENGTH + importData.length];
            }
        }];
        
        [[HiFiToyControl sharedInstance] getDspDataWithOffset:PERIPHERAL_CONFIG_LENGTH];
    }];
}

- (void) importWithDialog:(NSString *)title handler:(void (^ __nullable)(void))finishHandler {
    if (![[HiFiToyControl sharedInstance] isConnected]) return;
    
    [[DialogSystem sharedInstance] showProgressDialog:title];
    [self import:finishHandler];
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
