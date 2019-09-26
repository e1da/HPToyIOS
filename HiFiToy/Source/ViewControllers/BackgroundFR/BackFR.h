//
//  FiltersBackground.h
//  BackgroundFR
//
//  Created by Kerosinn_OSX on 05/09/2019.
//  Copyright © 2019 Kerosinn_OSX. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum {
    HZ20_DB0, HZ1000_DB0
} FB_Center_t;

@interface BackFR : NSObject {
    
}

@property (nonatomic) UIImage *             image;
@property (nonatomic) BOOL                  scaleTypeX;
@property (nonatomic, readonly) CGPoint     scale;
@property (nonatomic, readonly) CGPoint     translate;

+ (BackFR *)sharedInstance;

- (void) clear;
- (void) setScale:(float)deltaScale;
- (void) invertScaleType;

- (void) setTranslate:(CGPoint)deltaTranslate;

- (void) flipVertical;

@end

NS_ASSUME_NONNULL_END
