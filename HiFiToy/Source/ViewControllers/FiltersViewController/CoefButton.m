//
//  CoefLabel.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 26/10/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "CoefButton.h"
#import "FilterLabel.h"

@implementation CoefButton

- (id) initWithText:(NSString *)text withFontSize:(CGFloat)size withAlign:(UIControlContentHorizontalAlignment)align {
    self = [super init];
    if (self) {
        self.size = size;
        self.contentHorizontalAlignment = align;
        [self setText:text];
    }
    return self;
}

- (void) setText:(NSString *)text {
    NSDictionary * attr = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"ArialRoundedMTBold" size:self.size]
                                                      forKey:NSFontAttributeName];
    NSAttributedString * attrStr =  [[NSMutableAttributedString alloc] initWithString:text attributes:attr];

    [self setAttributedTitle:attrStr forState:UIControlStateNormal];
    self.titleLabel.textColor = [UIColor orangeColor];
}

@end
