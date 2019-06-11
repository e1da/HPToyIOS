//
//  DownloadPresetCellTableViewCell.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 07/06/2019.
//  Copyright © 2019 Kerosinn_OSX. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DownloadPresetCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *downloadPresetName_outl;
- (IBAction)downloadPreset:(id)sender;

@end

NS_ASSUME_NONNULL_END
