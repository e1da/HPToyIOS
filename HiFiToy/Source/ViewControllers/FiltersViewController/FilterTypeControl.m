//
//  FilterTypeControl.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 04/10/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "FilterTypeControl.h"
#import "FilterLabel.h"


@implementation FilterTypeControl

- (id) init {
    self = [super init];
    if (self) {
        [self setBackgroundColor:[UIColor darkGrayColor]];
        
        self.prevBtn = [self addButtonWithTitle:@"\u2329" withColor:[UIColor whiteColor] withBackColor:[UIColor clearColor]];
        self.nextBtn = [self addButtonWithTitle:@"\u232A" withColor:[UIColor whiteColor] withBackColor:[UIColor clearColor]];
        
        self.titleLabel = [[FilterLabel alloc] initWithText:@"ERROR" withFontSize:16.0];
        UIColor * c = [UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:0.5];
        self.titleLabel.textColor = c;//[UIColor orangeColor];
        [self addSubview:self.titleLabel];
    }
    return self;
}

- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    int width = frame.size.width;
    int height = frame.size.height;
    
    [self.prevBtn setFrame:CGRectMake(   0,              0, 0.25 * width, height)];
    [self.nextBtn setFrame:CGRectMake(   0.75 * width,    0, 0.25 * width, height)];
    [self.titleLabel setFrame:CGRectMake(0.25 * width,    0, 0.5 * width, height)];
}

- (UIButton *) addButtonWithTitle:(NSString *)title
                        withColor:(UIColor *)color
                    withBackColor:(UIColor *)backColor {
    UIButton * button = [[UIButton alloc] init];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:color forState:UIControlStateNormal];
    [button setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
    //[button setAttributedTitle: forState:UIControlStateNormal];
    [button setBackgroundColor:backColor];
    [self addSubview:button];
    
    return button;
}

@end
