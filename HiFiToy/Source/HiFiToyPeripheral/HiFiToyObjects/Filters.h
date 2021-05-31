//
//  Filters.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 10/10/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Biquad.h"
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
- (Biquad *)  getBiquadAtIndex:(uint8_t)index;
- (int)         getBiquadIndex:(Biquad *)biquad;
- (Biquad *)  getActiveBiquad;
- (void)        setBiquad:(Biquad *)biquad forIndex:(uint8_t)index;

- (void) getBiquadTypes:(BiquadType_t *)types;

- (void) incActiveBiquadIndex;
- (void) decActiveBiquadIndex;
- (void) nextActiveBiquadIndex;
- (void) prevActiveBiquadIndex;

- (NSArray<Biquad *> *) getBiquadsWithType:(BiquadType_t)type;
- (Biquad *) getFreeBiquad;

- (PassFilter *) getLowpass;
- (PassFilter *) getHighpass;
- (BOOL) isLowpassFull;
- (BOOL) isHighpassFull;
- (void) upOrderFor:(PassFilterType_t)type;
- (void) downOrderFor:(PassFilterType_t)type;

- (BOOL) isPEQEnabled;
- (void) setPEQEnabled:(BOOL)enabled;

- (int) getBetterNewFreq;

- (double) getAFR:(double)freqX;

@end

NS_ASSUME_NONNULL_END
