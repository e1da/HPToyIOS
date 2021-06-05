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

- (void) import:(NSData *)data {    
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
