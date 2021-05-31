//
//  Number523.c
//  
//
//  Created by Artem Khlyupin on 04/12/2018.
//

#include "Number523.h"

static float getMaxFloatFor523() {
    float max = 16.0f;
    uint32_t temp = *((uint32_t *)&max) - 1;
    return *((float *)&temp);
}

static float getMinFloatFor523() {
    return -16.0f;
}

void checkFloatFor523(float * num) {
    float max = getMaxFloatFor523();
    float min = getMinFloatFor523();
    
    if (*num > max) *num = max;
    if (*num < min) *num = min;
}

Number523_t to523(float number){
    return (Number523_t)((float)number * 0x800000);
}

Number523_t to523Reverse(float number){
	return reverseNumber523(to523(number));
}

float _523toFloat(Number523_t number523){
    if (number523 & 0x8000000){//check sign (27bit)
        number523 |= 0xF0000000;
    }
    return (float)number523 / 0x800000;  
}

Number523_t reverseNumber523(Number523_t number523){
	Number523_t result;
	uint8_t * pSrc = (uint8_t *)&number523;
	uint8_t * pDest = (uint8_t *)&result;
	
	pDest[0] = pSrc[3];
	pDest[1] = pSrc[2];
	pDest[2] = pSrc[1];
	pDest[3] = pSrc[0];
	
	return result;
}
