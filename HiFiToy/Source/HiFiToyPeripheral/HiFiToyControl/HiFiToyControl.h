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

#define HIFI_TOY_VERSION            10
#define CC2540_PAGE_SIZE            2048
#define ATTACH_PAGE_OFFSET          (3 * CC2540_PAGE_SIZE)//3 page

@interface HiFiToyControl : NSObject <BleCommunicationDelegate> {
    BleDriver * bleDriver;
    HiFiToyPeripheral_t hiFiToyConfig;
    
}

@property (nonatomic) AudioSource_t audioSource;

+ (HiFiToyControl *)sharedInstance;

- (NSMutableArray *) getPeripherals;

- (BOOL) isConnected;
- (void) startDiscovery;
- (void) stopDiscovery;
- (void) connect:(CBPeripheral *)p;
- (void) disconnect;

//base send command
- (void) sendDataToDsp:(NSData *)data withResponse:(BOOL)response;
//sys command
- (void) sendNewPairingCode:(uint32_t) pairing_code;
- (void) startPairedProccess:(uint32_t) pairing_code;
- (void) sendWriteFlag:(uint8_t) write_flag;
- (void) checkFirmareWriteFlag;
- (void) getVersion;
- (void) getChecksumParamData;
- (void) setInitDsp;
- (void) updateAudioSource;
- (void) sendEnergyConfig:(EnergyConfig_t)energy;
- (void) getEnergyConfig;

//adv command (save/restore to/from storage)
- (void) restoreFactorySettings;
- (void) sendDSPConfig:(NSData *)data;

- (void) getDspDataWithOffset:(uint16_t)offset;

@end
