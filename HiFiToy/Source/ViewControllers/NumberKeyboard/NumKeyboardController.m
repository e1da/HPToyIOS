//
//  NumKeyboardControllerViewController.m
//  TextEditTest
//
//  Created by Kerosinn_OSX on 30/09/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "NumKeyboardController.h"
#import "KeyboardButton.h"

@interface NumKeyboardController () {
    KeyboardView * keyboardView;
    UIButton * minusButton;
    UIButton * pointButton;
    UILabel * valLabel;
    
    int pointPosition;
}

- (void) didEnter;
@end

@implementation NumKeyboardController

- (id) init {
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    pointPosition = -1;
    
    [self addCancelButton];
    [self addValueLabelView];
    [self addKeyboardView];
    
}

- (void) viewWillLayoutSubviews {
    float width = self.view.frame.size.width;
    float height = self.view.frame.size.height;
    float btnHeight = (70 * 4  < height / 2) ? 70 : height / 2 / 4;
    
    [keyboardView setFrame:CGRectMake(0,
                                      height - btnHeight * 4,
                                      width,
                                      btnHeight * 4)];
    [valLabel setFrame:CGRectMake(0,
                                  (height - keyboardView.frame.size.height) / 2,
                                  self.view.frame.size.width,
                                  valLabel.frame.size.height)];
}

/* -------------------------------- Views creation -------------------------------------*/
- (void) addCancelButton {
    UIButton * cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 0, 50, 50)];
    //[cancelButton setBackgroundImage:[UIImage imageNamed:@"Cancel"] forState:UIControlStateNormal];
    [cancelButton setTitle:@"Close" forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor colorWithRed:1.0 green:0 blue:0 alpha:0.5] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(didClose) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:cancelButton];
}
- (void) addValueLabelView {
    valLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    valLabel.backgroundColor = [UIColor grayColor];
    valLabel.textColor = [UIColor whiteColor];
    valLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:valLabel];
}

- (void) addKeyboardView {
    keyboardView = [[KeyboardView alloc] init];
    keyboardView.delegate = self;
    [keyboardView setEnabledMinusButton:![self.valControl isOnlyPositive]];
    [keyboardView setEnabledPointButton:![self.valControl isOnlyInteger]];
    
    [self.view addSubview:keyboardView];
}

/* -------------------------------- Set value -------------------------------------*/
- (void) setValControl:(NumValueControl *)valControl {
    _valControl = valControl;
    
    valLabel.text = [_valControl getStringValue];
    minusButton.enabled = ![self.valControl isOnlyPositive];
    pointButton.enabled = ![self.valControl isOnlyInteger];
    
    
    NSRange range = [valLabel.text rangeOfString:@"."];
    if (range.length == 0) {
        pointPosition = -1;
    } else {
        pointPosition = (int)range.location;
    }
    /*if ((_valControl.type == NumberTypePositiveFloat) || (_valControl.type == NumberTypeFloat) ) {
        pointPosition = (int)valLabel.text.length - 2;
    }
    if ((_valControl.type == NumberTypePositiveDouble) || (_valControl.type == NumberTypeDouble) ) {
        pointPosition = (int)valLabel.text.length - 3;
    }*/
}

/* -------------------------------- Actions -------------------------------------*/
- (void) didClose {
    if (self.delegate) {
        [self.delegate didKeyboardClose];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) didEnter {
    if (self.delegate) {
        NSLog(@"%@", valLabel.text);
        double a = [valLabel.text doubleValue];
        _valControl.numValue = a;
        [self.delegate didKeyboardEnter:_valControl];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) addChar:(KeyboardButton *)btn {
    NSString * valStr = btn.titleLabel.text;
    
    if ([valStr isEqualToString:@"-"]) {
        if (valLabel.text.length == 0) {
            valLabel.text = @"-";
        }
    } else if ([valStr isEqualToString:@"."]) {
        if ( (pointPosition == -1) && ([self isLastCharIsNumber]) ){
            valLabel.text = [valLabel.text stringByAppendingString:@"."];
            pointPosition = (int)valLabel.text.length - 1;
        }
    } else { // 0..9
        
        if ([self getPermissionForAddChar]) {
            valLabel.text = [valLabel.text stringByAppendingString:valStr];
        }
    }
    
    //[btn.titleLabel.text intValue];

    NSLog(@"%@", btn.titleLabel.text);
}

- (void)didBackspace {
    if (valLabel.text.length != 0) {
        NSString * lastChar = [valLabel.text substringFromIndex:(valLabel.text.length - 1)];
        if ([lastChar isEqualToString:@"."]) {
            pointPosition = -1;
        }
        valLabel.text = [valLabel.text substringToIndex:(valLabel.text.length - 1)];
    }
}

/* -------------------------------- Utility -------------------------------------*/
- (BOOL) isLastCharIsNumber {
    if (valLabel.text.length > 0) {
        NSString * c = [valLabel.text substringFromIndex:valLabel.text.length - 1];
        if ( (![c isEqualToString:@"-"]) && (![c isEqualToString:@"."]) ) {
            return YES;
        }
    }
    return NO;
}

- (BOOL) getPermissionForAddChar {
    if (valLabel.text.length > 8) return NO;
    if (pointPosition == -1) return YES;
    
    int numAfterPoint = 2;
    switch (_valControl.type) {
        case NumberTypePositiveFloat:
        case NumberTypeFloat:
            numAfterPoint = 1;
            break;
        case NumberTypePositiveDouble:
        case NumberTypeDouble:
            numAfterPoint = 2;
            break;
        default:
            return YES;
    }
    
    
    if (valLabel.text.length - pointPosition <= numAfterPoint) {
        
        return YES;
    }
    return NO;
}

@end
