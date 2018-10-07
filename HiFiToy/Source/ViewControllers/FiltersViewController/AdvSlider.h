//
//  AdvSlider.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 29/09/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdvSlider : UISlider

@property (nonatomic) NSString * title;

+ (AdvSlider *) initWithTitle:(NSString *)title;

@end

NS_ASSUME_NONNULL_END
