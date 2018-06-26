//
//  DrcTimeConstViewController.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 23/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Drc.h"

@interface DrcTimeConstViewController : UITableViewController {
    Drc * drc;
}

//outlets
@property (weak, nonatomic) IBOutlet UILabel    * energyLabel_outl;
@property (weak, nonatomic) IBOutlet UISlider   * energySlider_outl;
@property (weak, nonatomic) IBOutlet UILabel    * attackLabel_outl;
@property (weak, nonatomic) IBOutlet UISlider   * attackSlider_outl;
@property (weak, nonatomic) IBOutlet UILabel    * decayLabel_outl;
@property (weak, nonatomic) IBOutlet UISlider   * decaySlider_outl;

- (IBAction)setEnergySlider:(id)sender;
- (IBAction)setAttackSlider:(id)sender;
- (IBAction)setDecaySlider:(id)sender;

@end
