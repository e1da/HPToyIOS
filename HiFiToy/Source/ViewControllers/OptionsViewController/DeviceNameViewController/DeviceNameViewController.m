//
//  DeviceNameViewController.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 08/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "DeviceNameViewController.h"

@implementation DeviceNameViewController

/*-----------------------------------------------------------------------------------------
 ViewController Orientation Methods
 -----------------------------------------------------------------------------------------*/
- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}


- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _name_outl.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    _name_outl.text = self.hiFiToyDevice.name;
    [_name_outl becomeFirstResponder];
}


- (IBAction)editName:(id)sender {
    self.hiFiToyDevice.name = _name_outl.text;
    
    [[HiFiToyDeviceList sharedInstance] saveDeviceListToFile];
    
    NSLog(@"%@",_name_outl.text);
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    //[textField resignFirstResponder];
    [self.navigationController popViewControllerAnimated:TRUE];
    return NO;
}
@end
