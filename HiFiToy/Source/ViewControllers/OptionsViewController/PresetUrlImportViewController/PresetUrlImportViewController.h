//
//  PresetUrlImportViewController.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 10/06/2019.
//  Copyright © 2019 Kerosinn_OSX. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PresetUrlImportViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *urlTextFiled_outl;
- (IBAction)importPreset:(id)sender;

@end

NS_ASSUME_NONNULL_END
