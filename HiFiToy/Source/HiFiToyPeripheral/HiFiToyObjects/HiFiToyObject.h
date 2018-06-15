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

#pragma pack(1)

typedef struct {
    uint8_t             i2cAddr;
    uint8_t             successWriteFlag;
    uint16_t            version;
    uint32_t            pairingCode;
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
