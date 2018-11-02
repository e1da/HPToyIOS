//
//  DialogSystem.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 07/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "DialogSystem.h"
#import "HiFiToyDeviceList.h"
#import "HiFiToyControl.h"

@implementation DialogSystem

+ (DialogSystem *)sharedInstance
{
    static DialogSystem * sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DialogSystem alloc] init];
        
    });
    return sharedInstance;
}

- (BOOL) isAlertVisible
{
    UINavigationController * navigation = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    
    if ((_alertController) && ([navigation.visibleViewController isKindOfClass:[UIAlertController class]])) {
        return YES;
    }
    return NO;
}

- (void) dismissAlert {
    if ([self isAlertVisible]) {
        [_alertController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void) showAlert:(NSString *)msg
{
    UINavigationController * navigation = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    
    if (_alertController) {
        
        [self dismissAlert];
        _alertController = nil;
    }

    _alertController = [UIAlertController alertControllerWithTitle:@""
                                                           message:msg
                                                    preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *closeAction = [UIAlertAction actionWithTitle:@"Close"
                                                          style:UIAlertActionStyleDestructive
                                                        handler:nil];
    [_alertController addAction:closeAction];
    
    [navigation.viewControllers.lastObject presentViewController:_alertController animated:YES completion:nil];
}

- (BOOL) isProgressDialogVisible
{
    UINavigationController * navigation = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    
    if ((_progressController) && ([navigation.visibleViewController isKindOfClass:[UIAlertController class]])) {
        return YES;
    }
    return NO;
}

- (void) dismissProgressDialog
{
    if ([self isProgressDialogVisible]) {
        [_progressController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void) showProgressDialog:(NSString *)title
{
    UINavigationController * navigation = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    
    if (_progressController) {
        
        [self dismissProgressDialog];
        _progressController = nil;
    }
    
    _progressController = [UIAlertController alertControllerWithTitle:title
                                                           message:@"Left ??? packets"
                                                    preferredStyle:UIAlertControllerStyleAlert];
    
    [navigation.viewControllers.lastObject presentViewController:_progressController animated:YES completion:nil];
}

- (void) showNewPairCodeInput
{
    UINavigationController * navigation = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    
    if (_alertController) {
        
        [self dismissAlert];
        _alertController = nil;
    }
    
    _alertController = [UIAlertController alertControllerWithTitle:@"New pair code"
                                                           message:NSLocalizedString(@"Please input new pair code!", @"")
                                                    preferredStyle:UIAlertControllerStyleAlert];
    [_alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Old pair code";
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    [_alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"New pair code";
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    [_alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Confirm new pair code";
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                          style:UIAlertActionStyleDestructive
                                                        handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         UITextField *oldPairCode = [self.alertController.textFields objectAtIndex:0];
                                                         UITextField *newPairCode = [self.alertController.textFields objectAtIndex:1];
                                                         UITextField *confirmPairCode = [self.alertController.textFields objectAtIndex:2];
                                                         
                                                         if (([oldPairCode.text isEqualToString:@""]) ||
                                                             ([newPairCode.text isEqualToString:@""]) ||
                                                             ([confirmPairCode.text isEqualToString:@""])) {
                                                             [self showAlert:@"String is empty. Change pair code is not success."];
                                                             return;
                                                         }
                                                         
                                                         if (![newPairCode.text isEqualToString:confirmPairCode.text]) {
                                                             [self showAlert:@"Confirm and New strings are not equal. Change pair code is not success."];
                                                             return;
                                                         }
                                                         
                                                         HiFiToyDevice * device = [[HiFiToyDeviceList sharedInstance] getActiveDevice];
                                                         if (device.pairingCode != [oldPairCode.text intValue]) {
                                                             [self showAlert:@"Old pair code is not true. Change pair code is not success."];
                                                             return;
                                                         }
                                                         
                                                         device.pairingCode = [newPairCode.text intValue];
                                                         [[HiFiToyDeviceList sharedInstance] saveDeviceListToFile];
                                                     }];
    
    [_alertController addAction:cancelAction];
    [_alertController addAction:okAction];
    
    [navigation.viewControllers.lastObject presentViewController:_alertController animated:YES completion:nil];
}

- (void) showPairCodeInput
{
    UINavigationController * navigation = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    
    if (_alertController) {
        
        [self dismissAlert];
        _alertController = nil;
    }
    
    _alertController = [UIAlertController alertControllerWithTitle:@"Pair code fail"
                                                           message:NSLocalizedString(@"Please input valid pair code!", @"")
                                                    preferredStyle:UIAlertControllerStyleAlert];
    [_alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Pair code";
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];

    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleDestructive
                                                         handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         UITextField *pairCode = self.alertController.textFields.lastObject;
                                                         
                                                         if (![pairCode.text isEqualToString:@""]) {
                                                             HiFiToyDevice * device = [[HiFiToyDeviceList sharedInstance] getActiveDevice];
                                                             device.pairingCode = [pairCode.text intValue];
                                                             [[HiFiToyDeviceList sharedInstance] saveDeviceListToFile];
                                                             
                                                             //send pairing code
                                                             [[HiFiToyControl sharedInstance] startPairedProccess:device.pairingCode];
                                                         } else {
                                                             [navigation.viewControllers.lastObject presentViewController:self.alertController animated:YES completion:nil];
                                                         }
                                                     }];
    
    [_alertController addAction:cancelAction];
    [_alertController addAction:okAction];
    
    [navigation.viewControllers.lastObject presentViewController:_alertController animated:YES completion:nil];
}

- (void) showDeviceNameInput
{
    UINavigationController * navigation = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    
    if (_alertController) {
        
        [self dismissAlert];
        _alertController = nil;
    }
    
    _alertController = [UIAlertController alertControllerWithTitle:@"Device name"
                                                           message:NSLocalizedString(@"Please input new device name!", @"")
                                                    preferredStyle:UIAlertControllerStyleAlert];
    [_alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        //textField.keyboardType = UIKeyboardTypeNumberPad;
        HiFiToyDevice * device = [[HiFiToyDeviceList sharedInstance] getActiveDevice];
        textField.text = device.name;
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleDestructive
                                                         handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         UITextField *name = self.alertController.textFields.firstObject;
                                                         if (![name.text isEqualToString:@""]) {
                                                             HiFiToyDevice * device = [[HiFiToyDeviceList sharedInstance] getActiveDevice];
                                                             device.name = name.text;
                                                             
                                                             [[HiFiToyDeviceList sharedInstance] saveDeviceListToFile];
                                                             
                                                         } else {
                                                             [navigation.viewControllers.lastObject presentViewController:self.alertController animated:YES completion:nil];
                                                         }
                                                     }];
    
    [_alertController addAction:cancelAction];
    [_alertController addAction:okAction];
    
    [navigation.viewControllers.lastObject presentViewController:_alertController animated:YES completion:nil];
}

- (void) showImportPresetDialog
{
    UINavigationController * navigation = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    
    if (_alertController) {
        
        [self dismissAlert];
        _alertController = nil;
    }
    
    _alertController = [UIAlertController alertControllerWithTitle:@"Preset info"
                                                           message:NSLocalizedString(@"Import preset from HiFi Toy?", @"")
                                                    preferredStyle:UIAlertControllerStyleAlert];
    
    HiFiToyPreset * preset = [[[HiFiToyDeviceList sharedInstance] getActiveDevice] getActivePreset];
    HiFiToyPreset * tempPreset = [preset copy];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [preset saveToHiFiToyPeripheral];
                                                         }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         
                                                         
                                                         [tempPreset importFromHiFiToyPeripheral];
                                
                                                     }];
    
    [_alertController addAction:cancelAction];
    [_alertController addAction:okAction];
    
    [navigation.viewControllers.lastObject presentViewController:_alertController animated:YES completion:nil];
}

- (void) showEnergySyncDialog:(EnergyConfig_t)energy
{
    UINavigationController * navigation = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    
    if (_alertController) {
        
        [self dismissAlert];
        _alertController = nil;
    }
    
    _alertController = [UIAlertController alertControllerWithTitle:@"Info"
                                                           message:NSLocalizedString(@"Are you sure want to sync energy manager?", @"")
                                                    preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleDestructive
                                                         handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Sync"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         
                                                         [[HiFiToyControl sharedInstance] sendEnergyConfig:energy];
                                                         [self showAlert:@"Energy manager is syncronized."];
                                                     }];
    
    [_alertController addAction:cancelAction];
    [_alertController addAction:okAction];
    
    [navigation.viewControllers.lastObject presentViewController:_alertController animated:YES completion:nil];
}

- (void) showBiquadCoefSyncDialog:(BiquadLL *)biquad {
    UINavigationController * navigation = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    
    if (_alertController) {
        
        [self dismissAlert];
        _alertController = nil;
    }
    
    _alertController = [UIAlertController alertControllerWithTitle:@"Info"
                                                           message:NSLocalizedString(@"Are you sure want to sync biquad coefficients?", @"")
                                                    preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleDestructive
                                                         handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Sync"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         
                                                         [biquad sendWithResponse:YES];
                                                         [self showAlert:@"Biquad coefficients are syncronized."];
                                                     }];
    
    [_alertController addAction:cancelAction];
    [_alertController addAction:okAction];
    
    [navigation.viewControllers.lastObject presentViewController:_alertController animated:YES completion:nil];
}

- (void) showBiquadCoefWarning {
    UINavigationController * navigation = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    
    if (_alertController) {
        
        [self dismissAlert];
        _alertController = nil;
    }
    
    NSString * msg = @"Please be careful, this feature for geeks only. The text biquad entering requires exact values of coefficients, any mistake could make loud artifact-sounds which could be dangerous for your speakers! Try to simulate your settings first in some DSP/Filter design software(Matlab, SigmaStudio etc), and tap the BIQUAD SYNC next.\n\n\n\n";
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        _alertController = [UIAlertController alertControllerWithTitle:@"Info"
                                                               message:msg
                                                        preferredStyle:UIAlertControllerStyleAlert];
    } else {
        _alertController = [UIAlertController alertControllerWithTitle:@"Info"
                                                               message:msg
                                                        preferredStyle:UIAlertControllerStyleActionSheet];
    }
    
    
    int width = _alertController.view.frame.size.width;
    int height = _alertController.view.frame.size.height;
    
    /*UITextView * infoLabel = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, width, 100)];
    infoLabel.text = @"Please be careful, this feature for geeks only. The text biquad entering requires exact values of coefficients, any mistake could make loud artifact-sounds which could be dangerous for your speakers! Try to simulate your settings first in some DSP/Filter design software(Matlab, SigmaStudio etc), and tap the BIQUAD SYNC next.";
    infoLabel.textColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5];
    infoLabel.backgroundColor = [UIColor darkGrayColor];*/
    

    UISwitch * sw = [[UISwitch alloc] initWithFrame:CGRectMake(width - 100, 200, 0, 0)];
    //sw.frame = CGRectMake(0, 0, sw.frame.size.width, sw.frame.size.height);
    [_alertController.view addSubview:sw];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Don`t show again, continue"
                                                           style:UIAlertActionStyleDestructive
                                                         handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Continue"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         
                                                    
                                                     }];
    
    //[_alertController addAction:cancelAction];
    [_alertController addAction:okAction];
    
    NSLog(@"_alertController.view.subviews count=%d", (int)_alertController.view.subviews.count);
    UIView * firstSubview = _alertController.view.subviews.firstObject;
    NSLog(@"firstSubview.subviews count=%d %d", (int)firstSubview.subviews.count, firstSubview.frame.size.height);
    UIView * alertContentView = firstSubview.subviews.firstObject;
    NSLog(@"alertContentView.subviews count=%d %d", (int)alertContentView.subviews.count, alertContentView.frame.size.height);
    for (int i = 0; i < alertContentView.subviews.count; i++) {
        UIView * v = [alertContentView.subviews objectAtIndex:i];
        v.backgroundColor = [UIColor darkGrayColor];
        int height = v.frame.size.height;
        NSLog(@"%d %d", v.frame.origin.y, v.frame.size.height);
    }

    _alertController.view.tintColor = [UIColor orangeColor];
    
    [navigation.viewControllers.lastObject presentViewController:_alertController animated:YES completion:nil];
    
}

@end
