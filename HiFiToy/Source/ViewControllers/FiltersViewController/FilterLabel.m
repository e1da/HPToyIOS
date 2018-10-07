//
//  FilterLabel.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 03/10/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "FilterLabel.h"



@implementation FilterLabel


- (id) initWithText:(NSString *)text withFontSize:(CGFloat)size {
    self = [super init];
    if (self) {
        self.size = size;
        [self setText:text];
    }
    return self;
}

- (void) setText:(NSString *)text {
    NSDictionary * attr = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"ArialRoundedMTBold" size:self.size]
                                                      forKey:NSFontAttributeName];
    NSAttributedString * attrStr =  [[NSMutableAttributedString alloc] initWithString:text attributes:attr];
    
    self.attributedText = attrStr;
    self.textColor = [UIColor lightGrayColor];
    self.textAlignment = NSTextAlignmentCenter;
    [self setBackgroundColor:[UIColor clearColor]];
}


@end
