//
//  PresetTextImportViewController.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 10/06/2019.
//  Copyright © 2019 Kerosinn_OSX. All rights reserved.
//

#import "PresetTextImportViewController.h"
#import "HiFiToyPreset.h"
#import "HiFiToyPresetList.h"
#import "DialogSystem.h"

@interface PresetTextImportViewController ()

@end

@implementation PresetTextImportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIView * dummyView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 1)];
    self.presetTextView_outl.inputView = dummyView; // Hide keyboard, but show blinking cursor
}


- (IBAction)importPreset:(id)sender {
    NSData * data = [self.presetTextView_outl.text dataUsingEncoding:NSUTF8StringEncoding];
    
    HiFiToyPreset * p = [HiFiToyPreset getDefault];
    [p importFromXmlWithData:data
                    withName:[[NSDate date] descriptionWithLocale:[NSLocale systemLocale]]
               resultHandler:^(HiFiToyPreset * _Nonnull p, NSString * _Nullable error) {
          
        if (error) {
            [[DialogSystem sharedInstance] showAlert:error];
            
        } else {
            [[DialogSystem sharedInstance] showSavePresetDialog:p okHandler:^{
                [self.navigationController popViewControllerAnimated:YES];
            }];
            
        }
    }];
}

@end
