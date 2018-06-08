//
//  PresetDetailViewController.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 08/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "HiFiToyPresetList.h"

@interface PresetDetailViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic) HiFiToyPreset *hiFiToyPreset;

@property (weak, nonatomic) IBOutlet UITextField *name_outl;

- (IBAction)editNamePreset:(id)sender;
- (IBAction)sharePreset:(id)sender;


@end
