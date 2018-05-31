//
//  Number88.h
//  
//
//  Created by Artem Khlyupin on 05/28/2018.
//

#ifndef NUMBER_88_h
#define NUMBER_88_h

#include <stdint.h>

typedef int16_t Number88_t;

extern Number88_t to88(float number);
extern Number88_t to88Reverse(float number);

extern float _88toFloat(Number88_t number88);

extern Number88_t reverseNumber88(Number88_t number88); 

#endif
