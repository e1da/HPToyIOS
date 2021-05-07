//
//  HiFiToyOutputMode.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 01/05/2021.
//  Copyright © 2021 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : uint8_t {
    BALANCE_OUT_MODE, UNBALANCE_OUT_MODE, UNBALANCE_BOOST_OUT_MODE
} OutputModeValue_t;

@interface HiFiToyOutputMode : NSObject

@property (getter=isHwSupported) BOOL   hwSupported;
@property (nonatomic) OutputModeValue_t value;

- (void) setBoost:(int16_t)boostValue;

- (void) sendToDsp;
- (void) readFromDsp;

@end

NS_ASSUME_NONNULL_END
