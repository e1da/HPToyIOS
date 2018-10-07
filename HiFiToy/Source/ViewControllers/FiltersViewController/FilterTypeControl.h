//
//  FilterTypeControl.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 04/10/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterLabel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FilterTypeControl : UIView

@property (nonatomic) UIButton * prevBtn;
@property (nonatomic) UIButton * nextBtn;
@property (nonatomic) FilterLabel * titleLabel;

@end

NS_ASSUME_NONNULL_END
