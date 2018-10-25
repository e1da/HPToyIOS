//
//  Filters.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 10/10/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BiquadLL.h"
#import "PassFilter.h"

NS_ASSUME_NONNULL_BEGIN

@interface Filters : NSObject <HiFiToyObject, NSCoding, NSCopying, XmlParserDelegate>

@property (nonatomic)   int     address0;
@property (nonatomic)   int     address1; //if == 0 then off else stereo (2nd channel)

@property (nonatomic) uint8_t   activeBiquadIndex;
@property (nonatomic) BOOL      activeNullLP;
@property (nonatomic) BOOL      activeNullHP;

+ (Filters *)   initDefaultWithAddr0:(int)addr0 withAddr1:(int)addr1;

- (uint8_t)     getBiquadLength;
- (BiquadLL *)  getBiquadAtIndex:(uint8_t)index;
- (int)         getBiquadIndex:(BiquadLL *)biquad;
- (BiquadLL *)  getActiveBiquad;
- (void)        setBiquad:(BiquadLL *)biquad forIndex:(uint8_t)index;

- (void) nextActiveBiquadIndex;
- (void) prevActiveBiquadIndex;

- (NSArray<BiquadLL *> *) getBiquadsWithType:(BiquadType_t)type;
- (BiquadLL *) getFreeBiquad;

- (PassFilter *) getLowpass;
- (PassFilter *) getHighpass;
- (BOOL) isLowpassFull;
- (BOOL) isHighpassFull;
- (void) upOrderFor:(PassFilterType_t)type;
- (void) downOrderFor:(PassFilterType_t)type;

- (BOOL) isPEQEnabled;
- (void) setPEQEnabled:(BOOL)enabled;

- (double) getAFR:(double)freqX;

@end

NS_ASSUME_NONNULL_END
