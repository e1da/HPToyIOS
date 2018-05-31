//
//  Number923.h
//  
//
//  Created by Artem Khlyupin on 04/19/2018.
//

#ifndef NUMBER_923_h
#define NUMBER_923_h

#include <stdint.h>

typedef int32_t Number923_t;

extern Number923_t to923(float number);
extern Number923_t to923Reverse(float number);

extern float _923toFloat(Number923_t number923);

extern Number923_t reverseNumber923(Number923_t number923); 

#endif
