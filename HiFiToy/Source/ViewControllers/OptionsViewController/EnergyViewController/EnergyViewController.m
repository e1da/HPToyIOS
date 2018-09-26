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
#define MAX_TIMEOUT_MS      60000 // 60seconds

@interface EnergyViewController () {
    EnergyConfig_t energyConfig;
}

@end

@implementation EnergyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([[HiFiToyControl sharedInstance] isConnected]) {
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(didGetEnergyConfig:)
                                                     name: @"GetDataNotification"
                                                   object: nil];
        
        [[HiFiToyControl sharedInstance] getEnergyConfig];
    } else {
        [self setupOutlets];
    }
}

- (void) didGetEnergyConfig:(NSNotification*)notification {
    //remove observer
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    //get data and fill energyConfig struct
    NSData * data = (NSData *)[notification object];
    
    if (data.length == 20) {
        memcpy(&energyConfig, data.bytes, sizeof(EnergyConfig_t));
        [self setupOutlets];
        
    } else {
        [[DialogSystem sharedInstance] showAlert:@"Import energy config is not success."];
    }
    
}

- (void) checkEnergyBorders:(EnergyConfig_t) energy {
    if (energy.highThresholdDb > MAX_THRESHOLD_DB) energy.highThresholdDb = MAX_THRESHOLD_DB;
    if (energy.highThresholdDb < MIN_THRESHOLD_DB) energy.highThresholdDb = MIN_THRESHOLD_DB;
    if (energy.lowThresholdDb > MAX_THRESHOLD_DB) energy.lowThresholdDb = MAX_THRESHOLD_DB;
    if (energy.lowThresholdDb < MIN_THRESHOLD_DB) energy.lowThresholdDb = MIN_THRESHOLD_DB;
    if (energy.auxTimeout120ms > MAX_TIMEOUT_MS / 120) energy.auxTimeout120ms = MAX_TIMEOUT_MS / 120;
    if (energy.usbTimeout120ms > MAX_TIMEOUT_MS / 120) energy.usbTimeout120ms = MAX_TIMEOUT_MS / 120;
}

- (void) setupOutlets{
    [self checkEnergyBorders:energyConfig];
    
    self.autoOffLabel_outl.text = [NSString stringWithFormat:@"%ddB", (int)energyConfig.lowThresholdDb];
    self.autoOffSlider_outl.value = (energyConfig.lowThresholdDb - MIN_THRESHOLD_DB) / (MAX_THRESHOLD_DB - MIN_THRESHOLD_DB);
    self.clipLabel_outl.text = [NSString stringWithFormat:@"%ddB", (int)energyConfig.highThresholdDb];
    self.clipSlider_outl.value = (energyConfig.highThresholdDb - MIN_THRESHOLD_DB) / (MAX_THRESHOLD_DB - MIN_THRESHOLD_DB);
}

- (IBAction)setClipThreshold_outl:(id)sender {
    energyConfig.highThresholdDb = (MAX_THRESHOLD_DB - MIN_THRESHOLD_DB) * self.clipSlider_outl.value + MIN_THRESHOLD_DB;
    self.clipLabel_outl.text = [NSString stringWithFormat:@"%ddB", (int)energyConfig.highThresholdDb];
}

- (IBAction)setAutoOffThreshold:(id)sender {
    energyConfig.lowThresholdDb = (MAX_THRESHOLD_DB - MIN_THRESHOLD_DB) * self.autoOffSlider_outl.value + MIN_THRESHOLD_DB;
    self.autoOffLabel_outl.text = [NSString stringWithFormat:@"%ddB", (int)energyConfig.lowThresholdDb];
}

- (IBAction)syncEnergyConfig:(id)sender {
    [[DialogSystem sharedInstance] showEnergySyncDialog:energyConfig];
    
}

@end
