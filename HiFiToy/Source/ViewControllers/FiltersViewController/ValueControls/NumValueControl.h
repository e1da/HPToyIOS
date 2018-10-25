//
//  NumValueControl.h
//  BlurOverlayTest
//
//  Created by Kerosinn_OSX on 02/10/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FilterLabel.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    NumberTypePositiveInteger,
    NumberTypeInteger,
    NumberTypePositiveFloat, // one symbol after point
    NumberTypeFloat,
    NumberTypePositiveDouble, // two symbol after point
    NumberTypeDouble
} NumberType_t;

@class NumValueControl;

@protocol NumValueControlDelegate

- (void) didPressNext:(NumValueControl *) control;
- (void) didPressPrev:(NumValueControl *) control;
- (void) didPressValue:(NumValueControl *) control;

@end;

@interface NumValueControl : UIView

@property (nonatomic) id <NumValueControlDelegate> delegate;

@property (nonatomic) double numValue;
@property (nonatomic) NumberType_t type;

@property (nonatomic) FilterLabel * leftLabel;
@property (nonatomic) FilterLabel * rightLabel;

+ (NumValueControl *) initWithType:(NumberType_t)type;

- (BOOL) isOnlyPositive;
- (BOOL) isOnlyInteger;

- (NSString *) getStringValue;


@end

NS_ASSUME_NONNULL_END
