//
//  CoefWarningView.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 02/11/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "CoefWarningView.h"

@implementation CoefWarningView

- (id) init {
    self = [super init];
    if (self) {
        infoLabel = [[UITextView alloc] init];
        infoLabel.text = @"Please be careful, this feature for geeks only. The text biquad entering requires exact values of coefficients, any mistake could make loud artifact-sounds which could be dangerous for your speakers! Try to simulate your settings first in some DSP/Filter design software(Matlab, SigmaStudio etc), and tap the BIQUAD SYNC next.";
        infoLabel.textColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5];
        infoLabel.backgroundColor = [UIColor darkGrayColor];
        [self addSubview:infoLabel];
        
        continueButton = [[UIButton alloc] init];
        [continueButton setTitle:@"Continue" forState:UIControlStateNormal];
        [self addSubview:continueButton];
    }
    return self;
}

- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    infoLabel.frame = CGRectMake(0,         0,              width,      height - 50);
    continueButton.frame = CGRectMake(0,    height - 50,    width / 2,  50);
}

@end
