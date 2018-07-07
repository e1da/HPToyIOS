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

@interface XOverViewController : UIViewController <UIPopoverPresentationControllerDelegate> {
    id <HiFiToyObject> activeElement;
}

@property int maxFreq;
@property int minFreq;

//@property NSMutableDictionary * dspElements;
//@property NSString * activeElementKey;

@property XOver * xover;

@property (strong, nonatomic) IBOutlet XOverView *xOverView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *peqFlag_outl;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addEQ_outl;

- (IBAction)setPeqFlag:(id)sender;

- (IBAction)doubleTapHandle:(id)sender;
- (IBAction)longPressHandle:(id)sender;
- (IBAction)panHandle:(id)sender;
- (IBAction)pinchHandle:(id)sender;

- (IBAction)addParametric:(id)sender;
- (IBAction)delParametric:(id)sender;

/*- (IBAction)touchupinside:(id)sender;
- (IBAction)touchupoutside:(id)sender;
- (IBAction)touchdown:(id)sender;*/

@end
