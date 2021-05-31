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

@implementation AmMode {
    uint8_t data[4];
}

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


- (uint8_t) address {
    return AM_MODE_REG;
}

- (NSData *) getBinary {
    Packet_t p;
    p.addr = [self address];
    p.length = 4;
    memcpy(p.data, data, p.length);
    
    return [NSData dataWithBytes:(const void *)&p length:6];
}

- (NSString *) getInfo {
    return [NSString stringWithFormat:@"D31-24: 0x%x D23-16: 0x%x D15-8: 0x%x D7-0: 0x%x",
            data[0], data[1], data[2], data[3]];
}

- (BOOL)importData:(NSArray<HiFiToyDataBuf *> *) dataBufArray {
    _successImport = false;
    
    for (HiFiToyDataBuf * dataBuf in dataBufArray) {
        if ((dataBuf.addr == self.address) && (dataBuf.length == 4)){
            memcpy(data, dataBuf.data.bytes, dataBuf.length);
            
            NSLog(@"AMMode import success.");
            
            _successImport = true;
            break;
        }
    }
    
    return _successImport;
}

- (void)sendWithResponse:(BOOL)response {
    const void * d = [[self getBinary] bytes];
    
    NSData * packet20 = [NSData dataWithBytes:d length:sizeof(Packet_t)];
    [[HiFiToyControl sharedInstance] sendDataToDsp:packet20 withResponse:YES];
}


- (void) storeToPeripheral {
    HiFiToyPreset * p = [[[HiFiToyControl sharedInstance] activeHiFiToyDevice] preset];

    
    /*PeripheralData peripheralData = new PeripheralData(p.getFilters().getBiquadTypes(),
                p.getFilters().getDataBufs());
    peripheralData.exportPresetWithDialog("Beat-tones update...");*/
    [p storeToPeripheral];
    
    /*HiFiToyPreset p = HiFiToyControl.getInstance().getActiveDevice().getActivePreset();

    PeripheralData peripheralData = new PeripheralData(p.getFilters().getBiquadTypes(),
                    p.getDataBufs());
    peripheralData.exportPresetWithDialog("Beat-tones update...");*/
}

- (void) importFromPeripheral {
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(getParamData:)
                                                 name: @"GetDataNotification"
                                               object: nil];
    
    
    [[HiFiToyControl sharedInstance] getDspDataWithOffset:FIRST_DATA_BUF_OFFSET];
}

- (void) getParamData:(NSNotification*)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //we get 20 bytes
    NSData * d = ((NSData *)[notification object]);
    HiFiToyDataBuf * buf = [[HiFiToyDataBuf alloc] initWithData:d];
    
    [self importData:@[buf]];
    
    /*ApplicationContext.getInstance().setupOutlets();

    if (afterReadFromDspProcess != null) {
        afterReadFromDspProcess.onPostProcess();
    }*/
    
}

/*private transient PostProcess afterReadFromDspProcess = null;

    public void readFromDsp(PostProcess postProcess) {
        if (!HiFiToyControl.getInstance().isConnected()) return;

        afterReadFromDspProcess = postProcess;

        final Context c = ApplicationContext.getInstance().getContext();

        c.registerReceiver(new BroadcastReceiver() {
            @Override
            public void onReceive(Context context, Intent intent) {
                final String action = intent.getAction();

                if (HiFiToyControl.DID_GET_PARAM_DATA.equals(action)) {
                    c.unregisterReceiver(this);

                    byte[] data = intent.getByteArrayExtra(EXTRA_DATA);
                    parseFirstDataBuf(data);
                }
            }
        }, new IntentFilter(HiFiToyControl.DID_GET_PARAM_DATA));

        //send ble command
        HiFiToyControl.getInstance().getDspDataWithOffset(FIRST_DATA_BUF_OFFSET);
    }

    private void parseFirstDataBuf(byte[] data) {
        HiFiToyDataBuf buf = new HiFiToyDataBuf(ByteBuffer.wrap(data));
        importFromDataBufs(new ArrayList<>(Collections.singletonList(buf)));
        ApplicationContext.getInstance().setupOutlets();

        if (afterReadFromDspProcess != null) {
            afterReadFromDspProcess.onPostProcess();
        }

    }*/

@end
