//
//  PresetUrlImportViewController.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 10/06/2019.
//  Copyright © 2019 Kerosinn_OSX. All rights reserved.
//

#import "PresetUrlImportViewController.h"
#import "DialogSystem.h"
#import "HiFiToyPreset.h"
#import "HiFiToyPresetList.h"

@interface PresetUrlImportViewController ()

@end

@implementation PresetUrlImportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)importPreset:(id)sender {
    NSURL * fileURL = [[NSURL alloc] initWithString:self.urlTextFiled_outl.text];
    
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:fileURL
                                          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              if (error != nil) {
                                                  [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                                                      [[DialogSystem sharedInstance] showAlert:[error localizedDescription]];
                                                  }];
                                                  
                                              } else {
                                                  //NSString * s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                                  //NSLog(@"%@", s);
                                                  
                                                  [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                                                      [self import:data];
                                                  }];
                                                  
                                                  
                                                  
                                              }
                                          }];
    [downloadTask resume];
}

- (void) import:(NSData *)d {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Preset name"
                                                                             message:NSLocalizedString(@"Please input preset name!", @"")
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = @"";
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleDestructive
                                                         handler:nil];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
        
                                                         UITextField *name = alertController.textFields.firstObject;
                                                         if (![name.text isEqualToString:@""]) {
 
                                                             [[HiFiToyPresetList sharedInstance] importPresetFromData:d
                                                                                                           withName:name.text
                                                                                                          checkName:YES];
                                                         }
                                                     }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}
@end
