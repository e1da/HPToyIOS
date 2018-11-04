//
//  NumKeyboardControllerViewController.h
//  TextEditTest
//
//  Created by Kerosinn_OSX on 30/09/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NumValueControl.h"
#import "KeyboardView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol NumKeyboardDelegate

- (void) didKeyboardEnter:(NumValueControl *) valControl;
- (void) didKeyboardClose;

@end


@interface NumKeyboardController : UIViewController <KeyboardViewDelegate>

@property (nonatomic) id<NumKeyboardDelegate> delegate;
@property (nonatomic) NumValueControl * valControl;

@end

NS_ASSUME_NONNULL_END
