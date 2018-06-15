//
//  DrcViewController.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 15/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "DrcViewController.h"
#import "HiFiToyDeviceList.h"
#import "HiFiToyPreset.h"


@implementation DrcViewController

- (void)viewWillAppear:(BOOL)animated
{
    HiFiToyPreset * preset = [[[HiFiToyDeviceList sharedInstance] getActiveDevice] getActivePreset];
    drc = preset.drc;
    
    self.drcView.maxDbX = drc.coef17.point3.inputDb;
    self.drcView.minDbX = drc.coef17.point0.inputDb;
    self.drcView.maxDbY = 24;
    self.drcView.minDbY = -120;
    self.drcView.initHeight = 0;
    self.drcView.activePoint = 2;
    
    _enabledSlider_outl.value = [drc getEnabledChannel:0];
    _enabledLabel_outl.text = [NSString stringWithFormat:@"%d%%", (int)(_enabledSlider_outl.value * 100)];
    
    [self refreshView];
  
}

- (void) setTitleInfo
{
    NSString *title;
    
    switch (self.drcView.activePoint) {
        case 0:
            title = [NSString stringWithFormat:@"in:%0.1f out:%0.1f",
                     drc.coef17.point0.inputDb, drc.coef17.point0.outputDb];
            break;
        case 1:
            title = [NSString stringWithFormat:@"in:%0.1f out:%0.1f",
                     drc.coef17.point1.inputDb, drc.coef17.point1.outputDb];
            break;
        case 2:
            title = [NSString stringWithFormat:@"in:%0.1f out:%0.1f",
                     drc.coef17.point2.inputDb, drc.coef17.point2.outputDb];
            break;
        case 3:
            title = [NSString stringWithFormat:@"in:%0.1f out:%0.1f",
                     drc.coef17.point3.inputDb, drc.coef17.point3.outputDb];
            break;
    }
    
    [self setTitle:title];
}

- (IBAction)setEnabledSlider:(id)sender
{
    [drc setEnabled:_enabledSlider_outl.value forChannel:0];
    [drc setEnabled:_enabledSlider_outl.value forChannel:1];
    _enabledLabel_outl.text = [NSString stringWithFormat:@"%d%%", (int)(_enabledSlider_outl.value * 100)];
    
    [drc sendEnabledForChannel:0 withResponse:NO];
    [drc sendEnabledForChannel:1 withResponse:NO];
}

-(void) refreshView
{
    [self setTitleInfo];
    [self.drcView setNeedsDisplay];
    
}

- (IBAction)doubleTapHandle:(UITapGestureRecognizer *)recognizer
{
    [self selectActiveFilter:recognizer];
}

- (IBAction)longPressHandle:(UILongPressGestureRecognizer *)recognizer
{
    [self selectActiveFilter:recognizer];
}


//change Freq Order dbVolume
- (IBAction)panHandle:(UIPanGestureRecognizer *)recognizer
{
    static CGPoint prevTranslation;
    CGPoint translation = [recognizer translationInView:recognizer.view];
    
    if (recognizer.state == UIGestureRecognizerStateBegan){
        prevTranslation = CGPointMake(0.0f, 0.0f);
    }
    
    CGPoint delta = CGPointMake(translation.x -  prevTranslation.x,
                                translation.y -  prevTranslation.y);
    

    switch (self.drcView.activePoint) {
        case 0:
            drc.coef17.point0 = [self updateDrcPoint:drc.coef17.point0 Delta:delta];
            break;
        case 1:
            drc.coef17.point1 = [self updateDrcPoint:drc.coef17.point1 Delta:delta];
            break;
        case 2:
            drc.coef17.point2 = [self updateDrcPoint:drc.coef17.point2 Delta:delta];
            break;
        case 3:
            drc.coef17.point3 = [self updateDrcPoint:drc.coef17.point3 Delta:delta];
            break;
        default:
            return;
    }
    
    prevTranslation = translation;
    
    [drc.coef17 sendWithResponse:NO];
    
    [self refreshView];
}

- (void ) selectActiveFilter:(UIGestureRecognizer *)recognizer
{
    NSLog(@"Select Active");
    
    CGPoint tapPoint = [recognizer locationInView:recognizer.view];
    BOOL result[4];
    
    result[0] = [self checkCrossPoint:drc.coef17.point0 tapPoint:tapPoint];
    result[1] = [self checkCrossPoint:drc.coef17.point1 tapPoint:tapPoint];
    result[2] = [self checkCrossPoint:drc.coef17.point2 tapPoint:tapPoint];
    result[3] = [self checkCrossPoint:drc.coef17.point3 tapPoint:tapPoint];
    
    int counter = self.drcView.activePoint + 1;
    for (int i = 0; i < 3; i++) {
        if (counter > 3) counter = 0;
        if (result[counter]) {
            self.drcView.activePoint = counter;
            
            [self refreshView];
            break;
        }
        counter++;
    }
}

- (BOOL) checkCrossPoint:(DrcPoint_t)drcPoint
                        tapPoint: (CGPoint)tapPoint
{
    
    if ((fabs(tapPoint.x - [self.drcView dbToPixelX:drcPoint.inputDb]) < 30) &&
        (fabs(tapPoint.y - [self.drcView dbToPixelY:drcPoint.outputDb]) < 30)) {
        return YES;
    }

    return NO;
}

- (DrcPoint_t) updateDrcPoint:(DrcPoint_t)drcPoint Delta:(CGPoint)delta
{
    double pixX = [self.drcView dbToPixelX:drcPoint.inputDb] + delta.x;
    double pixY = [self.drcView dbToPixelY:drcPoint.outputDb] + delta.y;
    
    return initDrcPoint([self.drcView pixelXToDb:pixX], [self.drcView pixelYToDb:pixY]);
}

@end
