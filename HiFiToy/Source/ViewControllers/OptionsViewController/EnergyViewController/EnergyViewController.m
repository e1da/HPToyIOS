//
//  EnergyViewController.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 23/09/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "EnergyViewController.h"
#import "HiFiToyControl.h"
#import "DialogSystem.h"

#define MAX_THRESHOLD_DB    0.0f
#define MIN_THRESHOLD_DB    -120.0f

@interface EnergyViewController () {
    HiFiToyDevice * device;
}

@end

@implementation EnergyViewController

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
                                             selector: @selector(didUpdateEnergyConfig:)
                                                 name: @"UpdateEnergyConfigNotification"
                                               object: nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    device = [[HiFiToyControl sharedInstance] activeHiFiToyDevice];
    [self setupOutlets];
    [device updateEnergyConfig];
}

- (void) didUpdateEnergyConfig:(NSNotification*)notification {
    [self setupOutlets];
}

- (void) checkEnergyBorders:(EnergyConfig_t *) energy {
    
    if (energy->highThresholdDb > MAX_THRESHOLD_DB) energy->highThresholdDb = MAX_THRESHOLD_DB;
    if (energy->highThresholdDb < MIN_THRESHOLD_DB) energy->highThresholdDb = MIN_THRESHOLD_DB;
    if (energy->lowThresholdDb > MAX_THRESHOLD_DB) energy->lowThresholdDb = MAX_THRESHOLD_DB;
    if (energy->lowThresholdDb < MIN_THRESHOLD_DB) energy->lowThresholdDb = MIN_THRESHOLD_DB;
}

- (void) setupOutlets{
    EnergyConfig_t energy = device.energyConfig;
    [self checkEnergyBorders:&energy];
    device.energyConfig = energy;
    
    self.autoOffLabel_outl.text = [NSString stringWithFormat:@"%ddB", (int)energy.lowThresholdDb];
    self.autoOffSlider_outl.value = (energy.lowThresholdDb - MIN_THRESHOLD_DB) / (MAX_THRESHOLD_DB - MIN_THRESHOLD_DB);
    self.clipLabel_outl.text = [NSString stringWithFormat:@"%ddB", (int)energy.highThresholdDb];
    self.clipSlider_outl.value = (energy.highThresholdDb - MIN_THRESHOLD_DB) / (MAX_THRESHOLD_DB - MIN_THRESHOLD_DB);
}

- (IBAction)setClipThreshold_outl:(id)sender {
    EnergyConfig_t energy = device.energyConfig;
    energy.highThresholdDb = (MAX_THRESHOLD_DB - MIN_THRESHOLD_DB) * self.clipSlider_outl.value + MIN_THRESHOLD_DB;
    self.clipLabel_outl.text = [NSString stringWithFormat:@"%ddB", (int)energy.highThresholdDb];

    device.energyConfig = energy;
}

- (IBAction)setAutoOffThreshold:(id)sender {
    EnergyConfig_t energy = device.energyConfig;
    energy.lowThresholdDb = (MAX_THRESHOLD_DB - MIN_THRESHOLD_DB) * self.autoOffSlider_outl.value + MIN_THRESHOLD_DB;
    self.autoOffLabel_outl.text = [NSString stringWithFormat:@"%ddB", (int)energy.lowThresholdDb];
    
    device.energyConfig = energy;
}

- (IBAction)syncEnergyConfig:(id)sender {
    [[DialogSystem sharedInstance] showEnergySyncDialog];
    
}

@end
