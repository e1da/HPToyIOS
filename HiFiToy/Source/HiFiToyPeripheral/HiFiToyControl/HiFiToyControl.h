//
//  HiFiToyControl.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 06/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BleDriver.h"
#import "HiFiToyPreset.h"
#import "HiFiToyDevice.h"

#define HIFI_TOY_VERSION            11
#define CC2540_PAGE_SIZE            2048
#define ATTACH_PAGE_OFFSET          (3 * CC2540_PAGE_SIZE)//3 page

typedef enum : uint8_t {
    ESTABLISH_PAIR      = 0x00,
    SET_PAIR_CODE       = 0x01,
    SET_WRITE_FLAG      = 0x02,
    GET_WRITE_FLAG      = 0x03,
    GET_VERSION         = 0x04,
    GET_CHECKSUM        = 0x05,
    INIT_DSP            = 0x06,
    SET_AUDIO_SOURCE    = 0x07,
    GET_AUDIO_SOURCE    = 0x08,
    
    //feedback msg
    CLIP_DETECTION              = 0xFD,
    OTW_DETECTION               = 0xFE,
    PARAM_CONNECTION_ENABLED    = 0xFF
    
} CommonCmd_t;

typedef struct {
    uint8_t cmd;
    uint8_t data[4];
} CommonPacket_t;

typedef struct {
    uint8_t addr;
    uint8_t length;
    uint8_t data[18];
} Packet_t;

typedef enum : uint8_t {
    PAIR_NO, PAIR_YES
} PairStatus_t;

@interface HiFiToyControl : NSObject <BleCommunicationDelegate> {
    BleDriver * bleDriver;
    HiFiToyPeripheral_t hiFiToyConfig;
    
}

@property (nonatomic, readonly) NSMutableArray * foundHiFiToyDevices;
@property (nonatomic, readonly) HiFiToyDevice * activeHiFiToyDevice;

+ (HiFiToyControl *)sharedInstance;

- (BOOL) isConnected;
- (void) startDiscovery;
- (void) stopDiscovery;
- (void) connect:(HiFiToyDevice *) device;
- (void) demoConnect;
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
- (void) sendEnergyConfig:(EnergyConfig_t)energy;
- (void) getEnergyConfig;

//adv command (save/restore to/from storage)
- (void) restoreFactorySettings;
- (void) storePresetToDSP:(HiFiToyPreset *) preset;

- (void) getDspDataWithOffset:(uint16_t)offset;

@end
