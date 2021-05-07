//
//  HiFiToyObject.h
//  HifiToy
//
//  Created by Artem Khlyupin on 30/05/2018.
//

#import <Foundation/Foundation.h>
#import "XmlData.h"
#import "XmlParserWrapper.h"
#import "BiquadParam.h"

#define FS 96000

typedef struct{
    uint8_t addr;     // in TAS5558 registers
    uint8_t length;    // [byte] unit
} DataBufHeader_t;

typedef enum : uint8_t {
    PCM9211_SPDIF_SOURCE, PCM9211_USB_SOURCE, PCM9211_BT_SOURCE,
} PCM9211Source_t;

typedef enum : uint8_t {
    ALWAYS_ENABLED, AFTER_1MIN_DISABLED
} AdvertiseMode_t;

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


@protocol HiFiToyObject

-(uint8_t) address;

//info string
-(NSString *) getInfo;

//send to dsp
- (void) sendWithResponse:(BOOL)response;

//get binary for save to dsp
- (NSData *) getBinary;

- (BOOL) importData:(NSData *)data;

-(XmlData *) toXmlData;
-(void) importFromXml:(XmlParserWrapper *)xmlParser withAttrib:(NSDictionary<NSString *, NSString *> *)attributeDict;

@end
