//
//  DrcView.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 15/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <UIKit/UIKit.h>

#define GRID_STEP   12
#define DB_STEP_X   24
#define DB_STEP_Y   24


@interface DrcView : UIView {
    int width;
    int height;
    
    double border_left;
    double border_right;
    double border_top;
    double border_bottom;
    
    double a_coef;
    double b_coef;
    double c_coef;
    double d_coef;
}

@property double initHeight;

@property int maxDbX;
@property int minDbX;
@property int maxDbY;
@property int minDbY;

@property (nonatomic) int activePoint;

- (double) dbToPixelX:(double)db;
- (double) pixelXToDb:(double)pixel;
- (double) dbToPixelY:(double)db;
- (double) pixelYToDb:(double)pixel;

@end
