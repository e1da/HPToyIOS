//
//  NavigationController.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 08/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavigationController : UINavigationController <UINavigationControllerDelegate>{
    UIImage * backgroundImage;
    
}

@property (nonatomic) UIView * clipView;

@end
