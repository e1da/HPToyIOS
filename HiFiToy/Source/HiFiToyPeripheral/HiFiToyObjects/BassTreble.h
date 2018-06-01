//
//  BassTreble.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 30/05/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HiFiToyObject.h"
#import "BassTrebleChannel.h"



@interface BassTreble : NSObject <HiFiToyObject, NSCoding, NSCopying, XmlParserDelegate>{
    float enabledCh[8]; // 0.0 .. 1.0, 8 channels
}

@property (nonatomic)   BassTrebleChannel * bassTreble127;
@property (nonatomic)   BassTrebleChannel * bassTreble34;
@property (nonatomic)   BassTrebleChannel * bassTreble56;
@property (nonatomic)   BassTrebleChannel * bassTreble8;

+ (BassTreble *)initWithBassTreble127:(BassTrebleChannel *)bassTreble127
                        BassTreble34:(BassTrebleChannel *)bassTreble34
                       BassTreble56:(BassTrebleChannel *)bassTreble56
                         BassTreble8:(BassTrebleChannel *)bassTreble8;


-(void) setEnabledChannel:(uint8_t)channel Enabled:(float)enabled; //enabled = 0.0 .. 1.0
-(float) getEnabledChannel:(uint8_t)channel; //return enabled = 0.0 .. 1.0

- (void) sendEnabledWithChannel:(uint8_t)channel withResponse:(BOOL)response;

@end
