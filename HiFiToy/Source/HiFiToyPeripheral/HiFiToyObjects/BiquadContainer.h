//
//  BiquadContainer.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 30/05/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HiFiToyObject.h"
#import "Biquad.h"

@interface BiquadContainer : NSObject <HiFiToyObject, NSCoding, NSCopying, XmlParserDelegate>

//getters/setters
- (int) count;
- (void) addBiquad:(Biquad *)biquad;
- (Biquad *) biquadAtIndex:(NSUInteger)index;
- (void) clear;
//- (void) setBiquadContainer:(BiquadContainer *) biquadContainer;

//enabled methods
- (void) setEnabled:(BOOL)enabled;
- (BOOL) isEnabled;
- (BOOL) isActive;

@end
