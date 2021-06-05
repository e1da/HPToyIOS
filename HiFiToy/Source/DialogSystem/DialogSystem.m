//
//  DialogSystem.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 07/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "DialogSystem.h"
#import "HiFiToyDeviceList.h"
#import "HiFiToyPresetList.h"
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

- (UIViewController *) lastViewController {
    UINavigationController * navi = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    
    return navi.viewControllers.lastObject;
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

- (void) showDialog:(NSString *)title
                msg:(NSString *)msg
              okBtn:(NSString *)okBtn
          cancelBtn:(NSString *)cancelBtn
       okBtnHandler:(void (^ __nullable)(UIAlertAction *action))okHandler
   cancelBtnHandler:(void (^ __nullable)(UIAlertAction *action))cancelHandler {
    
    [self dismissAlert];
    
    _alertController = [UIAlertController alertControllerWithTitle:title
                                                           message:msg
                                                    preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * cancelAction = nil;
    if (cancelBtn) {
        cancelAction = [UIAlertAction actionWithTitle:cancelBtn
                                                style:UIAlertActionStyleDestructive
                                              handler:cancelHandler];
        [_alertController addAction:cancelAction];
    }
    
    UIAlertAction * okAction = nil;
    if (okBtn) {
        okAction = [UIAlertAction actionWithTitle:okBtn
                                                style:UIAlertActionStyleDefault
                                              handler:okHandler];
        [_alertController addAction:okAction];
    }
    
    [[self lastViewController]  presentViewController:_alertController animated:YES completion:nil];
}

- (void) showTextDialog:(NSString *)title
                    msg:(NSString *)msg
                  okBtn:(NSString *)okBtn
              cancelBtn:(NSString *)cancelBtn
      textConfigHandler:(void (^ __nullable)(UITextField *textField))textConfigHandler
           okBtnHandler:(void (^ __nullable)(UIAlertAction *action))okHandler
       cancelBtnHandler:(void (^ __nullable)(UIAlertAction *action))cancelHandler {
    
    [self dismissAlert];
    
    _alertController = [UIAlertController alertControllerWithTitle:@""
                                                           message:msg
                                                    preferredStyle:UIAlertControllerStyleAlert];
    
    [_alertController addTextFieldWithConfigurationHandler:textConfigHandler];
    
    UIAlertAction * cancelAction = nil;
    if (cancelBtn) {
        cancelAction = [UIAlertAction actionWithTitle:cancelBtn
                                                style:UIAlertActionStyleDestructive
                                              handler:cancelHandler];
        [_alertController addAction:cancelAction];
    }
    
    UIAlertAction * okAction = nil;
    if (okBtn) {
        okAction = [UIAlertAction actionWithTitle:okBtn
                                                style:UIAlertActionStyleDefault
                                              handler:okHandler];
        [_alertController addAction:okAction];
    }
    
    [[self lastViewController]  presentViewController:_alertController animated:YES completion:nil];
}

- (void) showTextDialog:(NSString *)title
                    msg:(NSString *)msg
                  okBtn:(NSString *)okBtn
              cancelBtn:(NSString *)cancelBtn
           okBtnHandler:(void (^ __nullable)(UIAlertAction *action))okHandler
       cancelBtnHandler:(void (^ __nullable)(UIAlertAction *action))cancelHandler {
    [self showTextDialog:title msg:msg okBtn:okBtn cancelBtn:cancelBtn textConfigHandler:^(UITextField * _Nullable textField) {
        textField.text = @"";
    } okBtnHandler:okHandler cancelBtnHandler:cancelHandler];
}


- (void) showAlert:(NSString *)msg {
    [self showDialog:@"" msg:msg okBtn:nil cancelBtn:@"Close" okBtnHandler:nil cancelBtnHandler:nil];
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
    
    if (![self isProgressDialogVisible]) {
        
        _progressController = [UIAlertController alertControllerWithTitle:title
                                                                  message:@"Left ??? packets"
                                                           preferredStyle:UIAlertControllerStyleAlert];
    
        [[self lastViewController] presentViewController:_progressController animated:YES completion:nil];
    }
}

- (void) showNewPairCodeInput
{
    UINavigationController * navigation = (UINavigationController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    
    [self dismissAlert];
    
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
    [self showTextDialog:@"Pair code fail"
                     msg:NSLocalizedString(@"Please input valid pair code!", @"")
                   okBtn:@"Ok"
               cancelBtn:@"Cancel"
       textConfigHandler:^(UITextField * _Nullable textField) {
            textField.placeholder = @"Pair code";
            textField.borderStyle = UITextBorderStyleRoundedRect;
            textField.keyboardType = UIKeyboardTypeNumberPad;
        
    }
            okBtnHandler:^(UIAlertAction * _Nullable action) {
        
        NSString * textField = self.alertController.textFields[0].text;
        if ([textField isEqualToString:@""]) {
            textField = @"0";
        }
        
        HiFiToyDevice * device = [[HiFiToyControl sharedInstance] activeHiFiToyDevice];
        device.pairingCode = [textField intValue];
        [[HiFiToyDeviceList sharedInstance] saveDeviceListToFile];
                                                             
        //send pairing code
        [[HiFiToyControl sharedInstance] startPairedProccess:device.pairingCode];
                                                         
    } cancelBtnHandler:nil];
}

- (void) showSavePresetDialog:(HiFiToyPreset *)preset okHandler:(void (^ __nullable)(void))okHandler {
    [self showTextDialog:@""
                     msg:NSLocalizedString(@"Please input preset name:", @"")
                   okBtn:@"Ok"
               cancelBtn:@"Cancel"
            okBtnHandler:^(UIAlertAction *action) {
        
        UITextField *name = [self.alertController textFields][0];
        preset.presetName = (![name.text isEqualToString:@""]) ? name.text : @" ";
        
        if ([[HiFiToyPresetList sharedInstance] isPresetExist:preset.presetName] == NO) {
            [[HiFiToyPresetList sharedInstance] setPreset:preset];
        
            if (okHandler) okHandler();
            
        } else {
            
            NSString * msg = [NSString stringWithFormat:@"Preset with name \"%@\" already exists. Do you want to replace it?", preset.presetName ];
            
            [[DialogSystem sharedInstance] showDialog:@"Warning"
                                                  msg:msg
                                                okBtn:@"Replace"
                                            cancelBtn:@"Cancel"
                                         okBtnHandler:^(UIAlertAction * _Nonnull action) {
                [[HiFiToyPresetList sharedInstance] setPreset:preset];
                if (okHandler) okHandler();
                
            } cancelBtnHandler:nil];
            
        }
    
    }
    
        cancelBtnHandler:nil];
}

- (void) showImportPresetDialog {
    NSString * bundleName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    NSString * msg = [NSString stringWithFormat:@"Import preset from %@?", bundleName];
    
    __block HiFiToyDevice * dev = [[HiFiToyControl sharedInstance] activeHiFiToyDevice];
    
    [self showDialog:@"Preset info"
                 msg:msg
               okBtn:@"Ok"
           cancelBtn:@"Cancel"
        okBtnHandler:^(UIAlertAction * action) { // import preset
        
        [dev importPreset:^() {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"SetupOutletsNotification" object:nil];
        }];
        
    }
    cancelBtnHandler:^(UIAlertAction * action) { // store preset
        //update checksum and save
        [dev.preset updateChecksum];
        [[HiFiToyPresetList sharedInstance] setPreset:dev.preset];
        
        [dev.preset storeToPeripheral];
    
    }];
    
}

@end
