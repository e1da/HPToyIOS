//
//  DiscoveryViewController.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 07/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HiFiToyControl.h"
#import "HiFiToyDeviceList.h"

@interface DiscoveryViewController : UITableViewController <UIAlertViewDelegate> {
    HiFiToyControl * hiFiToyControl;
    HiFiToyDeviceList * hiFiToyDeviceList;
}

@end
