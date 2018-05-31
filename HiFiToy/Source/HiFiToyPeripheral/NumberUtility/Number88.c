//
//  Number88.c
//  
//
//  Created by Artem Khlyupin on 05/28/2018.
//

#include "Number88.h"

Number88_t to88(float number){
    return (Number88_t)((float)number * 0x100);
}

Number88_t to88Reverse(float number){
	return reverseNumber88(to88(number));
}

float _88toFloat(Number88_t number88){
    return (float)number88 / 0x100;  
}

Number88_t reverseNumber88(Number88_t number88){
	Number88_t result;
	uint8_t * pSrc = (uint8_t *)&number88;
	uint8_t * pDest = (uint8_t *)&result;
	
	pDest[0] = pSrc[1];
	pDest[1] = pSrc[0];
	
	return result;
}
