//
//  DrcView.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 15/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "DrcView.h"
#import "HiFiToyControl.h"
#import "HiFiToyPreset.h"
#import "Drc.h"

@implementation DrcView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.maxDbX = POINT3_INPUT_DB;
        self.minDbX = POINT0_INPUT_DB;
        self.maxDbY = POINT3_INPUT_DB;
        self.minDbX = POINT0_INPUT_DB - 24;
        self.initHeight = 0;
        
        self.backgroundColor = [UIColor darkGrayColor];
        
    }
    return self;
}

- (void) setActivePoint:(int)activePoint
{
    if (activePoint > 3) activePoint = 3;
    _activePoint = activePoint;
}

- (int) getWidth
{
    return width;
}


- (int) getHeight
{
    return height;
}

/*-----------------------------------------------------------------------------------------
 Math Calculation
 -----------------------------------------------------------------------------------------*/
- (double) dbToPixelX:(double)db
{
    return a_coef * db + b_coef;
}

- (double) pixelXToDb:(double)pixel
{
    if (pixel > width - border_right) pixel = width - border_right;
    if (pixel < border_left) pixel = border_left;
    
    return (pixel - b_coef) / a_coef;
}

- (double) dbToPixelY:(double)db
{
    return c_coef * db + d_coef;
}

- (double) pixelYToDb:(double)pixel
{
    if (pixel > height - border_bottom) pixel = height - border_bottom;
    if (pixel < border_top) pixel = border_top;
    
    return (pixel - d_coef) / c_coef;
}


/*-----------------------------------------------------------------------------------------
 Draw Calculation
 -----------------------------------------------------------------------------------------*/
- (void) refreshView
{
    border_left = 30;
    border_right = 20;
    border_top = _initHeight + 10;
    border_bottom = 30;
    
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
    
    /*    a_coef*log10(MAX_FREQ)+b_coef = width - border_right
     a_coef*log10(MIN_FREQ)+b_coef = border_left
     =>
     a_coef*log10(MAX_FREQ) + border_left - a_coef*log10(MIN_FREQ) = width - border_right
     a_coef*(log10(MAX_FREQ)-log10(MIN_FREQ)) = width - (border_left + border_right)
     
     */
    a_coef = (double)(width - (border_left + border_right)) / (self.maxDbX - self.minDbX);
    b_coef = border_left - a_coef * self.minDbX;
    
    /*    15*c_coef + d_coef = border_top
     *  -30*c_coef + d_coef = height - border_bottom
     *  =>
     *  15*c_coef + height - border_bottom + 30*c_coef = border_top
     *  c_coef = (border_top + border_bottom - height) / (15 + 30)
     */
    c_coef = (double)(border_top + border_bottom - height) / (self.maxDbY - self.minDbY);
    d_coef = height - border_bottom - c_coef * self.minDbY;
    
    
}


/*-----------------------------------------------------------------------------------------
 Draw Methods
 -----------------------------------------------------------------------------------------*/
- (void) drawGrid:(CGContextRef)context
{
    //prepare color settings
    CGContextSetStrokeColorWithColor(context, [[UIColor grayColor] CGColor]);
    CGContextSetLineWidth(context, 1.0);
    
    //draw horizontal line
    for (int i = self.maxDbY; i >= self.minDbY; i -= GRID_STEP){
        CGContextMoveToPoint(context, (float)(border_left), [self dbToPixelY:i]);
        CGContextAddLineToPoint(context, (float)(width - border_right), [self dbToPixelY:i]);
        
    }
    for (int i = self.maxDbX; i >= self.minDbX; i -= GRID_STEP){
        CGContextMoveToPoint(context, [self dbToPixelX:i], (float)(border_top));
        CGContextAddLineToPoint(context, [self dbToPixelX:i], (float)(height - border_bottom));
        
    }
    
    CGContextDrawPath(context, kCGPathStroke);
    
    //draw 1.0 compressor line
    /*CGContextSetStrokeColorWithColor(context, [[UIColor grayColor] CGColor]);
    CGContextSetAlpha(context, 1.0f);
    CGContextSetLineWidth(context, 2.0);
    
    CGFloat dashes[] = {10,10};
    CGContextSetLineDash(context, 0.0, dashes, 2);
    
    CGContextMoveToPoint(context, [self dbToPixelX:self.maxDbX], [self dbToPixelY:self.maxDbY]);
    CGContextAddLineToPoint(context, [self dbToPixelX:self.minDbX], [self dbToPixelY:self.minDbX]);
    
    CGContextDrawPath(context, kCGPathStroke);
    
    CGContextSetLineDash(context, 0.0, dashes, 0);*/
}

- (void) drawGridUnits:(CGContextRef)context
{
    //prepare font and style for horizontal symbols
    UIFont *font = [UIFont fontWithName:@"ArialRoundedMTBold" size:12.0];
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentCenter;
    
    NSMutableDictionary * attr = [[NSMutableDictionary alloc] init];
    [attr setObject:style forKey:NSParagraphStyleAttributeName];
    [attr setObject:font forKey:NSFontAttributeName];
    [attr setObject:[UIColor lightGrayColor] forKey:NSForegroundColorAttributeName];
    
    for (int i = self.maxDbX; i > self.minDbX; i -= DB_STEP_X){
        
        NSString *dbString = [NSString stringWithFormat:@"%d", i + 24];
        CGRect rect = CGRectMake([self dbToPixelX:i] - 25, height - border_bottom + 10, // x y
                                 45, 30); //width height
        
        [dbString drawInRect:rect withAttributes:attr];
    }
    
    //prepare font and style for vertical symbols
    font = [UIFont fontWithName:@"ArialRoundedMTBold" size:10.0];
    style.alignment = NSTextAlignmentRight;
    [attr setObject:font forKey:NSFontAttributeName];
    [attr setObject:style forKey:NSParagraphStyleAttributeName];

    for (int i = self.maxDbY; i > self.minDbY; i -= DB_STEP_Y){
        
        NSString *dbString = [NSString stringWithFormat:@"%d", i + 24];
        CGRect rect = CGRectMake(0, [self dbToPixelY:i] - 5, // x y
                                 [self dbToPixelX:self.minDbX] - 12, 30); //width height
        
        [dbString drawInRect:rect withAttributes:attr];
    }
    
    //corner
    /*NSString *dbString = [NSString stringWithFormat:@"%d", self.minDb];
    CGRect rect = CGRectMake(0, height - border_bottom + 20, // x y
                             [self dbToPixelX:self.minDb] - 22, 30); //width height
    
    [dbString drawInRect:rect withAttributes:attr];*/
    
}

- (void) drawDrcGraph:(CGContextRef)context withPoints:(NSMutableData *)points {
    if ((!points) || (points.length < 2 * sizeof(CGPoint)) ) return;
    
    unsigned long size = points.length / sizeof(CGPoint);
    CGPoint * p = (CGPoint *)points.bytes;
    
    CGPoint firstPoint = p[0];
    firstPoint.y = [self dbToPixelY:self.minDbY];
    CGPoint lastPoint = p[size - 1];
    lastPoint.y = [self dbToPixelY:self.minDbY];
    
    [points appendBytes:&lastPoint length:sizeof(CGPoint)];
    [points appendBytes:&firstPoint length:sizeof(CGPoint)];
    //update p pointer after append new points
    p = (CGPoint *)points.bytes;
    
    UIColor * c = [UIColor colorWithRed:0.0 green:1.0 blue:1.0 alpha:0.1];
    CGContextSetFillColorWithColor(context, [c CGColor]);
    
    CGContextAddLines(context, p, size + 2);
    CGContextDrawPath(context, kCGPathFill);
    
    //draw stroke
    CGContextSetLineWidth(context, 2.0);
    CGContextSetStrokeColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
    CGContextAddLines(context, p, size);
    CGContextDrawPath(context, kCGPathStroke);
    
    
    
}

- (void) drawDrc:(CGContextRef)context
{
    HiFiToyPreset * preset = [[[HiFiToyControl sharedInstance] activeHiFiToyDevice] getActivePreset];
    DrcCoef * drc = preset.drc.coef17;
    
    //draw drc graphic
    NSMutableData * points = [[NSMutableData alloc] init];
    CGPoint p[4] = { CGPointMake([self dbToPixelX:drc.point0.inputDb], [self dbToPixelY:drc.point0.outputDb]),
                        CGPointMake([self dbToPixelX:drc.point1.inputDb], [self dbToPixelY:drc.point1.outputDb]),
                        CGPointMake([self dbToPixelX:drc.point2.inputDb], [self dbToPixelY:drc.point2.outputDb]),
                        CGPointMake([self dbToPixelX:drc.point3.inputDb], [self dbToPixelY:drc.point3.outputDb]) };
    
    [points appendBytes:&p length:4 * sizeof(CGPoint)];
    [self drawDrcGraph:context withPoints:points];
    
    //draw points
    if (self.activePoint == 0) {
        //CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1.0);
        CGContextSetFillColorWithColor(context, [[UIColor orangeColor] CGColor]);
    } else {
        //CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
        CGContextSetFillColorWithColor(context, [[UIColor brownColor] CGColor]);
    }
    CGContextFillEllipseInRect(context, CGRectMake([self dbToPixelX:drc.point0.inputDb] - 5, [self dbToPixelY:drc.point0.outputDb] - 5, 10, 10));
    
    if (self.activePoint == 1) {
        //CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1.0);
        CGContextSetFillColorWithColor(context, [[UIColor orangeColor] CGColor]);
    } else {
        //CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
        CGContextSetFillColorWithColor(context, [[UIColor brownColor] CGColor]);
    }
    CGContextFillEllipseInRect(context, CGRectMake([self dbToPixelX:drc.point1.inputDb] - 5, [self dbToPixelY:drc.point1.outputDb] - 5, 10, 10));
    
    if (self.activePoint == 2) {
        //CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1.0);
        CGContextSetFillColorWithColor(context, [[UIColor orangeColor] CGColor]);
    } else {
        //CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
        CGContextSetFillColorWithColor(context, [[UIColor brownColor] CGColor]);
    }
    CGContextFillEllipseInRect(context, CGRectMake([self dbToPixelX:drc.point2.inputDb] - 5, [self dbToPixelY:drc.point2.outputDb] - 5, 10, 10));
    
    if (self.activePoint == 3) {
        //CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1.0);
        CGContextSetFillColorWithColor(context, [[UIColor orangeColor] CGColor]);
    } else {
        //CGContextSetRGBFillColor(context, 0.0, 0.0, 1.0, 1.0);
        CGContextSetFillColorWithColor(context, [[UIColor brownColor] CGColor]);
    }
    CGContextFillEllipseInRect(context, CGRectMake([self dbToPixelX:drc.point3.inputDb] - 5, [self dbToPixelY:drc.point3.outputDb] - 5, 10, 10));
    
    CGContextDrawPath(context, kCGPathStroke);
    
}

/*-----------------------------------------------------------------------------------------
 Main Draw
 -----------------------------------------------------------------------------------------*/
- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self refreshView];
    
    [self drawGrid:context];
    [self drawGridUnits:context];
    
    [self drawDrc:context];
    
}

@end
