//
//  PeqValueControl.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 25/10/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NumValueControl.h"
#import "Filters.h"

NS_ASSUME_NONNULL_BEGIN

@protocol BiquadValueControlDelegate

- (void) showKeyboardWithValue:(NumValueControl *)valControl;
- (void) updateBiquadValueControl;

@end;

@interface BiquadValueControl : UIControl <NumValueControlDelegate>{
    NumValueControl * freqControl;
    NumValueControl * volumeControl;
    NumValueControl * qfacControl;
}

@property (nonatomic) id <BiquadValueControlDelegate> delegate;

@property (nonatomic) Filters * filters;
@property (nonatomic) BOOL showOnlyFreq;

- (void) update;
- (void) updateValueControl:(NumValueControl *)control;
@end

NS_ASSUME_NONNULL_END
