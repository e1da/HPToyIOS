//
//  XOverViewController.h
//  HiFiToy
//
//  Created by Kerosinn_OSX on 13/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XOverView.h"
#import "HiFiToyObject.h"

@interface XOverViewController : UIViewController <UIPopoverPresentationControllerDelegate>

@property int maxFreq;
@property int minFreq;

@property Filters * filters;

@property (strong, nonatomic) IBOutlet XOverView *xOverView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *peqFlag_outl;

- (IBAction)setPeqFlag:(id)sender;

- (IBAction)doubleTapHandle:(id)sender;
- (IBAction)longPressHandle:(id)sender;
- (IBAction)panHandle:(id)sender;
- (IBAction)pinchHandle:(id)sender;

@end
