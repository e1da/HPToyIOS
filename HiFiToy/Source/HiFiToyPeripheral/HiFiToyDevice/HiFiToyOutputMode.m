//
//  HiFiToyOutputMode.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 01/05/2021.
//  Copyright © 2021 Kerosinn_OSX. All rights reserved.
//

#import "HiFiToyOutputMode.h"
#import "HiFiToyControl.h"

@implementation HiFiToyOutputMode {
    uint16_t offset;
}

- (id) init {
    self = [super init];
    if (self) {
        [self setDefault];
    }
    return self;
}

- (void) setDefault {
    self.value = UNBALANCE_OUT_MODE;
    self.hwSupported = YES;
}

- (void) setValue:(OutputModeValue_t)value {
    if (value < BALANCE_OUT_MODE) value = BALANCE_OUT_MODE;
    if (value > UNBALANCE_BOOST_OUT_MODE) value = UNBALANCE_BOOST_OUT_MODE;

    _value = value;
}

- (BOOL) isUnbalance {
        return (_value > 0);
}

- (uint16_t) getGainCh3 {
    return (_value == UNBALANCE_BOOST_OUT_MODE) ? 0x4000 : 0;
}


- (void) sendToDsp {
    CommonPacket_t packet;
    
    //send output mode
    packet.cmd = SET_OUTPUT_MODE;
    packet.data[0] = (self.value == BALANCE_OUT_MODE) ? 0 : 1;
    
    [[HiFiToyControl sharedInstance] sendCommonPacketToDsp:&packet];
    
    //send mixer value
    packet.cmd = SET_TAS5558_CH3_MIXER;
    packet.data[0] = 0;
    packet.data[1] = (self.value == UNBALANCE_BOOST_OUT_MODE) ? 0x40 : 0;
    packet.data[2] = 0;
    packet.data[3] = 0;

    [[HiFiToyControl sharedInstance] sendCommonPacketToDsp:&packet];
}

- (void) readFromDsp {
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleGetDataNotification:)
                                                 name: @"GetDataNotification"
                                               object: nil];
    
    offset = GAIN_CH3_OFFSET;
    [[HiFiToyControl sharedInstance] getDspDataWithOffset:offset];
}

- (void) handleGetDataNotification:(NSNotification*)notification {
    static uint16_t boost;
    
    //we get 20 bytes
    const uint8_t * data = ((NSData *)[notification object]).bytes;
    
    if (offset == GAIN_CH3_OFFSET) {
        boost = (uint16_t)(data[0] + (data[1] << 8));

        offset += 20;
        [[HiFiToyControl sharedInstance] getDspDataWithOffset:offset];

    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self];

        uint8_t bal = data[OUTPUT_TYPE_OFFSET - GAIN_CH3_OFFSET - 20];
        NSLog(@"Boost=%d Unbalance=%d", boost, bal);
        
        //update value
        self.value = bal;
        if ((boost != 0) && (self.value > BALANCE_OUT_MODE)) {
            self.value = UNBALANCE_BOOST_OUT_MODE;
        }
        NSLog(@"%@", [self description]);
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SetupOutletsNotification" object:nil];
    }
}

//WARNING: GET_OUTPUT_MODE cmd uses only for check PDV2.1 or PDV2 classic
//this cmd return incorrect value. bug on hw side.
- (void) isSettingsAvailable {
    CommonPacket_t packet;
    
    //read output value
    packet.cmd = GET_OUTPUT_MODE;
    [[HiFiToyControl sharedInstance] sendCommonPacketToDsp:&packet];
}

- (NSString *) description {
    switch (self.value) {
        case BALANCE_OUT_MODE:
            return @"Output mode = Balance";
        case UNBALANCE_OUT_MODE:
            return @"Output mode = Unbalance";
        case UNBALANCE_BOOST_OUT_MODE:
            return @"Output mode = Boost unbalance";
        default:
            return @"Output mode = Error";
    }
}

@end
