//
//  DontShowView.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 03/11/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "DontShowView.h"

#define SWITCH_HEIGHT   31
#define SWITCH_WIDTH    51
@implementation DontShowView

- (id) init {
    self = [super init];
    if (self) {
        msgLabel = [[UILabel alloc] init];
        msgLabel.text = @"Don`t show again";
        msgLabel.textColor = [UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:0.5];//[UIColor whiteColor];
        [self addSubview:msgLabel];
        
        showSwitch = [[UISwitch alloc] init];
        showSwitch.onTintColor = [UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:0.5];//[UIColor orangeColor];
        showSwitch.on = NO;
        [showSwitch addTarget:self action:@selector(changeShowSwitch:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:showSwitch];
   
    }
    return self;
}

- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    float width = self.frame.size.width;
    float height = self.frame.size.height;
    
    msgLabel.frame = CGRectMake(20, 0, width - 40 - SWITCH_WIDTH, height);
    showSwitch.frame = CGRectMake(width - 20 - SWITCH_WIDTH, height / 2 - SWITCH_HEIGHT / 2, 100, height);
}

- (void) changeShowSwitch:(UISwitch *)sender {
    [[NSUserDefaults standardUserDefaults] setBool:sender.on forKey:@"BiquadCoefWarningKey"];

}

@end
