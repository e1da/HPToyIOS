//
//  HiFiToyObject.h
//  HifiToy
//
//  Created by Artem Khlyupin on 30/05/2018.
//

#import <Foundation/Foundation.h>
#import "XmlData.h"
#import "XmlParserWrapper.h"

#define FS 96000

typedef struct{
    uint8_t addr;     // in TAS5558 registers
    uint8_t length;    // [byte] unit
} DataBufHeader_t;

typedef enum : uint8_t {
    USB, AUX, AUTO
} AudioSource_t;

#pragma pack(1)
typedef struct {
    float       highThresholdDb;
    float       lowThresholdDb;
    uint16_t    auxTimeout120ms;
    uint16_t    usbTimeout120ms;
} EnergyConfig_t;
#pragma options align=reset

#pragma pack(1)
typedef struct {
    uint8_t             i2cAddr;
    uint8_t             successWriteFlag;
    uint16_t            version;
    uint32_t            pairingCode;
    AudioSource_t       audioSource;
    uint8_t             reserved[3];
    EnergyConfig_t      energy;
    
    uint16_t            dataBufLength;
    uint16_t            dataBytesLength;
    DataBufHeader_t     firstDataBuf;
} HiFiToyPeripheral_t;
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
