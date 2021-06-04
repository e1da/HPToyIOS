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

@property (nonatomic, readonly) UIAlertController * _Nullable alertController;
@property (nonatomic, readonly) UIAlertController * _Nullable progressController;


+ (DialogSystem * _Nonnull) sharedInstance;

- (BOOL) isAlertVisible;
- (void) dismissAlert;

- (void) showDialog:(NSString * _Nonnull)title
                msg:(NSString * _Nonnull)msg
              okBtn:(NSString * _Nullable)okBtn
          cancelBtn:(NSString * _Nullable)cancelBtn
       okBtnHandler:(void (^ __nullable)(UIAlertAction * _Nonnull action))okHandler
   cancelBtnHandler:(void (^ __nullable)(UIAlertAction * _Nonnull action))cancelHandler;

- (void) showAlert:(NSString * _Nonnull)msg;

- (BOOL) isProgressDialogVisible;
- (void) dismissProgressDialog;
- (void) dismissProgressDialog:(void (^ __nullable)(void))completion;
- (void) showProgressDialog:(NSString * _Nonnull)title;

- (void) showNewPairCodeInput;
- (void) showPairCodeInput;

- (void) showImportPresetDialog;

@end
