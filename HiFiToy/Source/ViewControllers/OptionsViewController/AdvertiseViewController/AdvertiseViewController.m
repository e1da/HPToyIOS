//
//  AdvertiseViewController.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 22/02/2019.
//  Copyright © 2019 Kerosinn_OSX. All rights reserved.
//

#import "AdvertiseViewController.h"
#import "HiFiToyControl.h"

@interface AdvertiseViewController () {
    HiFiToyDevice * device;
}

@end

@implementation AdvertiseViewController

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(didUpdateAdvertiseMode:)
                                                 name: @"UpdateAdvertiseModeNotification"
                                               object: nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    device = [[HiFiToyControl sharedInstance] activeHiFiToyDevice];
    [self setupOutlets];
    [device updateAdvertiseMode];
}

- (void) didUpdateAdvertiseMode:(NSNotification*)notification {
    [self setupOutlets];
}

- (void) setupOutlets{
    if (device) {
        self.advertiseModeSwitch_outl.on = (device.advertiseMode == ADVERTISE_ALWAYS_ENABLED) ? NO : YES;
    } else {
        self.advertiseModeSwitch_outl.on = NO;
    }
}


- (IBAction)setAdvertiseMode:(id)sender {
    if (device) {
        device.advertiseMode = (self.advertiseModeSwitch_outl.on) ?
                                ADVERTISE_AFTER_1MIN_DISABLED : ADVERTISE_ALWAYS_ENABLED;
        [device sendAdvertiseMode];
    }
}
@end
