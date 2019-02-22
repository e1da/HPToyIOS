//
//  AdvertiseViewController.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 22/02/2019.
//  Copyright © 2019 Kerosinn_OSX. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdvertiseViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UISwitch *advertiseModeSwitch_outl;

- (IBAction)setAdvertiseMode:(id)sender;

@end

NS_ASSUME_NONNULL_END
