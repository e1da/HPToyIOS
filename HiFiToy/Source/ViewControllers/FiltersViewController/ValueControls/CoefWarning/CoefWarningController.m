//
//  CoefWarningController.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 03/11/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "CoefWarningController.h"

@interface CoefWarningController ()

@end

@implementation CoefWarningController

- (id) init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor clearColor];
    
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    
    textView = [[UITextView alloc] init];//WithFrame:CGRectMake(0, height - 150 - 80 - 80, width , 150)];
    textView.backgroundColor = [UIColor grayColor];
    textView.editable = NO;
    textView.scrollEnabled = NO;
    textView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    textView.text = [self getMessage];
    textView.textAlignment = NSTextAlignmentCenter;
    textView.textColor = [UIColor whiteColor];
    textView.layer.cornerRadius = 15;
    textView.layer.maskedCorners = (kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner);
    [self.view addSubview:textView];
    
    
    dontShowView = [[DontShowView alloc] init];
    //[dontShowView setFrame:CGRectMake(0, height - 80 - 80, width , 80)];
    dontShowView.backgroundColor = [UIColor grayColor];
    [self.view addSubview:dontShowView];
    
    continueButton = [[UIButton alloc] init];//WithFrame:CGRectMake(0, height - 80, width, 80)];
    continueButton.backgroundColor = [UIColor grayColor];
    continueButton.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    continueButton.layer.borderWidth = 1;
    NSDictionary * attr = [NSDictionary dictionaryWithObject:[UIFont fontWithName:@"ArialRoundedMTBold" size:18]
                                                      forKey:NSFontAttributeName];
    NSAttributedString * attrStr =  [[NSMutableAttributedString alloc] initWithString:@"NEXT" attributes:attr];
    
    [continueButton setAttributedTitle:attrStr forState:UIControlStateNormal];
    continueButton.titleLabel.textColor =  [UIColor colorWithRed:1.0 green:0.55 blue:0.05 alpha:1.0];// [UIColor orangeColor];
    //[continueButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    
    [continueButton addTarget:self action:@selector(didContinue) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:continueButton];
}


- (NSString *) getMessage {
    return @"\nPlease be careful, this feature for geeks only. The text biquad entering requires exact values of coefficients, any mistake could make loud artifact-sounds which could be dangerous for your speakers! Try to simulate your settings first in some DSP/Filter design software(Matlab, SigmaStudio etc), and tap the BIQUAD SYNC next.";
}

- (void) viewWillLayoutSubviews {
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    
    CGFloat textHeight = textView.bounds.size.height;
    [textView setFrame:CGRectMake(0, 0, width , textHeight)];
    [textView sizeToFit];
    textHeight = textView.bounds.size.height;
    [textView setFrame:CGRectMake(0, height - textHeight - 80 - 80, width , textHeight)];
    
    NSLog(@"%f %f", textView.frame.size.width, textView.frame.size.height);
    
    
    [dontShowView setFrame:CGRectMake(0, height - 80 - 80, width , 80)];
    [continueButton setFrame:CGRectMake(0, height - 80, width, 80)];
}

- (void) didContinue {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
