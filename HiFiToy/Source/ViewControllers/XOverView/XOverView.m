//
//  SubFilterView.m
//  BTSub
//
//  Created by Kerosinn_OSX on 20/05/2015.
//  Copyright (c) 2015 Kerosinn_OSX. All rights reserved.
//

#import "XOverView.h"
#import "BackFR.h"

/*==========================================================================================
 SubFilterView Implementation
 ==========================================================================================*/
@implementation XOverView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.maxFreq = 20000;
        self.minFreq = 10;
        self.visibleRelativeCenter = NO;
        
        self.filters = nil;
        
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

- (float)dbToAmpl:(float)db {
    return pow(10, (db / 20));
}

- (float)amplToDb:(float)ampl {
    return 20 * log10(ampl);
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
    
    //check iphone x, xr, xs, xs max for landscape orientation
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone ){
        CGSize screenSize = [[UIScreen mainScreen] bounds].size;
        //NSLog(@"%f %f", screenSize.width, screenSize.height);
        if (screenSize.width == 812) { // x, xs
            border_right = 55;
            border_left = 55;
            border_bottom = 40;
        } else if (screenSize.width == 896) { // xr, xs max
            border_right = 55;
            border_left = 55;
            border_bottom = 40;
        }
        /*if ((screenSize.width == 812) || (screenSize.height == 812)){
            border_right = 55;
            border_left = 30;
            border_bottom = 40;
        }*/
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

- (void) drawAfrShadow:(CGContextRef)context {
    NSMutableData * points = [[NSMutableData alloc] init];
    
    for (int i = border_left; i <= width - border_right; i++) {
        double ampl = [self.filters getAFR:[self pixelToFreq:i] ];
        double db = [self amplToDb:ampl];
        if (db < MIN_VIEW_DB) db = MIN_VIEW_DB;
        if (db > MAX_VIEW_DB) db = MAX_VIEW_DB;
        
        CGPoint p = CGPointMake(i, [self dbToPixel:db]);
        [points appendBytes:&p length:sizeof(CGPoint)];
    }
    
    //add 2 points [0,0] [fmax, 0]
    CGPoint lastP = CGPointMake(width - border_right, [self dbToPixel:0]);
    CGPoint firstP = CGPointMake(border_left, [self dbToPixel:0]);
    [points appendBytes:&lastP length:sizeof(CGPoint)];
    [points appendBytes:&firstP length:sizeof(CGPoint)];
    
    unsigned long size = points.length / sizeof(CGPoint);
    CGPoint * p = (CGPoint *)points.bytes;
    
    UIColor * shadowColor = [UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:0.1];
    CGContextSetFillColorWithColor(context, [shadowColor CGColor]);
    CGContextAddLines(context, p, size);
    CGContextDrawPath(context, kCGPathFill);
    
}

- (void) drawFilters:(CGContextRef)context {
    if (!_filters) return;
    
    [self drawAfrShadow:context];
    
    int highpass_freq_pix = 0;
    int lowpass_freq_pix = 0;
    
    BiquadType_t type = [[_filters getActiveBiquad] type];
    if (type == BIQUAD_HIGHPASS) highpass_freq_pix = [self getHighPassBorderPix];
    if (type == BIQUAD_LOWPASS) lowpass_freq_pix = [self getLowPassBorderPix];
    
    //get points
    NSMutableData * points = [[NSMutableData alloc] init];
    NSMutableData * activePoints = [[NSMutableData alloc] init];
    
    for (int i = border_left; i <= width - border_right; i++) {
        double ampl = [self.filters getAFR:[self pixelToFreq:i] ];
        double db = [self amplToDb:ampl];
        if ( (db < MIN_VIEW_DB) || (db > MAX_VIEW_DB) ) continue;
        
        
        CGPoint p = CGPointMake(i, [ self dbToPixel:db ]);
        if ((type == BIQUAD_HIGHPASS) && (i <= highpass_freq_pix)) {
            [activePoints appendBytes:&p length:sizeof(CGPoint)];
            if (i == highpass_freq_pix) [points appendBytes:&p length:sizeof(CGPoint)];
            
        } else if ((type == BIQUAD_LOWPASS) && (i >= lowpass_freq_pix)) {
            [activePoints appendBytes:&p length:sizeof(CGPoint)];
            if (i == lowpass_freq_pix) [points appendBytes:&p length:sizeof(CGPoint)];
            
        } else {
            [points appendBytes:&p length:sizeof(CGPoint)];
        }
        
    }
    
    CGContextSetLineWidth(context, 2.0);
    
    //draw active stroke
    unsigned long size = activePoints.length / sizeof(CGPoint);
    if (size > 1) {
        CGPoint * p = (CGPoint *)activePoints.bytes;
        CGContextSetStrokeColorWithColor(context, [[UIColor orangeColor] CGColor]);
        CGContextAddLines(context, p, size);
        CGContextDrawPath(context, kCGPathStroke);
    }
    
    //draw normal stroke
    size = points.length / sizeof(CGPoint);
    if (size > 1) {
        CGPoint * p = (CGPoint *)points.bytes;
        CGContextSetStrokeColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
        CGContextAddLines(context, p, size);
        CGContextDrawPath(context, kCGPathStroke);
    }
    
    [self drawFreqLineForParamFilters:(CGContextRef)context];
    [self drawFreqLineForAllpassFilters:(CGContextRef)context];
    [self drawPassFilterTap:context];
}


- (void) drawFreqLineForParamFilters:(CGContextRef)context {
    if (!_filters) return;
    
    NSArray<Biquad *> * params = [_filters getBiquadsWithType:BIQUAD_PARAMETRIC];
    [self drawFreqLineForBiquads:params
                       withColor:[UIColor brownColor] withSelectColor:[UIColor orangeColor]
                     withContext:context];
}

- (void) drawFreqLineForAllpassFilters:(CGContextRef)context {
    if (!_filters) return;
    
    NSArray<Biquad *> * allpass = [_filters getBiquadsWithType:BIQUAD_ALLPASS];
    UIColor * c = [UIColor colorWithRed:0.2 green:0.5 blue:1.0 alpha:0.5];
    UIColor * sc = [UIColor colorWithRed:0.2 green:0.5 blue:1.0 alpha:1.0];
    [self drawFreqLineForBiquads:allpass
                       withColor:c withSelectColor:sc
                     withContext:context];
}

- (void) drawFreqLineForBiquads:(NSArray<Biquad *> *)biquads
                      withColor:(UIColor *)color
                withSelectColor:(UIColor *)selColor
                    withContext:(CGContextRef)context{
    if (!biquads) return;
    
    for (int i = 0; i < biquads.count; i++) {
        Biquad * b = [biquads objectAtIndex:i];
        
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
    if (!_filters) return;
    
    CGPoint point;
    
    if (![_filters getLowpass]) {
        if (_filters.activeNullLP) {
            CGContextSetFillColorWithColor(context, [[UIColor orangeColor] CGColor]);
        } else {
            CGContextSetFillColorWithColor(context, [[UIColor brownColor] CGColor]);
        }
        
        point.x = width - border_right;
        point.y = [self.filters getAFR:[self pixelToFreq:width - border_right] ];
        
        if ([self amplToDb:point.y] > MIN_VIEW_DB) {
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
        
        if ([self amplToDb:point.y] > MIN_VIEW_DB) {
            CGContextFillEllipseInRect(context, CGRectMake(point.x - 5, [ self dbToPixel:(20.0f * log10(point.y)) ]  - 5, 10, 10));
            CGContextDrawPath(context, kCGPathStroke);
        }
        
    }
}

- (UIImage *) clipImage:(UIImage *)img inRect:(CGRect)clipRect {
    CGImageRef imgCGRef = [img CGImage];
    size_t w = CGImageGetWidth(imgCGRef) ;
    size_t h = CGImageGetHeight(imgCGRef);
    
    if (w > clipRect.size.width * img.scale)    w = clipRect.size.width * img.scale;
    if (h > clipRect.size.height * img.scale)   h = clipRect.size.height * img.scale;
    
    CGImageRef r = CGImageCreateWithImageInRect(imgCGRef, CGRectMake(0, 0, w, h));
    UIImage * i = [UIImage imageWithCGImage:r scale:img.scale orientation:img.imageOrientation];
    
    CGImageRelease(r);
    return i;
}

- (void) drawBack:(CGRect)dstRect {
    UIImage * img = [[BackFR sharedInstance] image];
    if (!img) return;
    
    CGPoint trans = [[BackFR sharedInstance] translate];
    CGPoint scale = [[BackFR sharedInstance] scale];
    CGSize scaleSize = CGSizeMake(dstRect.size.width * scale.x, dstRect.size.height * scale.y);
    
    CGPoint baseCenter = CGPointMake([self freqToPixel:1000] - [self freqToPixel:20], [self dbToPixel:0] - [self dbToPixel:15]);
    CGPoint center = CGPointMake(baseCenter.x - trans.x, baseCenter.y - trans.y);
    CGPoint scaleCenter = CGPointMake(center.x * scale.x, center.y * scale.y);
    CGPoint deltaCenter = CGPointMake(center.x - scaleCenter.x, center.y - scaleCenter.y);
    
    CGSize s = CGSizeMake(scaleSize.width + deltaCenter.x + trans.x, scaleSize.height + deltaCenter.y + trans.y);
    
    UIGraphicsBeginImageContextWithOptions(s, NO, 0.0);
    [img drawInRect:CGRectMake(trans.x + deltaCenter.x, trans.y + deltaCenter.y, scaleSize.width, scaleSize.height)];
    img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //clip and draw
    img = [self clipImage:img inRect:dstRect];
    [img drawAtPoint:dstRect.origin];
    
}

- (void) drawRelativeCenter:(CGContextRef)context {
    if (!_visibleRelativeCenter) return;
    
    //prepare color settings
    CGContextSetStrokeColorWithColor(context, [[UIColor orangeColor] CGColor]);
    CGContextSetLineWidth(context, 4.0);
    
    CGPoint center = CGPointMake([self freqToPixel:1000], [self dbToPixel:0]);
    CGFloat radius = 10.0f;
    
    CGContextMoveToPoint(context, center.x - radius, center.y);
    CGContextAddLineToPoint(context, center.x + radius, center.y);
    CGContextMoveToPoint(context, center.x, center.y - radius);
    CGContextAddLineToPoint(context, center.x, center.y + radius);
    
    CGContextDrawPath(context, kCGPathStroke);
}

/*-----------------------------------------------------------------------------------------
 Main Draw
 -----------------------------------------------------------------------------------------*/
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self view_refresh];
    
    CGRect dstRect = CGRectMake([self freqToPixel:20], [self dbToPixel:15],
                                [self freqToPixel:30000] - [self freqToPixel:20], [self dbToPixel:-30] - [self dbToPixel:15]);
    [self drawBack:dstRect];
    
    [self drawGrid:context];
    [self drawGridUnits:context];
    
    [self drawFilters:context];
    
    [self drawRelativeCenter:context];
    
}

@end
