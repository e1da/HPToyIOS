//
//  FilterLabel.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 03/10/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FilterLabel : UILabel

@property (nonatomic) CGFloat size;

- (id) initWithText:(NSString *)text withFontSize:(CGFloat)size;

@end

NS_ASSUME_NONNULL_END
