//
//  HiFiToyDataBuf.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 20/05/2021.
//  Copyright © 2021 Kerosinn_OSX. All rights reserved.
//

#import "HiFiToyDataBuf.h"

@implementation HiFiToyDataBuf

- (id) initWithAddr:(uint8_t)addr withLength:(uint8_t)length withData:(uint8_t *)d {
    self = [super init];
    if (self) {
        self.addr = addr;
        self.data = [NSData dataWithBytes:d length:length];
    }
    return self;
}

- (id) initWithData:(NSData *)d {
    self = [super init];
    if (self) {
        [self parseBinary:d];
    }
    return self;
}

+ (id) dataBufWithAddr:(uint8_t)addr withLength:(uint8_t)length withData:(uint8_t *)d {
    return [[HiFiToyDataBuf alloc] initWithAddr:addr withLength:length withData:d];
}

- (uint8_t) length {
    return (self.data == nil) ? 0 : self.data.length;
}

- (NSData *) binary {
    uint8_t length = self.length;
    
    if (length != 0) {
        NSMutableData * bin = [[NSMutableData alloc] init];
        [bin appendBytes:&_addr length:1];
        [bin appendBytes:&length length:1];
        [bin appendData:self.data];
        
        return bin;
    }
    return nil;
}

- (BOOL) parseBinary:(NSData *)bin {
    BOOL full = YES;

    uint8_t * valP = (uint8_t *)bin.bytes;
    
    self.addr = valP[0];
    uint8_t length = valP[1];
    
    if (bin.length < length + 2) {
        full = NO;
        length = bin.length - 2;
    }
    
    _data = [bin subdataWithRange:NSMakeRange(2, length)];
    return full;
}

- (NSString *) description {
    NSMutableString * str = [[NSMutableString alloc] init];
    [str appendFormat:@"Addr %d: ", self.addr];
    
    uint8_t * val = (uint8_t *)self.data.bytes;
    
    for (int i = 0; i < self.data.length; i++) {
        [str appendFormat:@"%x ", val[i]];
    }
    return str;
}

@end
