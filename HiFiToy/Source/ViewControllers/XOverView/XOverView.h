//
//  SubFilterView.h
//  BTSub
//
//  Created by Kerosinn_OSX on 20/05/2015.
//  Copyright (c) 2015 Kerosinn_OSX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Filters.h"

/*==========================================================================================
 DEFINES
 ==========================================================================================*/
#define MIN_VIEW_DB     -30.0f
#define MAX_VIEW_DB     15.0f

typedef enum {
    NO_COMPLEMENT, LEFT_COMPLEMENT, RIGHT_COMPLEMENT, BOTH_COMPLEMENT
} FillViewComplement_t;

/*==========================================================================================
 SubFilterView Interface
 ==========================================================================================*/
@interface XOverView : UIView {
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

@property Filters * filters;

@property int maxFreq;
@property int minFreq;

@property NSArray * drawFreqUnitArray;

- (double) freqToPixel:(int)freq;
- (double) pixelToFreq:(double)pix;
- (double) dbToPixel:(double)db;
- (double) pixelToDb:(double)pixel;

- (int) getWidth;
- (int) getHeight;

- (int) getLowPassBorderPix;
- (int) getHighPassBorderPix;

@end
