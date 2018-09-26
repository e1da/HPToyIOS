//
//  EnergyViewController.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 23/09/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface EnergyViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UILabel *autoOffLabel_outl;
@property (weak, nonatomic) IBOutlet UISlider *autoOffSlider_outl;
@property (weak, nonatomic) IBOutlet UILabel *clipLabel_outl;
@property (weak, nonatomic) IBOutlet UISlider *clipSlider_outl;

- (IBAction)setClipThreshold_outl:(id)sender;
- (IBAction)setAutoOffThreshold:(id)sender;
- (IBAction)syncEnergyConfig:(id)sender;

@end

NS_ASSUME_NONNULL_END
