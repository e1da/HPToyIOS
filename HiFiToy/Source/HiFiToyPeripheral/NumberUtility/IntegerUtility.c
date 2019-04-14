//
//  IntegerUtility.c
//  HiFiToy
//
//  Created by Kerosinn_OSX on 14/04/2019.
//  Copyright © 2019 Kerosinn_OSX. All rights reserved.
//

#include "IntegerUtility.h"

uint32_t reverseUint32(uint32_t num) {
    uint32_t result;
    uint8_t * pSrc = (uint8_t *)&num;
    uint8_t * pDest = (uint8_t *)&result;
    
    pDest[0] = pSrc[3];
    pDest[1] = pSrc[2];
    pDest[2] = pSrc[1];
    pDest[3] = pSrc[0];
    
    return result;
}
