//
//  FiltersViewController.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 28/09/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NumKeyboardController.h"
#import "HiFiToyObject.h"
#import "Filters.h"
#import "BiquadValueControl.h"
#import "BiquadCoefValueControl.h"

NS_ASSUME_NONNULL_BEGIN



@interface FiltersViewController : UIViewController <NumKeyboardDelegate, BiquadValueControlDelegate, BiquadCoefValueControlDelegate> {

    UITapGestureRecognizer *        tapGesture;
    UILongPressGestureRecognizer *  longPressGesture;
    UIPanGestureRecognizer *        panGesture;
    UIPinchGestureRecognizer *      pinchGesture;
}

@property Filters * filters;

@end

NS_ASSUME_NONNULL_END
