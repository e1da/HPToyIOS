//
//  MainViewController.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 07/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HiFiToyControl.h"
#import "HiFiToyDeviceList.h"
#import "HiFiToyPreset.h"

@interface MainViewController : UITableViewController {
    HiFiToyControl * hiFiToyControl;
    HiFiToyDevice * hiFiToyDevice;
    HiFiToyPreset * hiFiToyPreset;
}

//outlets
@property (weak, nonatomic) IBOutlet UILabel *gainLabel_outl;
@property (weak, nonatomic) IBOutlet UISlider *gainSlider_outl;
@property (weak, nonatomic) IBOutlet UILabel *bassLabel_outl;
@property (weak, nonatomic) IBOutlet UISlider *bassSlider_outl;
@property (weak, nonatomic) IBOutlet UILabel *trebleLabel_outl;
@property (weak, nonatomic) IBOutlet UISlider *trebleSlider_outl;
@property (weak, nonatomic) IBOutlet UILabel *loudnessLabel_outl;
@property (weak, nonatomic) IBOutlet UISlider *loudnessSlider_outl;

//actions
- (IBAction)setGainSlider:(id)sender;
- (IBAction)setBassSlider:(id)sender;
- (IBAction)setTrebleSlider:(id)sender;
- (IBAction)setLoudnessSlider:(id)sender;

@end
