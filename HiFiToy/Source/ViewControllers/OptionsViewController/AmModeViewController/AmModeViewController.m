//
//  AmModeViewController.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 04/06/2021.
//  Copyright © 2021 Kerosinn_OSX. All rights reserved.
//

#import "AmModeViewController.h"
#import "HiFiToyControl.h"
#import "DialogSystem.h"

@interface AmModeViewController ()

@end

@implementation AmModeViewController

- (void) viewDidLoad {
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    AmMode * amMode = [[[HiFiToyControl sharedInstance] activeHiFiToyDevice] amMode];
    [amMode importFromPeripheral:^() {
        [self setupOutlets];
    }];
}

- (void) setupOutlets {
    AmMode * amMode = [[[HiFiToyControl sharedInstance] activeHiFiToyDevice] amMode];
    
    self.amModeEnabledSwitch.on = [amMode isEnabled];
}

- (IBAction)setAmMode:(id)sender {
    DialogSystem * dialog = [DialogSystem sharedInstance];
    
    [dialog showDialog:@""
                   msg:@"Do you want to send a new value?"
                 okBtn:@"Yes"
             cancelBtn:@"Cancel"
          okBtnHandler:^(UIAlertAction * _Nonnull action) {
            AmMode * amMode = [[[HiFiToyControl sharedInstance] activeHiFiToyDevice] amMode];
        
            [amMode setEnabled:self.amModeEnabledSwitch.on];
            [amMode storeToPeripheral];
        
        } cancelBtnHandler:^(UIAlertAction * _Nonnull action) {
            [self setupOutlets];
        }];
      
}

@end
