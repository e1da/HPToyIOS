//
//  DialogSystem.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 07/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "DialogSystem.h"

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
@end
