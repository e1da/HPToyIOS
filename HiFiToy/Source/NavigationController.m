//
//  NavigationController.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 08/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "NavigationController.h"

@implementation NavigationController

-(BOOL)shouldAutorotate
{
    return [[self.viewControllers lastObject] shouldAutorotate];
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [[self.viewControllers lastObject] supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [[self.viewControllers lastObject] preferredInterfaceOrientationForPresentation];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.interactivePopGestureRecognizer.enabled = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didClipDetection:)
                                                 name:@"ClipDetectionNotification"
                                               object:nil];
    
    self.clipView = [[UIView alloc] init];
    [self.clipView setFrame:CGRectMake(0, self.navigationBar.frame.size.height - 3, self.navigationBar.frame.size.width, 3)];
    [self.clipView setBackgroundColor:[UIColor clearColor]];
    [self.navigationBar addSubview:self.clipView];
}


- (void) viewWillLayoutSubviews
{
    NSString * s = [NSString stringWithFormat:@"w=%f h=%f",  self.navigationBar.frame.size.width,  self.navigationBar.frame.size.height];
    NSLog(@"viewWillLayoutSubviews %@", s);
    
    [self.clipView setFrame:CGRectMake(0, self.navigationBar.frame.size.height - 3, self.navigationBar.frame.size.width, 3)];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

/*-----------------------------------------------------------------------------------------
 ClipDetectionNotification
 -----------------------------------------------------------------------------------------*/
- (void) didClipDetection:(NSNotification *)notification
{
    BOOL clip = [[notification object] boolValue];
    //NSLog(@"Clip=%d", clip);


    if (clip) {
        [self.clipView setBackgroundColor:[UIColor redColor]];
        //animate
        /*[UIView animateWithDuration:0.5 animations:^{
            [self.clipView setBackgroundColor:[UIColor redColor]];
        }];*/
        
    } else {
        [self.clipView setBackgroundColor:[UIColor clearColor]];
        //animate
        /*[UIView animateWithDuration:0.5 animations:^{
            [self.clipView setBackgroundColor:[UIColor clearColor]];
        }];*/
    }
    
    //self.navigationBar.translucent = clip ? NO : YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
