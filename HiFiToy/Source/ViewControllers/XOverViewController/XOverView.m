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
    double prev_y = [self getFilters_y:[self pixelToFreq:start_pix]];
    int extremum_pix = start_pix - 1;
    
    while (extremum_pix > border_left){
        double y = [self getFilters_y:[self pixelToFreq:extremum_pix]];
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
    double prev_y = [self getFilters_y:[self pixelToFreq:start_pix]];
    int extremum_pix = start_pix + 1;
    
    while (extremum_pix < (width - border_right)){
        double y = [self getFilters_y:[self pixelToFreq:extremum_pix]];
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
- (double) getFilters_y:(double)freq
{
    /*double result = 1.0f;
    
    for (NSString *key in [self.dspElements keyEnumerator]){
        id dspElemet = [self.dspElements objectForKey:key];
        
        if (![dspElemet respondsToSelector:@selector(getAFR:)]) continue;
        result *= [dspElemet getAFR:freq];
    }*/
    
    
    return [self.xover getAFR:freq];
}

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
    
    if (self.xover.hp == self.activeElement) {
        CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
        
        if (self.xover.hp.order != FILTER_ORDER_0) {
            highpass_freq_pix = [self getHighPassBorderPix];
        } else {
            ParamFilter * param = [self.xover.params paramWithMinFreq];
            highpass_freq_pix = [self freqToPixel:param.freq];
        }
        
    } else {
        CGContextSetStrokeColorWithColor(context, [[UIColor blueColor] CGColor]);
        
        if (self.xover.lp == self.activeElement){
            if (self.xover.lp.order != FILTER_ORDER_0) {
                lowpass_freq_pix = [self getLowPassBorderPix];
            } else {
                ParamFilter * param = [self.xover.params paramWithMaxFreq];
                lowpass_freq_pix = [self freqToPixel:param.freq];
            }
        }
    }
    
    bool start = NO;
    double i = border_left;
    //double prev_y = [self getFilters_y:[self pixelToFreq:i] ];
    
    while (i <= width - border_right){
        double y = [self getFilters_y:[self pixelToFreq:i] ];
        
        if ((i > highpass_freq_pix) && (self.xover.hp == self.activeElement) && (!change_color_flag)){
            CGContextDrawPath(context, kCGPathStroke);
            
            change_color_flag = YES;
            start = NO;
            CGContextSetStrokeColorWithColor(context, [[UIColor blueColor] CGColor]);
        }
        if ((i > lowpass_freq_pix) && (self.xover.lp == self.activeElement) && (!change_color_flag)){
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
        //prev_y = y;
    }
    
    CGContextDrawPath(context, kCGPathStroke);
    
    [self drawFreqLineForParamFilters:(CGContextRef)context];
    
    [self drawSimpleTap:context forPassFilter:self.xover.hp];
    [self drawSimpleTap:context forPassFilter:self.xover.lp];
    
}

- (void) drawFreqLineForParamFilters:(CGContextRef)context
{
    if (!self.xover.params) return;
    
    for (int i = 0; i < self.xover.params.count; i++) {
        ParamFilter * param = [self.xover.params paramAtIndex:i];
        
        if (![param isEnabled]) continue;
        
        if (param == self.activeElement) {
            CGContextSetStrokeColorWithColor(context, [[UIColor redColor] CGColor]);
            CGContextSetLineWidth(context, 3.0);
        } else {
            CGContextSetStrokeColorWithColor(context, [[UIColor brownColor] CGColor]);
            CGContextSetAlpha(context, 1.0f);
            CGContextSetLineWidth(context, 2.0);
        }
            
        CGFloat dashes[] = {10,10};
        CGContextSetLineDash(context, 0.0, dashes, 2);
            
        CGContextMoveToPoint(context, (float)[self freqToPixel:param.freq], border_top);
        CGContextAddLineToPoint(context, (float)[self freqToPixel:param.freq], height - border_bottom);
            
        CGContextDrawPath(context, kCGPathStroke);
        CGContextSetLineDash(context, 0.0, dashes, 0);
    }
    
}

- (void) drawTap:(CGContextRef)context forPassFilter:(PassFilter2 *)passFilter
{
    if (passFilter.order != FILTER_ORDER_0) return;
    
    if (self.activeElement == passFilter) {
        CGContextSetFillColorWithColor(context, [[UIColor redColor] CGColor]);
    } else {
        CGContextSetFillColorWithColor(context, [[UIColor brownColor] CGColor]);
    }
    
    bool start = NO;
    double p;
    
    int border_pix;
    CGPoint point;
    
    if (passFilter.type == BIQUAD_HIGHPASS) {
        
        border_pix = [self getHighPassBorderPix];
        if (border_pix <= border_left + 50) border_pix = width - border_right;
        p = width - border_right;
        
        for (int i = border_left; i < width - border_right; i++) {
            double y = [self getFilters_y:[self pixelToFreq:i] ];
            
            if ((y > CLIP_DB) && (!start)) {
                start = YES;
                p = i;
            }

            if ((i - p > 50) || (i > border_pix) ){
                point.x = i;
                point.y = (y > CLIP_DB) ? y : CLIP_DB;
                break;
            }
        }
        
    } else if (passFilter.type == BIQUAD_LOWPASS) {
        
        border_pix = [self getLowPassBorderPix];
        if (border_pix >= width - border_right - 50) border_pix = border_left;
        p = border_left;
        
        for (int i = width - border_right; i >= border_left; i--) {
            double y = [self getFilters_y:[self pixelToFreq:i] ];
            
            if ((y > CLIP_DB) && (!start)) {
                start = YES;
                p = i;
            }
            
            if ((p - i > 50) || (i < border_pix) ){
                point.x = i;
                point.y = (y > CLIP_DB) ? y : CLIP_DB;
                break;
            }
            
        }
    } else {
        return;
    }
    
    CGContextFillEllipseInRect(context, CGRectMake(point.x - 5, [ self dbToPixel:(20.0f * log10(point.y)) ]  - 5, 10, 10));
    CGContextDrawPath(context, kCGPathStroke);
}

- (void) drawSimpleTap:(CGContextRef)context forPassFilter:(PassFilter2 *)passFilter
{
    if (passFilter.order != FILTER_ORDER_0) return;
    
    if (self.activeElement == passFilter) {
        CGContextSetFillColorWithColor(context, [[UIColor redColor] CGColor]);
    } else {
        CGContextSetFillColorWithColor(context, [[UIColor brownColor] CGColor]);
    }
    
    CGPoint point;
    
    if (passFilter.type == BIQUAD_HIGHPASS) {
        point.x = border_left;
        point.y = [self getFilters_y:[self pixelToFreq:border_left] ];
        
    } else if (passFilter.type == BIQUAD_LOWPASS) {
        
        point.x = width - border_right;
        point.y = [self getFilters_y:[self pixelToFreq:width - border_right] ];
        
    } else {
        return;
    }
    
    if (point.y > CLIP_DB) {
        CGContextFillEllipseInRect(context, CGRectMake(point.x - 5, [ self dbToPixel:(20.0f * log10(point.y)) ]  - 5, 10, 10));
        CGContextDrawPath(context, kCGPathStroke);
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
