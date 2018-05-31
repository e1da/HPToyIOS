//
//  Number923.c
//  
//
//  Created by Artem Khlyupin on 04/19/2018.
//

#include "Number923.h"
#include "Number523.h"

Number923_t to923(float number){
	return to523(number);
}

Number923_t to923Reverse(float number){
	return to523Reverse(number);
}

float _923toFloat(Number923_t number923){
    return (float)number923 / 0x800000;  
}

Number923_t reverseNumber923(Number923_t number923){
	return reverseNumber523(number923);
}