//
//  KeyboardButton.m
//  TextEditTest
//
//  Created by Kerosinn_OSX on 01/10/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "KeyboardButton.h"

@implementation KeyboardButton

- (id) init {
    self  = [super init];
    if (self) {
        [self setHighlighted:NO];
        
    }
    return self;
}

- (void) setNeedsLayout {
    self.layer.borderWidth = 2.0f;
    self.layer.borderColor = [UIColor darkGrayColor].CGColor;
    [super setNeedsLayout];
}

- (void) setHighlighted:(BOOL)highlighted {
    if (highlighted) {
        self.backgroundColor = [UIColor darkGrayColor];
    } else {
        self.backgroundColor = [UIColor grayColor];
    }
}

- (void) setEnabled:(BOOL)enabled {
    [super setEnabled:enabled];
    
    if (enabled) {
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        [self setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
}

@end
