//
//  BiquadContainer.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 30/05/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HiFiToyObject.h"
#import "ParamFilter.h"

@interface ParamFilterContainer : NSObject <HiFiToyObject, NSCoding, NSCopying, XmlParserDelegate>

//getters/setters
- (int) count;
- (void) addParam:(ParamFilter *)param;
- (ParamFilter *) paramAtIndex:(NSUInteger)index;
- (void) removeAtIndex:(NSUInteger)index;
- (void) clear;
- (BOOL) containsParam:(ParamFilter *) param;
- (NSUInteger) indexOfParam:(ParamFilter *) param;

//- (void) setBiquadContainer:(BiquadContainer *) biquadContainer;

- (double) getAFR:(double)freqX;

//enabled methods
- (void) setEnabled:(BOOL)enabled;
- (BOOL) isEnabled;
- (BOOL) isActive;

- (ParamFilter *) getFirstEnabled;
- (ParamFilter *) getFirstDisabled;



@end
