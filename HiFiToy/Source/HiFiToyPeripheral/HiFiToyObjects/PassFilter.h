//
//  PassFilter.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 30/05/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BiquadLL.h"

typedef BiquadType_t PassFilterType_t;

typedef enum : int8_t{
    PASSFILTER_ORDER_0      = 0,
    PASSFILTER_ORDER_2      = 1,
    PASSFILTER_ORDER_4      = 2,
    PASSFILTER_ORDER_8      = 3,
    PASSFILTER_ORDER_UNK    = 4
} PassFilterOrder_t;

#pragma pack(1)
typedef struct {
    PassFilterOrder_t   order;
    PassFilterType_t    type;
    uint16_t freq;
} PassFilter_t;

typedef struct {
    uint8_t             addr[8];        //0x00
    PassFilter_t        filter;         //0x08
    uint8_t             nc;
} PassFilterPacket_t;                   //size == 13
#pragma options align=reset

@interface PassFilter : NSObject <NSCopying>

@property (nonatomic)   NSArray<BiquadLL *> * biquads;
//border property
@property (nonatomic)   PassFilterOrder_t maxOrder;
@property (nonatomic)   PassFilterOrder_t minOrder;


+ (PassFilter *)initWithBiquads:(NSArray<BiquadLL *> *)biquads withType:(PassFilterType_t)type;

// getter/setter
//-(void) setOrder:(PassFilterOrder_t)order;
-(PassFilterOrder_t)    getOrder;
-(void)                 setType:(PassFilterType_t)type;
-(PassFilterType_t)     getType;

-(void) setFreq:(int)freq;
-(int) Freq;

//border setter function
- (void) setBorderMaxFreq:(int)maxFreq minFreq:(int)minFreq;
- (void) setBorderMaxQfac:(double)maxQfac minQfac:(double)minQfac;
- (void) setBorderMaxDbVolume:(double)maxDbVolume minDbVolume:(double)minDbVolume;
- (void) setBorderMaxOrder:(PassFilterOrder_t)maxOrder minOrder:(PassFilterOrder_t)minOrder;

- (void) setBorderMaxFreq:(int)maxFreq minFreq:(int)minFreq
                  maxQfac:(double)maxQfac minQfac:(double)minQfac
              maxDbVolume:(double)maxDbVolume minQfac:(double)minDbVolume
                 maxOrder:(PassFilterOrder_t)maxOrder minOrder:(PassFilterOrder_t)minOrder;

-(NSString *)getInfo;
//send to dsp
- (void) sendWithResponse:(BOOL)response;

@end
