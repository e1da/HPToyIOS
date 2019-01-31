//
//  DrcTimeConstViewController.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 23/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "DrcTimeConstViewController.h"
#import "HiFiToyControl.h"

@implementation DrcTimeConstViewController

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor darkGrayColor];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    HiFiToyPreset * preset = [[[HiFiToyControl sharedInstance] activeHiFiToyDevice] getActivePreset];
    drc = preset.drc;
    
    [self setupOutlets];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor darkGrayColor];
}

- (void) setupOutlets{
    self.energyLabel_outl.text = [NSString stringWithFormat:@"%0.1fms", drc.timeConst17.energyMS];
    self.energySlider_outl.value = (drc.timeConst17.energyMS - 0.1) / (50 - 0.1);
    
    self.attackLabel_outl.text = [NSString stringWithFormat:@"%dms", (int)drc.timeConst17.attackMS];
    self.attackSlider_outl.value = [self getPercent:drc.timeConst17.attackMS MaxVal:200 MinVal:1];//(drc.timeConst17.attackMS - 1) / (200 - 1);
    
    self.decayLabel_outl.text = [NSString stringWithFormat:@"%dms", (int)drc.timeConst17.decayMS];
    self.decaySlider_outl.value = [self getPercent:drc.timeConst17.decayMS MaxVal:10000 MinVal:10];
}

- (IBAction)setEnergySlider:(id)sender
{
    float energy = self.energySlider_outl.value * (50 - 0.1) + 0.1;
    drc.timeConst17.energyMS = [self round01:energy];
    self.energyLabel_outl.text = [NSString stringWithFormat:@"%0.1fms", drc.timeConst17.energyMS];
    
    [drc.timeConst17 sendEnergyWithResponse:NO];
}

- (IBAction)setAttackSlider:(id)sender
{
    float attack = [self setPercent:self.attackSlider_outl.value MaxVal:200 MinVal:1];//self.attackSlider_outl.value * (200 - 1) + 1;
    drc.timeConst17.attackMS = [self round1:attack];;
    self.attackLabel_outl.text = [NSString stringWithFormat:@"%dms", (int)drc.timeConst17.attackMS];
    
    [drc.timeConst17 sendAttackDecayWithResponse:NO];
}

- (IBAction)setDecaySlider:(id)sender
{
    float decay = [self setPercent:self.decaySlider_outl.value MaxVal:10000 MinVal:10];//self.decaySlider_outl.value * (10000 - 10) + 10;
    drc.timeConst17.decayMS = [self round10:decay];
    self.decayLabel_outl.text = [NSString stringWithFormat:@"%dms", (int)drc.timeConst17.decayMS];
    
    [drc.timeConst17 sendAttackDecayWithResponse:NO];
}

- (float) getPercent:(float)val MaxVal:(float)maxVal MinVal:(float)minVal
{
    return (log10(val) - log10(minVal)) / (log10(maxVal) - log10(minVal));
}

- (float) setPercent:(float)percent MaxVal:(float)maxVal MinVal:(float)minVal
{
    return pow(10, percent * (log10(maxVal) - log10(minVal)) + log10(minVal));
    
}
- (float) round01:(float)n
{
    return (int)(n / 0.1) * 0.1;
}

- (float) round1:(float)n
{
    return (int)n;
}

- (float) round10:(float)n
{
    return (int)(n / 10) * 10;
}
@end
