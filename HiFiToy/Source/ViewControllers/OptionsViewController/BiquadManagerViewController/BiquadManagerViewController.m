//
//  BiquadManagerViewController.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 02/07/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "BiquadManagerViewController.h"

@implementation BiquadManagerViewController

/*-----------------------------------------------------------------------------------------
 ViewController Orientation Methods
 -----------------------------------------------------------------------------------------*/
- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self setupOutlets];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self setupOutlets];
}

- (NSString *) orderToString:(BiquadLength_t)biquadLength
{
    if (biquadLength == BIQUAD_LENGTH_4) {
        return @"8-order (4-biquads)";
    } else if (biquadLength == BIQUAD_LENGTH_2) {
        return @"4-order (2-biquads)";
    } else if (biquadLength == BIQUAD_LENGTH_1) {
        return @"2-order (1-biquad)";
    }
    
    return @"Off (0-biquads)";
}

- (void) setupOutlets
{
    //hp
    BiquadLength_t hpBiquadLength = (self.xover.hp) ? self.xover.hp.biquadLength : BIQUAD_LENGTH_0;
    self.hpBiquadLabel_outl.text = [self orderToString:hpBiquadLength];
    
    //lp
    BiquadLength_t lpBiquadLength = (self.xover.lp) ? self.xover.lp.biquadLength : BIQUAD_LENGTH_0;
    self.lpBiquadLabel_outl.text = [self orderToString:lpBiquadLength];
    
    //parametrics
    int paramBiquadLength = (self.xover.params) ? self.xover.params.count : 0;
    NSString * bStr = (paramBiquadLength != 1) ? @"biquads" : @"biquad";
    
    self.paramBiquadLabel_outl.text = [NSString stringWithFormat:@"%d-%@", paramBiquadLength, bStr];
}

/*-----------------------------------------------------------------------------------------
 Table Row select method
 -----------------------------------------------------------------------------------------*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section == 0){
        if (indexPath.row == 0){//hp
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"", @"")
                                                                                     message:NSLocalizedString(@"Please choose HP type", @"")
                                                                              preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:nil];
            
            UIAlertAction *offAction = [UIAlertAction actionWithTitle:@"Off"
                                                                        style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                                          [self setHp:BIQUAD_LENGTH_0];
                                                                          [self setupOutlets];
                                                                      }];
            UIAlertAction *secondOrderAction = [UIAlertAction actionWithTitle:@"2-order (1-biquad)"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 [self setHp:BIQUAD_LENGTH_1];
                                                                 [self setupOutlets];
                                                             }];
            UIAlertAction *fourthOrderAction = [UIAlertAction actionWithTitle:@"4-order (2-biquads)"
                                                               style:UIAlertActionStyleDefault
                                                             handler:^(UIAlertAction * _Nonnull action) {
                                                                 [self setHp:BIQUAD_LENGTH_2];
                                                                 [self setupOutlets];
                                                             }];
            
            [alertController addAction:cancelAction];
            [alertController addAction:offAction];
            [alertController addAction:secondOrderAction];
            [alertController addAction:fourthOrderAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
        
        if (indexPath.row == 1){//change pairing code
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"", @"")
                                                                                     message:NSLocalizedString(@"Please choose LP type", @"")
                                                                              preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:nil];
            
            UIAlertAction *offAction = [UIAlertAction actionWithTitle:@"Off"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * _Nonnull action) {
                                                                  [self setLp:BIQUAD_LENGTH_0];
                                                                  [self setupOutlets];
                                                              }];
            UIAlertAction *secondOrderAction = [UIAlertAction actionWithTitle:@"2-order (1-biquad)"
                                                                        style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                                          [self setLp:BIQUAD_LENGTH_1];
                                                                          [self setupOutlets];
                                                                      }];
            UIAlertAction *fourthOrderAction = [UIAlertAction actionWithTitle:@"4-order (2-biquads)"
                                                                        style:UIAlertActionStyleDefault
                                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                                          [self setLp:BIQUAD_LENGTH_2];
                                                                          [self setupOutlets];
                                                                      }];
            
            [alertController addAction:cancelAction];
            [alertController addAction:offAction];
            [alertController addAction:secondOrderAction];
            [alertController addAction:fourthOrderAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }
    
    
}

- (void) setHp:(BiquadLength_t)biquadLength
{
    PassFilter2 * hp = nil;
    if ((biquadLength > BIQUAD_LENGTH_0) && (biquadLength < BIQUAD_LENGTH_4)) {
        hp = [PassFilter2 initWithAddress0:0 Address1:0
                                        BiquadLength:biquadLength Order:FILTER_ORDER_2 Type:BIQUAD_HIGHPASS Freq:60];
        
    }
    
    [self.xover setHp:hp];
}

- (void) setLp:(BiquadLength_t)biquadLength
{
    PassFilter2 * lp = nil;
    if ((biquadLength > BIQUAD_LENGTH_0) && (biquadLength < BIQUAD_LENGTH_4)) {
        lp = [PassFilter2 initWithAddress0:0 Address1:0
                              BiquadLength:biquadLength Order:FILTER_ORDER_2 Type:BIQUAD_LOWPASS Freq:10000];
        
    }
    
    [self.xover setLp:lp];
}

@end
