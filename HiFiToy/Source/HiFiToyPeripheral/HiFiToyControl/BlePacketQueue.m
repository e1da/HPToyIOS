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

- (void) clear
{
    if (blePacketsArray != nil){
        [blePacketsArray removeAllObjects];
    }
    blePacketsArray = nil;
    
}

- (int) size
{
    return (int)blePacketsArray.count;
}

/*-(uint8_t) getAddressInPacket:(BlePacket *)packet
{
    DataBufHeader_t * header = (DataBufHeader_t *)packet.data.bytes;
    return header->addr;
}

-(uint8_t) getLengthInPacket:(BlePacket *)packet
{
    DataBufHeader_t * header = (DataBufHeader_t *)packet.data.bytes;
    return header->length;
}*/

- (void) addPacket:(BlePacket*)blePacket
{
    
    if ([blePacket response]){// == YES
        //add packet to queue
        if (blePacketsArray == nil){
            blePacketsArray = [NSMutableArray arrayWithObject:blePacket];
        } else {
            [blePacketsArray addObject:blePacket];
        }
    } else {// == NO
        BOOL add_status = NO;
        
        DataBufHeader_t * headerBlePacket = (DataBufHeader_t *)blePacket.data.bytes;
        
        for (long i = blePacketsArray.count - 1; i > 0; i--){
            BlePacket* pack = [blePacketsArray objectAtIndex:i];
            DataBufHeader_t * headerPack = (DataBufHeader_t *)pack.data.bytes;
            
            if ((pack.response == NO) &&
                (headerBlePacket->addr == headerPack->addr) &&
                (headerBlePacket->length == headerPack->length)) {
                
                [blePacketsArray replaceObjectAtIndex:i withObject:blePacket];
                add_status = YES;
                break;
            }
        }
        
        
        /*for (long i = blePacketsArray.count - 1; i > 0; i--){
            BlePacket* pack = [blePacketsArray objectAtIndex:i];
            if (pack.response == NO){
                [blePacketsArray replaceObjectAtIndex:i withObject:blePacket];
                add_status = YES;
                break;
            }
        }*/
        
        if (add_status == NO){//
            //add packet to queue
            if (blePacketsArray == nil){
                blePacketsArray = [NSMutableArray arrayWithObject:blePacket];
            } else {
                [blePacketsArray addObject:blePacket];
            }
            
        }
        
    }
    
    
}

- (void) addPacketWithCharacteristic:(CBCharacteristic*)characteristic
                                data:(NSData *)data
                            response:(BOOL)response
{
    [self addPacket:[BlePacket initWithPacket:characteristic data:data response:response]];
}




- (BlePacket *) getFirstPacket
{
    BlePacket* firstPacket = nil;
    
    if (blePacketsArray != nil){
        firstPacket = [blePacketsArray firstObject];
    }
    
    return firstPacket;
    
}

- (void) removeFirstPacket
{
    if (blePacketsArray != nil){
        [blePacketsArray removeObjectAtIndex:0];
    }
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
