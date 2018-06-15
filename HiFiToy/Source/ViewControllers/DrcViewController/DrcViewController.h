//
//  DrcViewController.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 15/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrcView.h"
#import "Drc.h"

@interface DrcViewController : UITableViewController {
    Drc * drc;
}

@property (weak, nonatomic) IBOutlet DrcView *drcView;

//outlets
@property (weak, nonatomic) IBOutlet UILabel *enabledLabel_outl;
@property (weak, nonatomic) IBOutlet UISlider *enabledSlider_outl;

- (IBAction)setEnabledSlider:(id)sender;

- (IBAction)doubleTapHandle:(id)sender;
- (IBAction)longPressHandle:(id)sender;
- (IBAction)panHandle:(id)sender;

@end
