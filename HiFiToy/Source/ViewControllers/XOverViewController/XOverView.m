//
//  SubFilterView.m
//  BTSub
//
//  Created by Kerosinn_OSX on 20/05/2015.
//  Copyright (c) 2015 Kerosinn_OSX. All rights reserved.
//

#import "XOverView.h"
#import "HiFiToyPreset.h"

/*==========================================================================================
 SubFilterView Implementation
 ==========================================================================================*/
@implementation XOverView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.maxFreq = 20000;
        self.minFreq = 10;
        
    }
    return self;
}


/*-----------------------------------------------------------------------------------------
 Math Calculation
 -----------------------------------------------------------------------------------------*/
- (double) freqToPixel:(int)freq{
    return a_coef * log10(freq) + b_coef;
    
}

- (double) pixelToFreq:(double)pix{
    return pow(10, (pix - b_coef) / a_coef);
}

- (double) dbToPixel:(double)db
{
    return c_coef * db + d_coef;
}

- (double) pixelToDb:(double)pixel
{
    return (pixel - d_coef) / c_coef;
}

- (int) getWidth
{
    return width;
}


- (int) getHeight
{
    return height;
}

- (int) getLowPassBorderPix
{
    int start_pix = width - border_right;
    double prev_y = [self.filters getAFR:[self pixelToFreq:start_pix]];
    int extremum_pix = start_pix - 1;
    
    while (extremum_pix > border_left){
        double y = [self.filters getAFR:[self pixelToFreq:extremum_pix]];
        if (y < prev_y){
            break;
        }
        prev_y = y;
        extremum_pix--;
    }
    return extremum_pix;
}

- (int) getHighPassBorderPix
{
    int start_pix = border_left;
    double prev_y = [self.filters getAFR:[self pixelToFreq:start_pix]];
    int extremum_pix = start_pix + 1;
    
    while (extremum_pix < (width - border_right)){
        double y = [self.filters getAFR:[self pixelToFreq:extremum_pix]];
        if ( y < prev_y ){
            break;
        }
        prev_y = y;
        extremum_pix++;
    }
    return extremum_pix;
}


/*-----------------------------------------------------------------------------------------
 Draw Calculation
 -----------------------------------------------------------------------------------------*/
- (void) view_refresh
{
    border_left = 20;
    border_right = 20;
    border_top = _initHeight + 10;
    border_bottom = 20;
    
    height = (int)[self bounds].size.height;
    width = (int)[self bounds].size.width;
    
    //check iphone x
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ){
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        //NSLog(@"%f %f", screenSize.width, screenSize.height);
        if ((screenSize.width == 812) || (screenSize.height == 812)){
            border_right = 55;
            border_left = 30;
            border_bottom = 40;
        }
    }
    
    /*	a_coef*log10(MAX_FREQ)+b_coef = width - border_right
     a_coef*log10(MIN_FREQ)+b_coef = border_left
     =>
     a_coef*log10(MAX_FREQ) + border_left - a_coef*log10(MIN_FREQ) = width - border_right
     a_coef*(log10(MAX_FREQ)-log10(MIN_FREQ)) = width - (border_left + border_right)
     
     */
    a_coef = (double)(width - (border_left + border_right)) / (log10((double)self.maxFreq) - log10((double)self.minFreq));
    b_coef = border_left - a_coef * log10((double)self.minFreq);
    
    /*	15*c_coef + d_coef = border_top
     *  -30*c_coef + d_coef = height - border_bottom
     *  =>
     *  15*c_coef + height - border_bottom + 30*c_coef = border_top
     *  c_coef = (border_top + border_bottom - height) / (15 + 30)
     */
    c_coef = (double)(border_top + border_bottom - height) / (15 + 30);
    d_coef = height - border_bottom + 30*c_coef;
    
    
}

/*-----------------------------------------------------------------------------------------
 Draw Methods
 -----------------------------------------------------------------------------------------*/
- (void) drawGrid:(CGContextRef)context
{
    //prepare color settings
    CGContextSetStrokeColorWithColor(context, [[UIColor grayColor] CGColor]);
    CGContextSetLineWidth(context, 1.0);
    
    
    int weight = 10;
    int freq = 10;
    
    while (freq <= self.maxFreq){
        //draw vertical line
        CGContextMoveToPoint(context, [self freqToPixel:freq], (float)(border_top));
        CGContextAddLineToPoint(context, [self freqToPixel:freq], (float)(height - border_bottom));
        
        if (freq >= 100) weight = 100;
        if (freq >= 1000) weight = 1000;
        if (freq >= 10000) weight = 10000;
        
        freq += weight;
    }
    
    //draw horizontal line and db units
    for (int i = 15; i >= -30; i -= 5){
        CGContextMoveToPoint(context, (float)(border_left), [self dbToPixel:i]);
        CGContextAddLineToPoint(context, (float)(width - border_right), [self dbToPixel:i]);
        
    }
    
    CGContextDrawPath(context, kCGPathStroke);
}

- (void) drawGridUnits:(CGContextRef)context
{
    //prepare font and style for horizontal symbols
    UIFont *font = [UIFont fontWithName:@"Palatino-Roman" size:14.0];
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentCenter;
    
    NSMutableDictionary * attr = [[NSMutableDictionary alloc] init];
    [attr setObject:style forKey:NSParagraphStyleAttributeName];
    [attr setObject:font forKey:NSFontAttributeName];
    
    //draw freq units
    //int drawFreqUnits[7] = {20, 50, 100, 500, 1000, 10000, 20000};
    
    if (_drawFreqUnitArray){
        for (int i = 0; i < _drawFreqUnitArray.count; i++){
            int drawFreq = [[_drawFreqUnitArray objectAtIndex:i] intValue];
            
            if (drawFreq > self.maxFreq)
                break;
            
            //draw freq unit string
            NSString *freqString;
            if (drawFreq >= 1000){
                freqString = [NSString stringWithFormat:@"%dkHz", drawFreq / 1000];
            } else {
                freqString = [NSString stringWithFormat:@"%dHz", drawFreq];
            }

            CGRect rect;
            
            if (drawFreq == 500){
                rect = CGRectMake( ([self freqToPixel:drawFreq] - 25), height - border_bottom, // x y
                                  45, 30); //width height
            } else {
                rect = CGRectMake( ([self freqToPixel:drawFreq] - 15), height - border_bottom, // x y
                                  45, 30); //width height
            }
            
            [freqString drawInRect:rect withAttributes:attr];
        }
    }
    
    
    //prepare font and style for vertical symbols
    font = [UIFont fontWithName:@"Palatino-Roman" size:12.0];
    style.alignment = NSTextAlignmentRight;
    
    [attr setObject:style forKey:NSParagraphStyleAttributeName];
    [attr setObject:font forKey:NSFontAttributeName];
    
    //draw horizontal line and db units
    for (int i = 15; i > -30; i -= 5){
        
        NSString *dbString = [NSString stringWithFormat:@"%d", i];
        CGRect rect = CGRectMake(0, [self dbToPixel:i] - 5, // x y
                                 [self freqToPixel:20] - 2, 30); //width height
        
        [dbString drawInRect:rect withAttributes:attr];
    }

}


- (void) drawFilters:(CGContextRef)context
{
    int highpass_freq_pix = 0;
    int lowpass_freq_pix = 0;
    BOOL change_color_flag = NO;
    
    CGContextSetLineWidth(context, 2.0);
    
    BiquadType_t type = [[_filters getActiveBiquad] biquadParam].type;
    
    if (type == BIQUAD_HIGHPASS) {
        CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
        
        //if (self.xover.hp.order != FILTER_ORDER_0) {
            highpass_freq_pix = [self getHighPassBorderPix];
        /*} else {
            ParamFilter * param = [self.xover.params paramWithMinFreq];
            highpass_freq_pix = [self freqToPixel:param.freq];
        }*/
        
    } else {
        CGContextSetStrokeColorWithColor(context, [[UIColor blueColor] CGColor]);
        
        if (type == BIQUAD_LOWPASS){
            //if (self.xover.lp.order != FILTER_ORDER_0) {
                lowpass_freq_pix = [self getLowPassBorderPix];
            /*} else {
                ParamFilter * param = [self.xover.params paramWithMaxFreq];
                lowpass_freq_pix = [self freqToPixel:param.freq];
            }*/
        }
    }
    
    bool start = NO;
    double i = border_left;
    
    while (i <= width - border_right){
        double y = [self.filters getAFR:[self pixelToFreq:i] ];
        
        if ((i > highpass_freq_pix) && (type == BIQUAD_HIGHPASS) && (!change_color_flag)){
            CGContextDrawPath(context, kCGPathStroke);
            
            change_color_flag = YES;
            start = NO;
            CGContextSetStrokeColorWithColor(context, [[UIColor blueColor] CGColor]);
        }
        if ((i > lowpass_freq_pix) && (type == BIQUAD_LOWPASS) && (!change_color_flag)){
            CGContextDrawPath(context, kCGPathStroke);
            
            change_color_flag = YES;
            start = NO;
            CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
        }
        
        if (y > CLIP_DB){
            if (!start){
                start = YES;
                CGContextMoveToPoint(context, (float)i, [ self dbToPixel:(20.0f * log10(y)) ] );
            } else {
                CGContextAddLineToPoint(context, (float)i, [ self dbToPixel:(20.0f * log10(y)) ] );
            }
        }
        i++;
    }
    
    CGContextDrawPath(context, kCGPathStroke);
    
    [self drawFreqLineForParamFilters:(CGContextRef)context];
    [self drawFreqLineForAllpassFilters:(CGContextRef)context];
    [self drawPassFilterTap:context];
    
}

- (void) drawFreqLineForParamFilters:(CGContextRef)context {
    NSArray<BiquadLL *> * params = [_filters getBiquadsWithType:BIQUAD_PARAMETRIC];
    [self drawFreqLineForBiquads:params withColor:[UIColor brownColor] withContext:context];
}

- (void) drawFreqLineForAllpassFilters:(CGContextRef)context {
    NSArray<BiquadLL *> * allpass = [_filters getBiquadsWithType:BIQUAD_ALLPASS];
    [self drawFreqLineForBiquads:allpass withColor:[UIColor purpleColor] withContext:context];
}

- (void) drawFreqLineForBiquads:(NSArray<BiquadLL *> *)biquads withColor:(UIColor *)color withContext:(CGContextRef)context{
    if (!biquads) return;
    
    for (int i = 0; i < biquads.count; i++) {
        BiquadLL * b = [biquads objectAtIndex:i];
        
        if (!b.enabled) continue;
        
        if ((b == [_filters getActiveBiquad]) && (!_filters.activeNullLP) && (!_filters.activeNullHP)){
            CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
            CGContextSetLineWidth(context, 3.0);
        } else {
            CGContextSetStrokeColorWithColor(context, [color CGColor]);
            CGContextSetAlpha(context, 1.0f);
            CGContextSetLineWidth(context, 2.0);
        }
        
        CGFloat dashes[] = {10,10};
        CGContextSetLineDash(context, 0.0, dashes, 2);
        
        uint16_t f = b.biquadParam.freq;
        
        CGContextMoveToPoint(context, (float)[self freqToPixel:f], border_top);
        CGContextAddLineToPoint(context, (float)[self freqToPixel:f], height - border_bottom);
        
        CGContextDrawPath(context, kCGPathStroke);
        CGContextSetLineDash(context, 0.0, dashes, 0);
    }
    
}


- (void) drawPassFilterTap:(CGContextRef)context {
    CGPoint point;
    
    if (![_filters getLowpass]) {
        if (_filters.activeNullLP) {
            CGContextSetFillColorWithColor(context, [[UIColor redColor] CGColor]);
        } else {
            CGContextSetFillColorWithColor(context, [[UIColor brownColor] CGColor]);
        }
        
        point.x = width - border_right;
        point.y = [self.filters getAFR:[self pixelToFreq:width - border_right] ];
        
        if (point.y > CLIP_DB) {
            CGContextFillEllipseInRect(context, CGRectMake(point.x - 5, [ self dbToPixel:(20.0f * log10(point.y)) ]  - 5, 10, 10));
            CGContextDrawPath(context, kCGPathStroke);
        }
        
    }
    if (![_filters getHighpass]) {
        if (_filters.activeNullHP) {
            CGContextSetFillColorWithColor(context, [[UIColor redColor] CGColor]);
        } else {
            CGContextSetFillColorWithColor(context, [[UIColor brownColor] CGColor]);
        }
        
        point.x = border_left;
        point.y = [self.filters getAFR:[self pixelToFreq:border_left] ];
        
        if (point.y > CLIP_DB) {
            CGContextFillEllipseInRect(context, CGRectMake(point.x - 5, [ self dbToPixel:(20.0f * log10(point.y)) ]  - 5, 10, 10));
            CGContextDrawPath(context, kCGPathStroke);
        }
        
    }
}

/*-----------------------------------------------------------------------------------------
 Main Draw
 -----------------------------------------------------------------------------------------*/
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self view_refresh];
    
    [self drawGrid:context];
    [self drawGridUnits:context];
    
    [self drawFilters:context];
    
}

@end
