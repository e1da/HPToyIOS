//
//  AmModeViewController.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 04/06/2021.
//  Copyright © 2021 Kerosinn_OSX. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AmModeViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UISwitch *amModeEnabledSwitch;

- (IBAction)setAmMode:(id)sender;

@end

NS_ASSUME_NONNULL_END
