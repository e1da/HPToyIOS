//
//  PassFilter.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 30/05/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "PassFilter.h"
#import "HiFiToyControl.h"

@implementation PassFilter

/*==========================================================================================
 Init
 ==========================================================================================*/
- (id) init {
    self = [super init];
    if (self) {
        [self setBorderMaxOrder:PASSFILTER_ORDER_8 minOrder:PASSFILTER_ORDER_2];
        self.biquads = nil;
    }
    
    return self;
}

/*---------------------- create method -----------------------------*/
+ (PassFilter *)initWithBiquads:(NSArray<BiquadLL *> *)biquads withType:(PassFilterType_t)type {
    BiquadParam * b;
    BiquadParam_t p;
    
    p.type = (type == BIQUAD_LOWPASS) ? BIQUAD_LOWPASS : BIQUAD_HIGHPASS;
    if ((biquads) && (biquads.count > 0)) {
        p.freq = [[biquads objectAtIndex:0] biquadParam].freq;
    } else {
        p.freq = 0;
    }
    p.dbVolume = 0.0;
    
    if (biquads) {
        switch (biquads.count) {
            case 1:
                b = [[biquads objectAtIndex:0] biquadParam];
                p.qFac = 0.71f;
                [b setBiquadParam:p];
                break;
                
            case 2:
                b = [[biquads objectAtIndex:0] biquadParam];
                p.qFac = 0.54f;
                [b setBiquadParam:p];
                b = [[biquads objectAtIndex:1] biquadParam];
                p.qFac = 1.31f;
                [b setBiquadParam:p];
                break;
                
            case 4:
                b = [[biquads objectAtIndex:0] biquadParam];
                p.qFac = 0.90f;
                [b setBiquadParam:p];
                b = [[biquads objectAtIndex:1] biquadParam];
                p.qFac = 2.65f;
                [b setBiquadParam:p];
                b = [[biquads objectAtIndex:0] biquadParam];
                p.qFac = 0.51f;
                [b setBiquadParam:p];
                b = [[biquads objectAtIndex:1] biquadParam];
                p.qFac = 0.60f;
                [b setBiquadParam:p];
                break;
            default:
                biquads = nil;
                break;
                
        }
    }
    
    PassFilter *instance = [[PassFilter alloc] init];
    instance.biquads = biquads;
    
    return instance;
}

/*==========================================================================================
 NSCopying protocol implementation
 ==========================================================================================*/
-(PassFilter *)copyWithZone:(NSZone *)zone {
    PassFilter * copyFilter = [[[self class] allocWithZone:zone] init];
    
    copyFilter.biquads = [self.biquads copy];
    
    copyFilter.maxOrder = self.maxOrder;
    copyFilter.minOrder = self.minOrder;
    
    return copyFilter;
}

/*==========================================================================================
 isEqual implementation
 ==========================================================================================*/
- (BOOL) isEqual: (id) object {
    if ([object class] == [self class]){
        PassFilter * temp = object;
        
        if (([self.biquads isEqual:temp.biquads] == NO) ||
            (self.maxOrder != temp.maxOrder) || (self.minOrder != temp.minOrder)) {
            return NO;
        }
        
        return YES;
    }
    return NO;
}

// getter/setter
-(PassFilterOrder_t) getOrder {
    if (self.biquads) {
        switch (self.biquads.count) {
            case 0:
                return PASSFILTER_ORDER_0;
            case 1:
                return PASSFILTER_ORDER_2;
            case 2:
                return PASSFILTER_ORDER_4;
            case 4:
                return PASSFILTER_ORDER_8;
            default:
                return PASSFILTER_ORDER_UNK;
        }
    }
    return PASSFILTER_ORDER_0;
}
    
-(void) setType:(PassFilterType_t)type {
    type = (type == BIQUAD_LOWPASS) ? BIQUAD_LOWPASS : BIQUAD_HIGHPASS;
    
    if (_biquads) {
        for (int i = 0; i < _biquads.count; i++) {
            BiquadParam * p = [[_biquads objectAtIndex:i] biquadParam];
            p.type = type;
        }
    }
}

-(PassFilterType_t) getType {
    if ((_biquads) && (_biquads.count > 0)) {
        return [[_biquads objectAtIndex:0] biquadParam].type;
    }
    return BIQUAD_OFF;
}

-(void) setFreq:(int)freq {
    if (_biquads) {
        for (int i = 0; i < _biquads.count; i++) {
            BiquadParam * p = [[_biquads objectAtIndex:i] biquadParam];
            p.freq = freq;
        }
    }
}

-(int) Freq {
    if ((_biquads) && (_biquads.count > 0)) {
        return [[_biquads objectAtIndex:0] biquadParam].freq;
    }
    return 0;
}

//border setter function
- (void) setBorderMaxFreq:(int)maxFreq minFreq:(int)minFreq {
    if (_biquads) {
        for (int i = 0; i < _biquads.count; i++) {
            BiquadParam * p = [[_biquads objectAtIndex:i] biquadParam];
            [p setBorderMaxFreq:maxFreq minFreq:minFreq];
        }
    }
}

- (void) setBorderMaxQfac:(double)maxQfac minQfac:(double)minQfac {
    if (_biquads) {
        for (int i = 0; i < _biquads.count; i++) {
            BiquadParam * p = [[_biquads objectAtIndex:i] biquadParam];
            [p setBorderMaxQ:maxQfac minQfac:minQfac];
        }
    }
}

- (void) setBorderMaxDbVolume:(double)maxDbVolume minDbVolume:(double)minDbVolume {
    if (_biquads) {
        for (int i = 0; i < _biquads.count; i++) {
            BiquadParam * p = [[_biquads objectAtIndex:i] biquadParam];
            [p setBorderMaxDbVol:maxDbVolume minDbVolume:minDbVolume];
        }
    }
}

- (void) setBorderMaxOrder:(PassFilterOrder_t)maxOrder minOrder:(PassFilterOrder_t)minOrder {
    self.maxOrder = maxOrder;
    self.minOrder = minOrder;
}

- (void) setBorderMaxFreq:(int)maxFreq minFreq:(int)minFreq
                  maxQfac:(double)maxQfac minQfac:(double)minQfac
              maxDbVolume:(double)maxDbVolume minQfac:(double)minDbVolume
                 maxOrder:(PassFilterOrder_t)maxOrder minOrder:(PassFilterOrder_t)minOrder {
    [self setBorderMaxFreq:maxFreq minFreq:minFreq];
    [self setBorderMaxQfac:maxQfac minQfac:minQfac];
    [self setBorderMaxDbVolume:maxDbVolume minDbVolume:minDbVolume];
    [self setBorderMaxOrder:maxOrder minOrder:minOrder];
}

//info string
-(NSString *)getInfo {
    int dbOnOctave[4] = {0, 12, 24, 48};// db/oct
    int index = [self getOrder];
    return [NSString stringWithFormat:@"%ddb/oct; Freq:%dHz", dbOnOctave[index], [self Freq]];
}

//send to dsp
- (void) sendWithResponse:(BOOL)response {

    PassFilterPacket_t packet;
    memset(&packet.addr, 0, 4);
    
    for (int i = 0; i < _biquads.count; i++) {
        packet.addr[i * 2]      = [[_biquads objectAtIndex:i] address0];
        packet.addr[i * 2 + 1]  = [[_biquads objectAtIndex:i] address1];
    }
    packet.filter.order = [self getOrder];
    packet.filter.type  = [self getType];
    packet.filter.freq  = self.Freq;
    
    //send data
    NSData *data = [[NSData alloc] initWithBytes:&packet length:sizeof(PassFilterPacket_t)];
    
    [[HiFiToyControl sharedInstance] sendDataToDsp:data withResponse:response];
}

@end
