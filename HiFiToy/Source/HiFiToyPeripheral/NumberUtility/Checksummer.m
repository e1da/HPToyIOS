//
//  Checksummer.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 02/06/2021.
//  Copyright © 2021 Kerosinn_OSX. All rights reserved.
//

#import "Checksummer.h"
#import "BinaryOperation.h"

@implementation Checksummer

+ (uint16_t) calc:(NSData *)data {
    uint16_t checksum = 0;
    
    uint8_t * d = (uint8_t *)data.bytes;
    
    uint8_t sum = 0;
    uint8_t fibonacci = 0;
    
    for (int i = 0; i < data.length; i++) {
        sum += d[i];
        fibonacci += sum;
    }
    
    checksum = sum & 0xFF;
    checksum |= ((uint16_t)fibonacci << 8) & 0xFF00;
    
    return checksum;
}

+ (uint16_t) calcDataBufs:(NSArray<HiFiToyDataBuf *> *) dataBufs {
    NSData * data = [BinaryOperation getDataBufBinary:dataBufs];
    return [Checksummer calc:data];
}


//we have checksum(CS) value of data with originalLength
//func recalculate CS subtracting first data[]
+ (uint16_t) subtractDataFrom:(uint16_t)checksum
               originalLength:(int)length
                         data:(NSData *)data {
    
    uint8_t sum = checksum & 0xFF;
    uint8_t fib = (checksum >> 8) & 0xFF;
    
    uint8_t * d = (uint8_t *)data.bytes;
    
    for (int i = 0; i < data.length; i++) {
        sum -= d[i];
        fib -= d[i] * (length - i);
    }
    
    uint16_t updChecksum = sum & 0xFF;
    updChecksum |= ((uint16_t)fib << 8) & 0xFF00;
    
    return updChecksum;
}

@end
