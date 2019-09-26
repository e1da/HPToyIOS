//
//  DialogSystem.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 07/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HiFiToyObject.h"
#import "Biquad.h"

@interface DialogSystem : NSObject

@property (nonatomic) UIAlertController * alertController;
@property (nonatomic) UIAlertController * progressController;


+ (DialogSystem *) sharedInstance;

- (BOOL) isAlertVisible;
- (void) dismissAlert;
- (void) showAlert:(NSString *)msg;

- (BOOL) isProgressDialogVisible;
- (void) dismissProgressDialog;
- (void) dismissProgressDialog:(void (^ __nullable)(void))completion;
- (void) showProgressDialog:(NSString *)title;

- (void) showNewPairCodeInput;
- (void) showPairCodeInput;

- (void) showImportPresetDialog;

- (void) showEnergySyncDialog;
- (void) showBiquadCoefSyncDialog:(Biquad *)biquad;

@end
