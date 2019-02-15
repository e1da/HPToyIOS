//
//  MergeNavigationViewCell.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 14/02/2019.
//  Copyright © 2019 Kerosinn_OSX. All rights reserved.
//

#import "MergeNavigationViewCell.h"

@implementation MergeNavigationViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
