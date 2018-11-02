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
        
        self.backgroundColor = [UIColor darkGrayColor];
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
    UIFont *font = [UIFont fontWithName:@"ArialRoundedMTBold" size:12.0];
    //UIFont *font = [UIFont fontWithName:@"Palatino-Roman" size:14.0];
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentCenter;
    
    
    NSMutableDictionary * attr = [[NSMutableDictionary alloc] init];
    [attr setObject:style forKey:NSParagraphStyleAttributeName];
    [attr setObject:font forKey:NSFontAttributeName];
    [attr setObject:[UIColor lightGrayColor] forKey:NSForegroundColorAttributeName];
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
    font = [UIFont fontWithName:@"ArialRoundedMTBold" size:10.0];
    //font = [UIFont fontWithName:@"Palatino-Roman" size:12.0];
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

- (void) drawAfr:(CGContextRef)context withPoints:(NSMutableData *)points withComplement:(FillViewComplement_t) complement {
    if ((!points) || (points.length < 2 * sizeof(CGPoint)) ) return;
    
    unsigned long size = points.length / sizeof(CGPoint);
    CGPoint * p = (CGPoint *)points.bytes;
    
    CGPoint firstPoint = p[0];
    firstPoint.y = [self dbToPixel:0];
    CGPoint lastPoint = p[size - 1];
    lastPoint.y = [self dbToPixel:0];
    
    [points appendBytes:&lastPoint length:sizeof(CGPoint)];
    [points appendBytes:&firstPoint length:sizeof(CGPoint)];
    //update p pointer after append new points
    p = (CGPoint *)points.bytes;
    
    UIColor * c = [UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:0.1];
    CGContextSetFillColorWithColor(context, [c CGColor]);
    
    CGContextAddLines(context, p, size + 2);
    CGContextDrawPath(context, kCGPathFill);
    
    if ((complement == LEFT_COMPLEMENT) || (complement == BOTH_COMPLEMENT)) {
        CGRect rect = CGRectMake([self freqToPixel:self.minFreq], [self dbToPixel:0],
                                 p[0].x - [self freqToPixel:self.minFreq], [self dbToPixel:-30] - [self dbToPixel:0]);
        
        CGContextAddRect(context, rect);
        CGContextDrawPath(context, kCGPathFill);
    }
    if ((complement == RIGHT_COMPLEMENT) || (complement == BOTH_COMPLEMENT)) {
        CGPoint lP = p[size - 1];
        CGRect rect = CGRectMake([self freqToPixel:self.maxFreq], [self dbToPixel:0],
                                 lP.x - [self freqToPixel:self.maxFreq], [self dbToPixel:-30] - [self dbToPixel:0]);
        
        CGContextAddRect(context, rect);
        CGContextDrawPath(context, kCGPathFill);
    }
    
    
    //draw stroke
    CGContextAddLines(context, p, size);
    CGContextDrawPath(context, kCGPathStroke);
    
    
    
}

- (void) drawFilters:(CGContextRef)context
{
    int highpass_freq_pix = 0;
    int lowpass_freq_pix = 0;
    
    CGContextSetLineWidth(context, 2.0);
    
    BiquadType_t type = [[_filters getActiveBiquad] type];
    
    if (type == BIQUAD_HIGHPASS) {
        CGContextSetStrokeColorWithColor(context, [[UIColor orangeColor] CGColor]);
        
        highpass_freq_pix = [self getHighPassBorderPix];

    } else {
        CGContextSetStrokeColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
        
        if (type == BIQUAD_LOWPASS){
            lowpass_freq_pix = [self getLowPassBorderPix];
        }
    }

    //get points
    NSMutableData * points = [[NSMutableData alloc] init];
    
    for (int i = border_left; i <= width - border_right; i++) {
        double y = [self.filters getAFR:[self pixelToFreq:i] ];
        
        if ((i == highpass_freq_pix) && (type == BIQUAD_HIGHPASS)){
            CGPoint p = CGPointMake(i, [ self dbToPixel:(20.0f * log10(y)) ]);
            [points appendBytes:&p length:sizeof(CGPoint)];
            [self drawAfr:context withPoints:points withComplement:LEFT_COMPLEMENT];
            points = [[NSMutableData alloc] init];
            
            CGContextSetStrokeColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
        }
        if ((i == lowpass_freq_pix) && (type == BIQUAD_LOWPASS)){
            CGPoint p = CGPointMake(i, [ self dbToPixel:(20.0f * log10(y)) ]);
            [points appendBytes:&p length:sizeof(CGPoint)];
            [self drawAfr:context withPoints:points withComplement:LEFT_COMPLEMENT];
            points = [[NSMutableData alloc] init];
            
            CGContextSetStrokeColorWithColor(context, [[UIColor orangeColor] CGColor]);
        }
        
        if (y > CLIP_DB){
            CGPoint p = CGPointMake(i, [ self dbToPixel:(20.0f * log10(y)) ]);
            [points appendBytes:&p length:sizeof(CGPoint)];
        }
        
    }
    
    FillViewComplement_t com;
    if ( (type == BIQUAD_HIGHPASS) || (type == BIQUAD_LOWPASS) ){
        com = RIGHT_COMPLEMENT;
    } else {
        com = BOTH_COMPLEMENT;
    }
    [self drawAfr:context withPoints:points withComplement:com];
    
    [self drawFreqLineForParamFilters:(CGContextRef)context];
    [self drawFreqLineForAllpassFilters:(CGContextRef)context];
    [self drawPassFilterTap:context];
    
}

- (void) drawFreqLineForParamFilters:(CGContextRef)context {
    NSArray<BiquadLL *> * params = [_filters getBiquadsWithType:BIQUAD_PARAMETRIC];
    [self drawFreqLineForBiquads:params
                       withColor:[UIColor brownColor] withSelectColor:[UIColor orangeColor]
                     withContext:context];
}

- (void) drawFreqLineForAllpassFilters:(CGContextRef)context {
    NSArray<BiquadLL *> * allpass = [_filters getBiquadsWithType:BIQUAD_ALLPASS];
    UIColor * c = [UIColor colorWithRed:0.2 green:0.5 blue:1.0 alpha:0.5];
    UIColor * sc = [UIColor colorWithRed:0.2 green:0.5 blue:1.0 alpha:1.0];
    [self drawFreqLineForBiquads:allpass
                       withColor:c withSelectColor:sc
                     withContext:context];
}

- (void) drawFreqLineForBiquads:(NSArray<BiquadLL *> *)biquads
                      withColor:(UIColor *)color
                withSelectColor:(UIColor *)selColor
                    withContext:(CGContextRef)context{
    if (!biquads) return;
    
    for (int i = 0; i < biquads.count; i++) {
        BiquadLL * b = [biquads objectAtIndex:i];
        
        if (!b.enabled) continue;
        
        if ((b == [_filters getActiveBiquad]) && (!_filters.activeNullLP) && (!_filters.activeNullHP)){
            CGContextSetStrokeColorWithColor(context, [selColor CGColor]);
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
            CGContextSetFillColorWithColor(context, [[UIColor orangeColor] CGColor]);
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
            CGContextSetFillColorWithColor(context, [[UIColor orangeColor] CGColor]);
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
