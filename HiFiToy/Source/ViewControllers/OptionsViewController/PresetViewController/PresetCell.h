//
//  PresetCell.h
//  BT2x500
//
//  Created by Kerosinn_OSX on 29/04/2015.
//  Copyright (c) 2015 Kerosinn_OSX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PresetDetailButton.h"

@interface PresetCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *presetLabel_outl;
@property (weak, nonatomic) IBOutlet PresetDetailButton *presetDetailButton_outl;


@end
