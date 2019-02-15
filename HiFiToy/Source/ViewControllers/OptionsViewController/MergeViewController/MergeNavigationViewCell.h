//
//  MergeNavigationViewCell.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 14/02/2019.
//  Copyright © 2019 Kerosinn_OSX. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MergeNavigationViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *itemLabel_outl;
@property (weak, nonatomic) IBOutlet UIButton *prevButton_outl;
@property (weak, nonatomic) IBOutlet UIButton *nextButton_outl;

@end

NS_ASSUME_NONNULL_END
