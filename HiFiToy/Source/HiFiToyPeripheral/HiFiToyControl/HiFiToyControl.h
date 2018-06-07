//
//  HiFiToyControl.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 06/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BleDriver.h"
#import "HiFiToyObject.h"

#define CC2540_PAGE_SIZE            2048
#define ATTACH_PAGE_OFFSET          (3 * CC2540_PAGE_SIZE)//3 page

@interface HiFiToyControl : NSObject <BleCommunicationDelegate> {
    BleDriver * bleDriver;
    HiFiToyPeripheral_t hiFiToyConfig;
}

+ (HiFiToyControl *)sharedInstance;

- (void) sendNewPairingCode:(uint32_t) pairing_code;
- (void) startPairedProccess:(uint32_t) pairing_code;
- (void) sendWriteFlag:(uint8_t) write_flag;
- (void) checkFirmareWriteFlag;
- (void) getChecksumParamData;
- (void) sendDSPConfig:(NSData *)data;

- (void) sendDataToDsp:(NSData *)data withResponse:(BOOL)response;

@end
