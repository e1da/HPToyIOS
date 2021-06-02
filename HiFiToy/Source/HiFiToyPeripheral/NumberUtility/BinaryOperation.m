//
//  BinaryOperation.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 02/06/2021.
//  Copyright © 2021 Kerosinn_OSX. All rights reserved.
//

#import "BinaryOperation.h"

@implementation BinaryOperation

+ (NSData *) getDataBufBinary:(NSArray<HiFiToyDataBuf *> *)dataBufs {
    NSMutableData * data = [[NSMutableData alloc] init];
    
    //append data bufs
    for (HiFiToyDataBuf * db in dataBufs) {
        [data appendData:[db binary]];
    }
    return data;
}

@end
