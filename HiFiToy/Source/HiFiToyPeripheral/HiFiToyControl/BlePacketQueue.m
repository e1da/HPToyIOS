//
//  BlePacketQueue.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 05/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "BlePacketQueue.h"
#import "HiFiToyObject.h"

@implementation BlePacketQueue

- (id) init {
    self = [super init];
    if (self) {
        blePacketsArray = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) clear {
    [blePacketsArray removeAllObjects];
}

- (int) size {
    return (int)blePacketsArray.count;
}

- (void) addPacket:(BlePacket*)blePacket {
    
    if ([blePacket response] == NO) {

        DataBufHeader_t * headerBlePacket = (DataBufHeader_t *)blePacket.data.bytes;
        
        for (long i = blePacketsArray.count - 1; i > 0; i--){
            BlePacket* pack = [blePacketsArray objectAtIndex:i];
            DataBufHeader_t * headerPack = (DataBufHeader_t *)pack.data.bytes;
            
            if ((pack.response == NO) &&
                (headerBlePacket->addr == headerPack->addr) &&
                (headerBlePacket->length == headerPack->length)) {
                
                [blePacketsArray replaceObjectAtIndex:i withObject:blePacket];
                return;
            }
        }
    }
    

    //add packet to queue
    [blePacketsArray addObject:blePacket];
}

- (void) addPacketWithCharacteristic:(CBCharacteristic*)characteristic
                                data:(NSData *)data
                            response:(BOOL)response {
    [self addPacket:[BlePacket initWithPacket:characteristic data:data response:response]];
}

- (BlePacket *) getFirstPacket {
    return [blePacketsArray firstObject];
}

- (void) removeFirstPacket {
    [blePacketsArray removeObjectAtIndex:0];
}

- (void) print
{
    NSLog(@"<BlePacketQueue>");
    if (blePacketsArray) {
        for (int i = 0; i< blePacketsArray.count; i++) {
            BlePacket * packet = [blePacketsArray objectAtIndex:i];
            uint8_t * data = (uint8_t *)packet.data.bytes;
            
            for (int u = 0; u < packet.data.length; u++){
                printf("%x ", data[u]);
            }
            printf("\n");
        }
    }
    NSLog(@"</BlePacketQueue>");
}

/*-(void)testModule
 {
 uint8_t p2[2] = {0, 1};
 [self addPacketWithCharacteristic:0xFF00 data:[NSData dataWithBytes:p2 length:2] response:YES];
 [self addPacketWithCharacteristic:0xFF10 data:[NSData dataWithBytes:p2 length:2] response:NO];
 
 BlePacket * pack = [self getFirstPacketWithRemove];
 NSLog(@"%@", [pack description]);
 NSLog(@"%@", [pack description]);
 pack = [self getFirstPacketWithRemove];
 NSLog(@"%@", [pack description]);*/

/*NSLog(@"%@" , blePacketsArray.description);
 
 [self addPacketWithCharacteristic:0xFF20 data:[NSData dataWithBytes:p2 length:2] response:NO];
 
 NSLog(@"%@" , blePacketsArray.description);
 
 [self addPacketWithCharacteristic:0xFF30 data:[NSData dataWithBytes:p2 length:2] response:YES];
 
 NSLog(@"%@" , blePacketsArray.description);
 
 
 }*/


@end
