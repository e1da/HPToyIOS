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

@interface NumValueControl : UIControl

@property (nonatomic, readonly) double numValue;
@property (nonatomic, readonly) double deltaValue;
@property (nonatomic, readonly) NumberType_t type;

@property (nonatomic) FilterLabel * leftLabel;
@property (nonatomic) FilterLabel * rightLabel;

- (void) setNumValue:(double)numVal withDeltaValue:(double)deltaVal withType:(NumberType_t)t;

- (void) addValuePressEvent:(id)target action:(SEL)action;

- (BOOL) isOnlyPositive;
- (BOOL) isOnlyInteger;

- (NSString *) getStringValue;


@end

NS_ASSUME_NONNULL_END
