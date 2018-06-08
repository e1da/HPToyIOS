//
//  DeviceNameViewController.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 08/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HiFiToyDeviceList.h"

@interface DeviceNameViewController : UITableViewController <UITextFieldDelegate>


@property HiFiToyDevice * hiFiToyDevice;

@property (weak, nonatomic) IBOutlet UITextField * name_outl;

- (IBAction)editName:(id)sender;

@end
