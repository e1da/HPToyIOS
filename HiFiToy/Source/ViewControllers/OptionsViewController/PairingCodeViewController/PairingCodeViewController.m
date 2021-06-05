//
//  PairingCodeViewController.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 08/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "PairingCodeViewController.h"
#import "DialogSystem.h"

@implementation PairingCodeViewController

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


- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated
{
    _pairingCodeTextField_outl.text = [NSString stringWithFormat:@"%d", self.hiFiToyDevice.pairingCode];
    [_pairingCodeTextField_outl becomeFirstResponder];
}

/*-----------------------------------------------------------------------------------------
 Table Row select method
 -----------------------------------------------------------------------------------------*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0){
        if (indexPath.row == 1){//change pairing code
            
            [[DialogSystem sharedInstance] showDialog:NSLocalizedString(@"Warning", @"")
                                                  msg:NSLocalizedString(@"Are You sure want to change Pairing Code?", @"")
                                                okBtn:@"Yes"
                                            cancelBtn:@"Cancel"
                                         okBtnHandler:^(UIAlertAction * _Nonnull action) {
                
                if (!self.hiFiToyDevice) return;
                self.hiFiToyDevice.pairingCode = [self.pairingCodeTextField_outl.text intValue];

                [[HiFiToyDeviceList sharedInstance] saveDeviceListToFile];
                
                [[HiFiToyControl sharedInstance] sendNewPairingCode:self.hiFiToyDevice.pairingCode];
                
            } cancelBtnHandler:nil];
            
        }
    }
    
    
}

@end
