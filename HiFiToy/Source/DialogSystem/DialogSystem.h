//
//  DialogSystem.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 07/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DialogSystem : NSObject

@property (nonatomic) UIAlertController * alertController;


+ (DialogSystem *) sharedInstance;

- (BOOL) isAlertVisible;
- (void) dismissAlert;
- (void) showAlert:(NSString *)msgString;

@end
