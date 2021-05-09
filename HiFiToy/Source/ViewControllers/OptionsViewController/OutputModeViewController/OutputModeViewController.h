//
//  OutputModeViewController.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 07/05/2021.
//  Copyright © 2021 Kerosinn_OSX. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OutputModeViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISegmentedControl *outputSegmentedOutlet;

- (IBAction)setOutputMode:(id)sender;

- (void) setupOutlets;

@end

NS_ASSUME_NONNULL_END
