//
//  MergeToolCell.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 13/02/2019.
//  Copyright © 2019 Kerosinn_OSX. All rights reserved.
//

#import "MergeToolCell.h"

@implementation MergeToolCell


- (void) setNeedsLayout {
    self.mergeLabel_outl.text = @"Merge Tool";
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [super setNeedsLayout];
}
@end
