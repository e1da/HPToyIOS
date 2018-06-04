//
//  Drc.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 30/05/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HiFiToyObject.h"
#import "DrcCoef.h"
#import "DrcTimeConst.h"

typedef enum : uint8_t {
    DISABLED_EVAL, PRE_VOLUME_EVAL, POST_VOLUME_EVAL
} DrcEvaluation_t;

@interface Drc : NSObject <HiFiToyObject, NSCoding, NSCopying, XmlParserDelegate> {
    float enabledCh[8]; // 0.0 .. 1.0, 8 channels
    DrcEvaluation_t evaluationCh[8];
}

@property (nonatomic) DrcCoef *         coef17;
@property (nonatomic) DrcCoef *         coef8;
@property (nonatomic) DrcTimeConst *    timeConst17;
@property (nonatomic) DrcTimeConst *    timeConst8;

+ (Drc *)initWithCoef17:(DrcCoef *)coef17
                  Coef8:(DrcCoef *)coef8
            TimeConst17:(DrcTimeConst *)timeConst17
             TimeConst8:(DrcTimeConst *)timeConst8;


-(void) setEnabled:(float)enabled forChannel:(uint8_t)channel; //enabled = 0.0 .. 1.0
-(float) getEnabledChannel:(uint8_t)channel; //return enabled = 0.0 .. 1.0

-(void) setEvaluation:(DrcEvaluation_t)evaluation forChannel:(uint8_t)channel;
-(float) getEvaluationChannel:(uint8_t)channel;

- (void) sendEvaluationWithResponse:(BOOL)response;
- (void) sendEnabledForChannel:(uint8_t)channel withResponse:(BOOL)response;

@end
