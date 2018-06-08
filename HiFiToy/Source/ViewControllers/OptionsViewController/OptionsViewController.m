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

@implementation OptionsViewController

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


- (void)viewDidLoad {
    [super viewDidLoad];
    
    hiFiToyControl = [HiFiToyControl sharedInstance];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setupOutlets];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self setupOutlets];
}


- (void) setupOutlets
{
    if (!self.hiFiToyDevice) return;
    
    _nameLabel_outl.text = self.hiFiToyDevice.name;
    _UUIDLabel_outl.text = [[HiFiToyDeviceList sharedInstance] keyActiveDevice];
}

/*-----------------------------------------------------------------------------------------
 Table Row select method
 -----------------------------------------------------------------------------------------*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0){
        if (indexPath.row == 2){//restore factory settings
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"", @"")
                                                                                     message:NSLocalizedString(@"Are you sure you want to reset to factory defaults?", @"")
                                                                              preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:nil];
            
            UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Yes"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 
                                                                 HiFiToyControl * control = [HiFiToyControl sharedInstance];
                                                                 if ([control isConnected]) {
                                                                    //[control sendFactorySettings];
                                                                 }
                                                            }];
            
            [alertController addAction:cancelAction];
            [alertController addAction:okAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
        
    }
    
    
}

/*-----------------------------------------------------------------------------------------
 Prepare for segue
 -----------------------------------------------------------------------------------------*/
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
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
