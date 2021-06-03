//
//  AmMode.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 20/05/2021.
//  Copyright © 2021 Kerosinn_OSX. All rights reserved.
//

#import "AmMode.h"
#import "TAS5558.h"
#import "HiFiToyControl.h"
#import "HiFiToyDataBuf.h"
#import "PeripheralData.h"

@implementation AmMode {
    uint8_t data[4];
}

/* -------------------- init state methods -------------------- */
- (id) init {
    self = [super init];
    if (self) {
        [self reset];
    }
    return self;
}

- (void) reset {
    data[0] = 0x00;
    data[1] = 0x09;
    data[2] = 0x03;
    data[3] = 0xF2;

    _successImport = false;
}

/* ------------------ setter getter methods ------------------ */
- (uint8_t) getData:(int)index {
    if (index > 3) index = 3;
    if (index < 0) index = 0;
    return data[index];
}

- (void) setData:(uint8_t)d toIndex:(int)index {
    if (index > 3) index = 3;
    if (index < 0) index = 0;
    data[index] = d;
}

- (BOOL) isEnabled {
    return ((data[1] & 0x10) != 0);
}

- (void) setEnabled:(BOOL)enabled {
    if (enabled) {
        data[1] |= 0x10; // set
    } else {
        data[1] &= ~0x10; // clear
    }
}

/* ----------------- HiFiToyObject implements ----------------- */
- (uint8_t) address {
    return AM_MODE_REG;
}

- (NSString *) getInfo {
    return [NSString stringWithFormat:@"D31-24: 0x%x D23-16: 0x%x D15-8: 0x%x D7-0: 0x%x",
            data[0], data[1], data[2], data[3]];
}

- (void)sendWithResponse:(BOOL)response {
    NSData *data = [[self getDataBufs][0] binary];
    Packet_t packet;
    memcpy(&packet, data.bytes, data.length);
    
    [[HiFiToyControl sharedInstance] sendPacketToDsp:&packet withResponse:YES];
}

- (NSArray<HiFiToyDataBuf *> *) getDataBufs {
    HiFiToyDataBuf * dataBuf = [HiFiToyDataBuf dataBufWithAddr:self.address withLength:4 withData:data];
    return @[dataBuf];
    
}

- (BOOL) importFromDataBufs:(NSArray<HiFiToyDataBuf *> *) dataBufs {
    _successImport = false;
    
    for (HiFiToyDataBuf * dataBuf in dataBufs) {
        if ((dataBuf.addr == self.address) && (dataBuf.length == 4)){
            memcpy(data, dataBuf.data.bytes, dataBuf.length);
            
            NSLog(@"AMMode import success.");
            
            _successImport = true;
            break;
        }
    }
    
    return _successImport;
}

- (void)importFromXml:(XmlParserWrapper *)xmlParser withAttrib:(NSDictionary<NSString *,NSString *> *)attributeDict {
}

- (XmlData *)toXmlData {
    return nil;
}

/* ------------------- export import methods ------------------- */

- (void) storeToPeripheral {
    HiFiToyPreset * preset = [[[HiFiToyControl sharedInstance] activeHiFiToyDevice] preset];
    PeripheralData * pd = [[PeripheralData alloc] initWithPreset:preset];
    [pd exportPresetWithDialog:@"Beat-tones update..."];
}

- (void) importFromPeripheral:(void (^ __nullable)(void))finishHandler {
    
    __block __weak id observer;
    observer = [[NSNotificationCenter defaultCenter] addObserverForName:@"GetDataNotification"
                                                                 object:nil
                                                                  queue:nil
                                                             usingBlock:^(NSNotification * note) {
        
        [[NSNotificationCenter defaultCenter] removeObserver:observer];
        
        NSData * data = (NSData *)[note object];
        HiFiToyDataBuf * db = [[HiFiToyDataBuf alloc] initWithData:data];
        
        [self importFromDataBufs:@[db]];
        
        if (finishHandler) finishHandler();
    }];
    
    
    [[HiFiToyControl sharedInstance] getDspDataWithOffset:FIRST_DATA_BUF_OFFSET];
}

@end
