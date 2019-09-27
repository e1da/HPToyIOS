//
//  AdjustViewController.m
//  BackgroundFR
//
//  Created by Kerosinn_OSX on 23/09/2019.
//  Copyright © 2019 Kerosinn_OSX. All rights reserved.
//

#import "AdjustBackFRViewController.h"
#import "XOverView.h"
#import "BackFR.h"

@interface AdjustBackFRViewController () {
    UIBarButtonItem * mirrorItem;
    UIBarButtonItem * typeScaleItem;
    UIBarButtonItem * doneItem;
    
    UIPinchGestureRecognizer *      scaleGesture;
    UIPanGestureRecognizer *        translateGesture;
    
    XOverView * filtersView;
}

@end

@implementation AdjustBackFRViewController

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeLeft;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:[UIColor darkGrayColor]];
    self.title = @"Relative center: 0dB, 1kHz";
    
    //init bar buttons
    mirrorItem = [[UIBarButtonItem alloc] init];
    mirrorItem.target = self;
    mirrorItem.action = @selector(mirror);
    mirrorItem.title = @"Mirror";
    
    typeScaleItem = [[UIBarButtonItem alloc] init];
    typeScaleItem.target = self;
    typeScaleItem.action = @selector(invertTypeScale);
    typeScaleItem.title = [[BackFR sharedInstance] scaleTypeX] ? @"X-Scale" : @"Y-Scale";
    
    doneItem = [[UIBarButtonItem alloc] init];
    doneItem.target = self;
    doneItem.action = @selector(done);
    doneItem.title = @"Done";
    
    //add buttons to bar
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:doneItem, typeScaleItem, mirrorItem, nil];
    
    //init filters view
    filtersView = [[XOverView alloc] init];
    filtersView.maxFreq = 30000;
    filtersView.minFreq = 20;
    filtersView.visibleRelativeCenter = YES;
    
    filtersView.drawFreqUnitArray =  [NSArray arrayWithObjects:[NSNumber numberWithInt:20],
                                     [NSNumber numberWithInt:100], [NSNumber numberWithInt:1000],
                                     [NSNumber numberWithInt:10000], nil];
    [self.view addSubview:filtersView];
    
    //init gestures
    scaleGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scaleHandler:)];
    translateGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(translateHandler:)];
    
    [self.view addGestureRecognizer:scaleGesture];
    [self.view addGestureRecognizer:translateGesture];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    typeScaleItem.title = [[BackFR sharedInstance] scaleTypeX] ? @"X-Scale" : @"Y-Scale";
    [filtersView setNeedsDisplay];
}

- (void) viewWillLayoutSubviews {
    int top = self.navigationController.navigationBar.frame.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    int width = self.view.frame.size.width;
    int height = self.view.frame.size.height - top;
    
    
    [filtersView setFrame:CGRectMake(0, top, width, height)];
    [filtersView setNeedsDisplay];

}

- (void) mirror {
    [[BackFR sharedInstance] flipVertical];
    
    //display refresh
    [self->filtersView setNeedsDisplay];
}

- (void) invertTypeScale {
    [[BackFR sharedInstance] invertScaleType];
    
    typeScaleItem.title = [[BackFR sharedInstance] scaleTypeX] ? @"X-Scale" : @"Y-Scale";
}

- (void) done {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) scaleHandler:(UIPinchGestureRecognizer *)recognizer {
    static double lastScaleFactor;
    
    if (recognizer.state == UIGestureRecognizerStateBegan){
        lastScaleFactor = 1.0f;
    }
    
    [[BackFR sharedInstance] setScale:recognizer.scale / lastScaleFactor];
    lastScaleFactor = recognizer.scale;
    
    //display refresh
    [self->filtersView setNeedsDisplay];
}

- (void) translateHandler:(UIPanGestureRecognizer *)recognizer {
    static CGPoint prevTranslate;
    CGPoint translate = [recognizer translationInView:recognizer.view];
    
    if (recognizer.state == UIGestureRecognizerStateBegan){
        prevTranslate = CGPointMake(0.0f, 0.0f);
    }
    
    CGPoint deltaTranslate = CGPointMake(translate.x - prevTranslate.x, translate.y - prevTranslate.y);
    prevTranslate = translate;
    
    [[BackFR sharedInstance] setTranslate:deltaTranslate];
    
    //display refresh
    [self->filtersView setNeedsDisplay];
   
}

@end
