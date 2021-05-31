//
//  HiFiToyDataBuf.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 20/05/2021.
//  Copyright © 2021 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef struct{
    uint8_t addr;     // in TAS5558 registers
    uint8_t length;    // [byte] unit
} DataBufHeader_t;


@interface HiFiToyDataBuf : NSObject

@property uint8_t               addr;
@property (readonly) uint8_t    length;
@property NSData *              data;

- (id) initWithAddr:(uint8_t)addr withLength:(uint8_t)length withData:(uint8_t *)d;
- (id) initWithData:(NSData *)d;

+ (id) dataBufWithAddr:(uint8_t)addr withLength:(uint8_t)length withData:(uint8_t *)d;

- (NSData *) binary;
- (BOOL) parseBinary:(NSData *)bin;

@end

NS_ASSUME_NONNULL_END
