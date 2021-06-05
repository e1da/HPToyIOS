//
//  OptionsViewController.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 08/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HiFiToyDevice.h"
#import "HiFiToyControl.h"

@interface OptionsViewController : UITableViewController {

}

//dspDevice
@property HiFiToyDevice * hiFiToyDevice;

//outlets
@property (weak, nonatomic) IBOutlet UILabel *nameLabel_outl;
@property (weak, nonatomic) IBOutlet UITableViewCell *outputModeCell_outl;
@property (weak, nonatomic) IBOutlet UITableViewCell *amModeCell_outl;

@end
