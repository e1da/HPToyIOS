//
//  FloatUtility.c
//  HiFiToy
//
//  Created by Kerosinn_OSX on 09/10/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#include "FloatUtility.h"
#include <math.h>

//accurancy = max float numbers between arg0 and arg1
bool isFloatEqualWithAccuracy(float arg0, float arg1, int accuracy) {
    int32_t arg0Int = *(int32_t *)&arg0;
    int32_t arg1Int = *(int32_t *)&arg1;
    if (arg0Int < 0) arg0Int = 0x80000000 - arg0Int; //float mantis to 2`s complement
    if (arg1Int < 0) arg1Int = 0x80000000 - arg1Int; //float mantis to 2`s complement
    
    uint32_t diff = (arg0Int > arg1Int) ? (arg0Int - arg1Int) : (arg1Int - arg0Int);
    
    return (diff < accuracy);
}

bool isFloatNull(float f) {
    return isFloatEqualWithAccuracy(f, 0.0f, 16);
}

bool isFloatDiffLessThan(float f0, float f1, float maxDiff) {
    return fabsf(f0 - f1) < maxDiff;
}

bool isCoefEqual(float c0, float c1) {
    return isFloatEqualWithAccuracy(c0, c1, 16);
}
