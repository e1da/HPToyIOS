//
//  BiquadCoefValueControl.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 26/10/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoefButton.h"
#import "Filters.h"
#import "NumValueControl.h"

NS_ASSUME_NONNULL_BEGIN

@protocol BiquadCoefValueControlDelegate

- (void) showKeyboardWithValue:(NumValueControl *)valControl;
//- (void) updateBiquadValueControl;

@end;

@interface BiquadCoefValueControl : UIView <NumValueControlDelegate> {
    NumValueControl * b0Label;
    NumValueControl * b1Label;
    NumValueControl * b2Label;
    NumValueControl * a1Label;
    NumValueControl * a2Label;
    UIButton * syncButton;
}

@property (nonatomic) id <BiquadCoefValueControlDelegate> delegate;

@property (nonatomic) Filters * filters;

- (void) update;
- (void) updateCoefValueControl:(NumValueControl *)control;
@end

NS_ASSUME_NONNULL_END
