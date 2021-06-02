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

- (void) dismissProgressDialog:(void (^ __nullable)(void))completion
{
    if ([self isProgressDialogVisible]) {
        [_progressController dismissViewControllerAnimated:YES completion:completion];
    } else {
        completion();
    }
}


- (void) showProgressDialog:(NSString *)title
{
    UINavigationController * navigation = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    
    if ([self isProgressDialogVisible]){
        //_progressController.title = title;
        //[self dismissProgressDialog];
        //_progressController = nil;
    } else {
    
        _progressController = [UIAlertController alertControllerWithTitle:title
                                                                  message:@"Left ??? packets"
                                                           preferredStyle:UIAlertControllerStyleAlert];
    
        [navigation.viewControllers.lastObject presentViewController:_progressController animated:YES completion:nil];
    }
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
                                                         
                                                         HiFiToyDevice * device = [[HiFiToyControl sharedInstance] activeHiFiToyDevice];
                                                         if (device.pairingCode != [oldPairCode.text intValue]) {
                                                             [self showAlert:@"Old pair code is not true. Change pair code is not success."];
                                                             return;
                                                         }
                                                         
                                                         device.pairingCode = [newPairCode.text intValue];
                                                         [[HiFiToyDeviceList sharedInstance] saveDeviceListToFile];
                                                         
                                                         [[HiFiToyControl sharedInstance] sendNewPairingCode:device.pairingCode];
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
                                                             HiFiToyDevice * device = [[HiFiToyControl sharedInstance] activeHiFiToyDevice];
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

- (void) showImportPresetDialog
{
    UINavigationController * navigation = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    
    if (_alertController) {
        
        [self dismissAlert];
        _alertController = nil;
    }
    
    NSString * bundleName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    NSString * msg = [NSString stringWithFormat:@"Import preset from %@?", bundleName];
    
    _alertController = [UIAlertController alertControllerWithTitle:@"Preset info"
                                                           message:msg
                                                    preferredStyle:UIAlertControllerStyleAlert];
    
    HiFiToyDevice * dev = [[HiFiToyControl sharedInstance] activeHiFiToyDevice];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleDestructive
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [dev.preset storeToPeripheral];
                                                         }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        [dev importPreset:^() {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SetupOutletsNotification" object:nil];
        }];
    }];
    
    [_alertController addAction:cancelAction];
    [_alertController addAction:okAction];
    
    [navigation.viewControllers.lastObject presentViewController:_alertController animated:YES completion:nil];
}

- (void) showEnergySyncDialog
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
                                                         
                                                         [[[HiFiToyControl sharedInstance] activeHiFiToyDevice] sendEnergyConfig];
                                                         [self showAlert:@"Energy manager is syncronized."];
                                                     }];
    
    [_alertController addAction:cancelAction];
    [_alertController addAction:okAction];
    
    [navigation.viewControllers.lastObject presentViewController:_alertController animated:YES completion:nil];
}

- (void) showBiquadCoefSyncDialog:(Biquad *)biquad {
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

@end
