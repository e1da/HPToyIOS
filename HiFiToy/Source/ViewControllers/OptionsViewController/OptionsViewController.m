//
//  OptionsViewController.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 08/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "OptionsViewController.h"
#import "HiFiToyDeviceList.h"
#import "DeviceNameViewController.h"
#import "PairingCodeViewController.h"
#import "PresetViewController.h"
#import "DialogSystem.h"

@implementation OptionsViewController

/*-----------------------------------------------------------------------------------------
 ViewController Orientation Methods
 -----------------------------------------------------------------------------------------*/
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
                                             selector: @selector(setupOutlets)
                                                 name: @"SetupOutletsNotification"
                                               object: nil];
    
    [self.hiFiToyDevice.outputMode isSettingsAvailable];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [self setupOutlets];
}

- (void) setupOutlets {
    if (!self.hiFiToyDevice) return;
    
    if (self.hiFiToyDevice.isPDV21Hw) {
        [self.nameLabel_outl setTextColor:UIColor.orangeColor];
    } else {
        if (@available(iOS 13.0, *)) {
            [self.nameLabel_outl setTextColor:UIColor.labelColor];
        } else {
            [self.nameLabel_outl setTextColor:UIColor.blackColor];
        }
    }
    
    _nameLabel_outl.text = self.hiFiToyDevice.name;
    
    if (self.hiFiToyDevice.outputMode.hwSupported) {
        _outputModeCell_outl.hidden = NO;
        _amModeCell_outl.hidden = NO;
    } else {
        _outputModeCell_outl.hidden = YES;
        _amModeCell_outl.hidden = YES;
    }
    
}

/*-----------------------------------------------------------------------------------------
 Table Row select method
 -----------------------------------------------------------------------------------------*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0){
        if (indexPath.row == 0){//change device name
            
            [[DialogSystem sharedInstance] showTextDialog:@"Device name"
                                                      msg:NSLocalizedString(@"Please input new device name:", @"")
                                                    okBtn:@"Ok"
                                                cancelBtn:@"Cancel"
                                        textConfigHandler:^(UITextField * _Nullable textField) {
                textField.text = self.hiFiToyDevice.name;
            
            } okBtnHandler:^(UIAlertAction * _Nullable action) {
                
                UITextField * name = [[[DialogSystem sharedInstance] alertController] textFields][0];
                if (![name.text isEqualToString:@""]) {
                    self.hiFiToyDevice.name = name.text;
                    [[HiFiToyDeviceList sharedInstance] saveDeviceListToFile];
                    
                    [self setupOutlets];
                }
                
            } cancelBtnHandler:nil];
            
        }
        
        if (indexPath.row == 1){//restore factory settings
            
            [[DialogSystem sharedInstance] showDialog:@""
                                                  msg:NSLocalizedString(@"Are you sure you want to reset to factory defaults?", @"")
                                                okBtn:@"Yes"
                                            cancelBtn:@"Cancel"
                                         okBtnHandler:^(UIAlertAction * _Nonnull action) {
                
                [self.hiFiToyDevice restoreFactory:nil];
            } cancelBtnHandler:nil];
            
        }
        if (indexPath.row == 2){//change pairing code
            
            [[DialogSystem sharedInstance] showNewPairCodeInput];
        }
        
    }
    
    
}

/*-----------------------------------------------------------------------------------------
 Prepare for segue
 -----------------------------------------------------------------------------------------*/
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showNameEdit"]) {
        DeviceNameViewController *destination = (DeviceNameViewController*)segue.destinationViewController;
        destination.hiFiToyDevice = self.hiFiToyDevice;
        
    }
    
    if ([[segue identifier] isEqualToString:@"showPairingCodeEdit"]) {
        PairingCodeViewController *destination = (PairingCodeViewController * )segue.destinationViewController;
        destination.hiFiToyDevice = self.hiFiToyDevice;
        
    }
    
    if ([[segue identifier] isEqualToString:@"showPresetManager"]) {
        PresetViewController *destination = (PresetViewController * )segue.destinationViewController;
        destination.hiFiToyDevice = self.hiFiToyDevice;
        
    }
    
    
}

@end
