//
//  CoefWarningController.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 03/11/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DontShowView.h"

NS_ASSUME_NONNULL_BEGIN

@interface CoefWarningController : UIViewController {
    UITextView * textView;
    DontShowView * dontShowView;
    UIButton * continueButton;
}

@end

NS_ASSUME_NONNULL_END
