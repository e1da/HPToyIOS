//
//  DialogSystem.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 07/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HiFiToyObject.h"
#import "BiquadLL.h"

@interface DialogSystem : NSObject

@property (nonatomic) UIAlertController * alertController;
@property (nonatomic) UIAlertController * progressController;


+ (DialogSystem *) sharedInstance;

- (BOOL) isAlertVisible;
- (void) dismissAlert;
- (void) showAlert:(NSString *)msg;

- (BOOL) isProgressDialogVisible;
- (void) dismissProgressDialog;
- (void) showProgressDialog:(NSString *)title;

- (void) showNewPairCodeInput;
- (void) showPairCodeInput;
- (void) showDeviceNameInput;

- (void) showImportPresetDialog;

- (void) showEnergySyncDialog:(EnergyConfig_t)energy;
- (void) showBiquadCoefSyncDialog:(BiquadLL *)biquad;

- (void) showBiquadCoefWarning;
@end
