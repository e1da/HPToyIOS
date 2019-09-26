//
//  FiltersBackground.m
//  BackgroundFR
//
//  Created by Kerosinn_OSX on 05/09/2019.
//  Copyright © 2019 Kerosinn_OSX. All rights reserved.
//

#import "BackFR.h"

@implementation BackFR

-(id) init {
    self = [super init];
    if (self) {
        [self clear];
    }
    return self;
}

+ (BackFR *)sharedInstance {
    static BackFR * sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BackFR alloc] init];
        
    });
    return sharedInstance;
}

- (void) setImage:(UIImage *)image {
    [self clear];
    _image = image;
    
}
- (void) clear {
    _image = nil;
    _scale.x = 1.0f;
    _scale.y = 1.0f;
    _scaleTypeX = YES;
    
    _translate.x = 0.0f;
    _translate.y = 0.0f;
}

- (void) setScale:(float)deltaScale {
    if (!_image) return;
    
    if (deltaScale > 1) {
        deltaScale = (deltaScale - 1) / 4 + 1;
    } else {
        deltaScale = 1.0f - (1.0f - deltaScale) / 4;
    }
    
    if (_scaleTypeX) {
        float sx = _scale.x * deltaScale;
        if ((sx > 16) || (sx < 0.0625f)) return;
        
        _scale.x = sx;
    } else {
        float sy = _scale.y * deltaScale;
        if ((sy > 16) || (sy < 0.0625f)) return;
        
        _scale.y = sy;
    }
    
}

- (void) invertScaleType {
    _scaleTypeX = !_scaleTypeX;
}

- (void) setTranslate:(CGPoint)deltaTranslate {
    if (!_image) return;
    
    _translate.x += deltaTranslate.x / 4;
    _translate.y += deltaTranslate.y / 4;
    
     NSLog(@"%f %f", _translate.x, _translate.y);
    
}

- (void) flipVertical {
    if (!_image) return;

    UIImageOrientation o = (_image.imageOrientation == UIImageOrientationUp) ? UIImageOrientationDownMirrored : UIImageOrientationUp;
    
    _image = [UIImage imageWithCGImage:_image.CGImage
                                 scale:_image.scale
                           orientation:o];
}

@end
