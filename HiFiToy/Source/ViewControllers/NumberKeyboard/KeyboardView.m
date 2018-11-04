//
//  KeyboardView.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 04/11/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "KeyboardView.h"

@implementation KeyboardView

- (id) init {
    self = [super init];
    if (self) {
        [self setBackgroundColor:[UIColor grayColor]];
        [self createButtons];
    }
    return self;
}

- (void) createButtons {
    for (int i = 0 ; i < 16; i++) buttons[i] = [[KeyboardButton alloc] init];
    
    for (int i = 0; i < 4; i++) { //row
        for (int u = 0; u < 4; u++) { //column
  
            int index = i * 4 + u;
            if ((index == 7) || (index == 11)) continue;
            
            KeyboardButton * btn = buttons[index];
            NSString * s;
            
            if (btn == [self getEnterButton]) {
                s = @"Enter";
                
            } else if (btn == [self getBackspaceButton]) {
                s = @"\u232B";
                
            } else if (btn == [self getMinusButton]) {
                s = @"-";
                
            } else if (btn == [self getPointButton]) {
                s = @".";
                
            } else {
                int n = (u + 1) + (i - 1) * 3;
                s = (n > 0) ? [NSString stringWithFormat:@"%d", n] : @"0";

            }
            
            [btn setTitle:s forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(didPressButton:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btn];
        }
    }
}

- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    float width = self.frame.size.width / 4;
    float height = self.frame.size.height / 4;
    
    for (int i = 0 ; i < 16; i++) {
        if ((i == 7) || (i == 11)) continue;
        
        CGFloat x = i % 4 * width;
        CGFloat y = (3 - i / 4) * height;
        if (buttons[i] == [self getEnterButton]) {
            [buttons[i] setFrame:CGRectMake(x, height, width, 3 * height)];
        } else {
            [buttons[i] setFrame:CGRectMake(x, y, width, height)];
        }
    
    }
    
    
}


- (KeyboardButton *) getBackspaceButton {
    return buttons[15];
}

- (KeyboardButton *) getEnterButton {
    return buttons[3];
}

- (KeyboardButton *) getMinusButton {
    return buttons[0];
}

- (KeyboardButton *) getPointButton {
    return buttons[2];
}

- (void) setEnabledPointButton:(BOOL) enabled {
    [self getPointButton].enabled = enabled;
}

- (void) setEnabledMinusButton:(BOOL) enabled {
    [self getMinusButton].enabled = enabled;
}

-(void) didPressButton:(KeyboardButton *) button {
    if (!self.delegate) return;
    
    if (button == [self getEnterButton]) {
        [_delegate didEnter];
    } else if (button == [self getBackspaceButton]) {
        [_delegate didBackspace];
    } else {
        [_delegate addChar:button];
    }
}


@end
