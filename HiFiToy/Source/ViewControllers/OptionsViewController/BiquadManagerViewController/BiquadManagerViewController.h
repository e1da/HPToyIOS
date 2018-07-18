//
//  BiquadManagerViewController.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 02/07/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HiFiToyPreset.h"

@interface BiquadManagerViewController : UITableViewController

@property XOver * xover;

@property (weak, nonatomic) IBOutlet UILabel *hpBiquadLabel_outl;
@property (weak, nonatomic) IBOutlet UILabel *lpBiquadLabel_outl;
@property (weak, nonatomic) IBOutlet UILabel *paramBiquadLabel_outl;

//- (void) setHp:(BiquadLength_t)biquadLength;
//- (void) setLp:(BiquadLength_t)biquadLength;

@end
