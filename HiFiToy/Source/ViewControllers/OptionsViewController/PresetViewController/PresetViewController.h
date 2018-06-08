//
//  PresetViewController.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 08/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "HiFiToyDeviceList.h"
#import "HiFiToyPresetList.h"

@interface PresetViewController : UITableViewController <UIAlertViewDelegate> {
    HiFiToyPresetList * hiFiToyPresetList;
}

@property HiFiToyDevice *hiFiToyDevice;

- (IBAction)addNewPreset:(id)sender;

@end
