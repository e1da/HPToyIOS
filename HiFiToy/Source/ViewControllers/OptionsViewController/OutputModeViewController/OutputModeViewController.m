//
//  OutputModeViewController.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 07/05/2021.
//  Copyright © 2021 Kerosinn_OSX. All rights reserved.
//

#import "OutputModeViewController.h"
#import "HiFiToyControl.h"

@interface OutputModeViewController ()

@end

@implementation OutputModeViewController

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
    
    
    [[UILabel appearanceWhenContainedInInstancesOfClasses:@[[UISegmentedControl class]]] setNumberOfLines:2];
    [_outputSegmentedOutlet setTitle:@"Balance" forSegmentAtIndex:0];
    [_outputSegmentedOutlet setTitle:@"Unbalance" forSegmentAtIndex:1];
    [_outputSegmentedOutlet setTitle:@"Unbalance\nboost" forSegmentAtIndex:2];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleNotification:)
                                                 name: @"SetupOutletsNotification"
                                               object: nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    HiFiToyDevice * dev = [[HiFiToyControl sharedInstance] activeHiFiToyDevice];
    [dev.outputMode readFromDsp];
    
    [self setupOutlets];
}

- (void) handleNotification:(NSNotification*)notification {
    [self setupOutlets];
}

- (void) setupOutlets {
    HiFiToyDevice * dev = [[HiFiToyControl sharedInstance] activeHiFiToyDevice];
    
    _outputSegmentedOutlet.selectedSegmentIndex = dev.outputMode.value;
}

- (IBAction)setOutputMode:(id)sender {
    HiFiToyDevice * dev = [[HiFiToyControl sharedInstance] activeHiFiToyDevice];
    
    if (_outputSegmentedOutlet.selectedSegmentIndex == BALANCE_OUT_MODE) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                               message:@"Please be careful. Using unbalance headphone with PDV2.1 in balance mode is dangerous. Are you sure want to set balance output mode?"
                                                        preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                               style:UIAlertActionStyleDestructive
                                                             handler:^(UIAlertAction * _Nonnull action) {
            [self setupOutlets];
        }];
        
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Set"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
            dev.outputMode.value = self.outputSegmentedOutlet.selectedSegmentIndex;
            [dev.outputMode sendToDsp];
            
        }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
    
        dev.outputMode.value = _outputSegmentedOutlet.selectedSegmentIndex;
        [dev.outputMode sendToDsp];
    }
}

@end
