//
//  FloatUtility.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 09/10/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#ifndef FloatUtility_h
#define FloatUtility_h

#include <stdbool.h>
#include <stdint.h>

extern bool isFloatEqualWithAccuracy(float arg0, float arg1, int accuracy);
extern bool isFloatNull(float f);

extern bool isFloatDiffLessThan(float f0, float f1, float maxDiff);

#endif /* FloatUtility_h */
