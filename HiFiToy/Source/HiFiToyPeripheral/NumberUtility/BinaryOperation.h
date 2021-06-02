//
//  BinaryOperation.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 02/06/2021.
//  Copyright © 2021 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HiFiToyDataBuf.h"

NS_ASSUME_NONNULL_BEGIN

@interface BinaryOperation : NSObject

+ (NSData *) getDataBufBinary:(NSArray<HiFiToyDataBuf *> *)dataBufs;

@end

NS_ASSUME_NONNULL_END
