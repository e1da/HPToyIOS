//
//  PresetTextImportViewController.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 10/06/2019.
//  Copyright © 2019 Kerosinn_OSX. All rights reserved.
//

#import "PresetTextImportViewController.h"
#import "HiFiToyPreset.h"

@interface PresetTextImportViewController ()

@end

@implementation PresetTextImportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIView * dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    self.presetTextView_outl.inputView = dummyView; // Hide keyboard, but show blinking cursor
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)importPreset:(id)sender {
    NSData * d = [self.presetTextView_outl.text dataUsingEncoding:NSUTF8StringEncoding];
    
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
                                                             HiFiToyPreset * importPreset = [HiFiToyPreset getDefault];
                                                             [importPreset importFromXmlWithData:d withName:name.text];
                                                            
                                                         }
                                                     }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}
@end
