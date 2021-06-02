//
//  Checksummer.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 02/06/2021.
//  Copyright © 2021 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HiFiToyDataBuf.h"

NS_ASSUME_NONNULL_BEGIN

@interface Checksummer : NSObject

+ (uint16_t) calc:(NSData *)data;
+ (uint16_t) calcDataBufs:(NSArray<HiFiToyDataBuf *> *) dataBufs;

+ (uint16_t) subtractDataFrom:(uint16_t)checksum
               originalLength:(int)length
                         data:(NSData *)data;
@end

NS_ASSUME_NONNULL_END
