//
//  KeyboardView.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 04/11/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KeyboardButton.h"

NS_ASSUME_NONNULL_BEGIN

@protocol KeyboardViewDelegate

- (void) addChar:(KeyboardButton *)button;
- (void) didEnter;
- (void) didBackspace;

@end

@interface KeyboardView : UIView {
    KeyboardButton * buttons[4 * 4];
}

@property (nonatomic) id <KeyboardViewDelegate> delegate;

- (void) setEnabledPointButton:(BOOL) enabled;
- (void) setEnabledMinusButton:(BOOL) enabled;

@end

NS_ASSUME_NONNULL_END
