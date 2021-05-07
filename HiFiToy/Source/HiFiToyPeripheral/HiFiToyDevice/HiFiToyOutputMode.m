//
//  HiFiToyOutputMode.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 01/05/2021.
//  Copyright © 2021 Kerosinn_OSX. All rights reserved.
//

#import "HiFiToyOutputMode.h"
#import "HiFiToyControl.h"

@implementation HiFiToyOutputMode

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

- (void) setBoost:(int16_t)boostValue {
    if (self.value == BALANCE_OUT_MODE) return;

    if (boostValue == 0) {
        self.value = UNBALANCE_OUT_MODE;
    } else {
        self.value = UNBALANCE_BOOST_OUT_MODE;
    }
}

- (void) sendToDsp {
    CommonPacket_t packet;
    
    //send output mode
    packet.cmd = SET_OUTPUT_MODE;
    
    if (self.value == BALANCE_OUT_MODE) {
        packet.data[0] = BALANCE_OUT_MODE;
    } else {
        packet.data[0] = UNBALANCE_OUT_MODE;
    }
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
    CommonPacket_t packet;
    
    //read output value
    packet.cmd = GET_OUTPUT_MODE;
    [[HiFiToyControl sharedInstance] sendCommonPacketToDsp:&packet];
    
    //read mixer value
    packet.cmd = GET_TAS5558_CH3_MIXER;
    [[HiFiToyControl sharedInstance] sendCommonPacketToDsp:&packet];
}

@end
