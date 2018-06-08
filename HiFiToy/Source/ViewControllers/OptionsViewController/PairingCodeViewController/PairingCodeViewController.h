//
//  PairingCodeViewController.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 08/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HiFiToyControl.h"
#import "HiFiToyDeviceList.h"

@interface PairingCodeViewController : UITableViewController

@property HiFiToyDevice * hiFiToyDevice;

@property (weak, nonatomic) IBOutlet UITextField * pairingCodeTextField_outl;

@end

