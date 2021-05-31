//
//  HiFiToyObject.h
//  HifiToy
//
//  Created by Artem Khlyupin on 30/05/2018.
//

#import "PeripheralDefines.h"
#import "XmlData.h"
#import "XmlParserWrapper.h"

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
