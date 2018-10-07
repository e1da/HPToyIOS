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
#import "XOver.h"

NS_ASSUME_NONNULL_BEGIN



@interface FiltersViewController : UIViewController <NumKeyboardDelegate> {
    id <HiFiToyObject> activeElement;
}

@property XOver * xover;

@end

NS_ASSUME_NONNULL_END
