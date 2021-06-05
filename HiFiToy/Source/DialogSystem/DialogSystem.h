//
//  DialogSystem.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 07/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HiFiToyObject.h"
#import "HiFiToyPreset.h"
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
       okBtnHandler:(void (^ __nullable)(UIAlertAction * _Nullable action))okHandler
   cancelBtnHandler:(void (^ __nullable)(UIAlertAction * _Nullable action))cancelHandler;

- (void) showTextDialog:(NSString * _Nonnull)title
                    msg:(NSString * _Nonnull)msg
                  okBtn:(NSString * _Nullable)okBtn
              cancelBtn:(NSString * _Nullable)cancelBtn
      textConfigHandler:(void (^ __nullable)(UITextField * _Nullable textField))textConfigHandler
           okBtnHandler:(void (^ __nullable)(UIAlertAction * _Nullable action))okHandler
       cancelBtnHandler:(void (^ __nullable)(UIAlertAction * _Nullable action))cancelHandler;

- (void) showTextDialog:(NSString * _Nonnull)title
                    msg:(NSString * _Nonnull)msg
                  okBtn:(NSString * _Nullable)okBtn
              cancelBtn:(NSString * _Nullable)cancelBtn
           okBtnHandler:(void (^ __nullable)(UIAlertAction * _Nullable action))okHandler
       cancelBtnHandler:(void (^ __nullable)(UIAlertAction * _Nullable action))cancelHandler;

- (void) showAlert:(NSString * _Nonnull)msg;

- (BOOL) isProgressDialogVisible;
- (void) dismissProgressDialog;
- (void) dismissProgressDialog:(void (^ __nullable)(void))completion;
- (void) showProgressDialog:(NSString * _Nonnull)title;

- (void) showNewPairCodeInput;
- (void) showPairCodeInput;

- (void) showSavePresetDialog:(HiFiToyPreset * _Nonnull)preset
                    okHandler:(void (^ __nullable)(void))okHandler;
- (void) showImportPresetDialog;

@end
