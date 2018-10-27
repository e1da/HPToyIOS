//
//  CoefLabel.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 26/10/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CoefButton : UIButton

@property (nonatomic) CGFloat size;

- (id) initWithText:(NSString *)text withFontSize:(CGFloat)size withAlign:(UIControlContentHorizontalAlignment)align;
- (void) setText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
