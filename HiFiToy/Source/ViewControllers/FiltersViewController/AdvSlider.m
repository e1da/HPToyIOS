//
//  AdvSlider.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 29/09/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "AdvSlider.h"

@interface AdvSlider() {
    UILabel * titleLabel;
}

@end

@implementation AdvSlider

+ (AdvSlider *) initWithTitle:(NSString *)title {
    AdvSlider * slider = [[AdvSlider alloc] init];
    if (slider) {
        UIImage * modImg = [slider drawText:title];
        [slider setThumbImage:[UIImage imageNamed:@"thumb"] forState:UIControlStateNormal];
    }
    return slider;
}

-(UIImage *) drawText:(NSString *)text {
    
    //calc rect
    CGRect trackRect = [self trackRectForBounds:self.bounds];
    CGRect thumbRect = [self thumbRectForBounds:self.bounds
                                      trackRect:trackRect
                                          value:self.value];
    
    //prepare font and style for horizontal symbols
    UIFont *font = [UIFont fontWithName:@"Palatino-Roman" size:16.0];
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentCenter;
    
    NSMutableDictionary * attr = [[NSMutableDictionary alloc] init];
    [attr setObject:style forKey:NSParagraphStyleAttributeName];
    [attr setObject:font forKey:NSFontAttributeName];
    
    //draw image
    CGSize size = thumbRect.size;
    UIGraphicsBeginImageContext(size);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIImage * im = [UIImage imageNamed:@"Image"];
    [im drawInRect:rect];
    
    //draw text
    rect = CGRectMake(0, size.height / 4, size.width, size.height / 2);
    [text drawInRect:rect withAttributes:attr];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    return newImage;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
/*- (void)drawRect:(CGRect)rect {
 
    [super drawRect:rect];
    //[self updateTitleLabelView];
}*/


@end
