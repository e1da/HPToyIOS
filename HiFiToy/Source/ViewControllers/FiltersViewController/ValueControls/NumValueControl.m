//
//  NumValueControl.m
//  BlurOverlayTest
//
//  Created by Kerosinn_OSX on 02/10/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "NumValueControl.h"

@interface NumValueControl() {
    UIButton * prevButton;
    UIButton * nextButton;
    UIButton * valButton;
}

@end

@implementation NumValueControl

- (id) init {
    self = [super init];
    if (self) {
        [self setBackgroundColor:[UIColor darkGrayColor]];
        
        prevButton = [[UIButton alloc] init];
        [prevButton setTitle:@"\u2329" forState:UIControlStateNormal];
        
        [prevButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [prevButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
        [prevButton setBackgroundColor:[UIColor darkGrayColor]];
        [prevButton addTarget:self action:@selector(prev) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:prevButton];
        
        nextButton = [[UIButton alloc] init];
        [nextButton setTitle:@"\u232A" forState:UIControlStateNormal];
        [nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [nextButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateHighlighted];
        [nextButton setBackgroundColor:[UIColor darkGrayColor]];
        [nextButton addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:nextButton];
        
        valButton = [[UIButton alloc] init];
        //[valButton setTitle:@"0" forState:UIControlStateNormal];
        [valButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [valButton setBackgroundColor:[UIColor darkGrayColor]];
        [valButton addTarget:self action:@selector(valButtonPress) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:valButton];
        
        self.leftLabel = [[FilterLabel alloc] initWithText:@"Freq" withFontSize:14];
        self.leftLabel.textColor = [UIColor lightGrayColor];
        [self addSubview:self.leftLabel];
        self.rightLabel = [[FilterLabel alloc] initWithText:@"Hz" withFontSize:14];
        self.rightLabel.textColor = [UIColor lightGrayColor];
        [self addSubview:self.rightLabel];
    }
    return self;
    
}

+ (NumValueControl *) initWithType:(NumberType_t)type {
    NumValueControl * numControl = [[NumValueControl alloc] init];
    numControl.type = type;
    
    return numControl;
}

- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    
    CGFloat w = self.frame.size.width;
    
    self.leftLabel.frame = CGRectMake(  0, 0,           0.2 * w, self.frame.size.height);
    prevButton.frame = CGRectMake(      0.2 * w, 0,     0.1 * w, self.frame.size.height);
    valButton.frame = CGRectMake(       0.3 * w, 0,     0.4 * w, self.frame.size.height);
    nextButton.frame = CGRectMake(      0.7 * w, 0,     0.1 * w, self.frame.size.height);
    self.rightLabel.frame = CGRectMake( 0.8 * w, 0,     0.2 * w, self.frame.size.height);
    
}

- (void) setNumValue:(double)numValue {
    _numValue = numValue;
    
    if (([self isOnlyPositive]) && (self.numValue < 0)) {
        _numValue = 0;
    }
    [self updateValueView];
}

- (void) updateValueView {
    FilterLabel * f = [[FilterLabel alloc] initWithText:[self getStringValue] withFontSize:28];
    f.textColor = [UIColor orangeColor];
    [valButton setAttributedTitle:f.attributedText forState:UIControlStateNormal];
    
}

- (void) prev {
    if (_delegate) [_delegate didPressPrev:self];
    
    if (([self isOnlyPositive]) && (self.numValue < 0)) {
        _numValue = 0;
    }
    
    [self updateValueView];
}

- (void) next {
    if (_delegate) [_delegate didPressNext:self];
    
    [self updateValueView];
}

- (void) valButtonPress {
    if (_delegate) [_delegate didPressValue:self];
}

- (BOOL) isOnlyPositive {
    if ((_type == NumberTypeInteger) || (_type == NumberTypeFloat) || (_type == NumberTypeDouble)) {
        return NO;
    }
    return YES;
}

- (BOOL) isOnlyInteger {
    if ((_type == NumberTypePositiveInteger) || (_type ==  NumberTypeInteger)) {
        return YES;
    }
    return NO;
}

- (NSString *) getStringValue {
    
    switch (_type) {
            
        case NumberTypePositiveInteger:
        case NumberTypeInteger:
            return [NSString stringWithFormat:@"%d", (int)self.numValue ];

        case NumberTypePositiveFloat:
        case NumberTypeFloat:
            return [NSString stringWithFormat:@"%0.1f", self.numValue ];

        case NumberTypePositiveDouble:
        case NumberTypeDouble:
            return [NSString stringWithFormat:@"%0.2f", self.numValue ];
    }
    return nil;
}




@end
