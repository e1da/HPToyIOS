//
//  MainViewController.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 07/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "MainViewController.h"
#import "DialogSystem.h"

@implementation MainViewController

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


- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /*[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didGetPresetImportNotification:)
                                                 name:@"PresetImportNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didGetPresetImportFailNotification:)
                                                 name:@"PresetImportFailNotification"
                                               object:nil];*/
    
    hiFiToyControl = [HiFiToyControl sharedInstance];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    hiFiToyDevice = [[HiFiToyDeviceList sharedInstance] getActiveDevice];
    hiFiToyPreset = [hiFiToyDevice getActivePreset];
    
    [self setupOutlets];
}

- (void) setupOutlets{
    self.gainLabel_outl.text = [hiFiToyPreset.masterVolume getInfo];
    self.gainSlider_outl.value = [hiFiToyPreset.masterVolume getDbPercent];
    
    self.bassLabel_outl.text = [NSString stringWithFormat:@"%ddB", hiFiToyPreset.bassTreble.bassTreble127.bassDb];
    self.bassSlider_outl.value = [hiFiToyPreset.bassTreble.bassTreble127 getBassDbPercent];
    
    self.trebleLabel_outl.text = [NSString stringWithFormat:@"%ddB", hiFiToyPreset.bassTreble.bassTreble127.trebleDb];
    self.trebleSlider_outl.value = [hiFiToyPreset.bassTreble.bassTreble127 getTrebleDbPercent];
    
    self.loudnessLabel_outl.text = [hiFiToyPreset.loudness getInfo];
    self.loudnessSlider_outl.value = [hiFiToyPreset.loudness.biquad getFreqPercent];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSString * tittleSection;
    BOOL buttonVisibleFlag = NO;
    
    switch (section){
        case 0:
            tittleSection = @"XOVER CONTROL";
            buttonVisibleFlag = YES;
            break;
        case 1:
            break;
        case 2:
            tittleSection = @"GAIN CONTROL";
            break;
        case 3:
            tittleSection = @"BASS TREBLE CONTROL";
            buttonVisibleFlag = YES;
            break;
        case 4:
            tittleSection = @"LOUDNESS CONTROL";
            buttonVisibleFlag = YES;
            break;
        case 5:
            tittleSection = @"DRC CONTROL";
            buttonVisibleFlag = YES;
            break;
    }
    
    CGRect frame = tableView.frame;
    
    //create Button
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    addButton.frame = (section) ? CGRectMake(20, 10, 20, 20) : CGRectMake(20, 30, 20, 20);
    addButton.tintColor = [UIColor brownColor];
    
    addButton.tag = section;
    [addButton addTarget:self action:@selector(infoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    //create Label
    UILabel *title = [[UILabel alloc] init];
    title.frame = (section) ? CGRectMake(50, 10, 250, 20) : CGRectMake(50, 30, 250, 20);
    
    title.font = [UIFont fontWithName:@"Helvetica" size:13];
    title.textColor = [UIColor grayColor];
    title.text = tittleSection;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [headerView addSubview:title];
    if (buttonVisibleFlag) [headerView addSubview:addButton];
    
    return headerView;
}

- (void) infoButtonClick:(UIButton *)button
{
    NSString * msgString = nil;
 
    switch (button.tag) {
        case 0://XOVER
            msgString = @"Xover let you fully control up to 7 Biquads: Parametric EQs, LPF and HPF, both are Butterworth 2 or 4 order. PEQ On/Off button bypassing PEQ's";
            break;
        case 2://GAIN
            msgString = @"Gain info";
            break;
        case 3://BASS TREBLE
            msgString = @"Bass and Treble info";
            break;
        case 4://LOUDNESS
            msgString = @"Loudness info";
            break;
        case 5://DRC
            msgString = @"Drc info";
            break;
        default:
            break;
    }

    
    if (msgString) [[DialogSystem sharedInstance] showAlert:msgString];
    
}

/*-----------------------------------------------------------------------------------------
 Prepare for segue
 -----------------------------------------------------------------------------------------*/
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    /*if ([[segue identifier] isEqualToString:@"showPresetManager"]) {
        PresetTableViewController *destination = (PresetTableViewController * )segue.destinationViewController;
        destination.dspDevice = self.dspDevice;
        
    }
    
    if ([[segue identifier] isEqualToString:@"showCommonFunctionMenu"]) {
        ThomasCommonFunctionViewController *destination = (ThomasCommonFunctionViewController * )segue.destinationViewController;
        destination.dspDevice = self.dspDevice;
    }
    
    if ([[segue identifier] isEqualToString:@"showXOverMenu"]) {
        XOverViewController *dest = (XOverViewController * )segue.destinationViewController;
        
        dest.xOverView.maxFreq = 500;
        dest.xOverView.minFreq = 20;
        
        if (!dest.dspElements){
            dest.dspElements  = [[NSMutableDictionary alloc] init];
        }
        [dest.dspElements removeAllObjects];
        
        dspPreset = [self.dspDevice getActivePreset];
        
        [dest.dspElements setObject:dspPreset.SubHPFilter forKey:@"HP"];
        [dest.dspElements setObject:dspPreset.SubLPFilter forKey:@"LP"];
        
        for (int i = 0; i < [dspPreset.SubParam count]; i++){
            NSString * keyString = [NSString stringWithFormat:@"EQ#%d", i + 1];
            [dest.dspElements setObject:[dspPreset.SubParam biquadAtIndex:i] forKey:keyString];
        }
        
    }*/
    
    
}

/*-----------------------------------------------------------------------------------------
 Events from outlet
 -----------------------------------------------------------------------------------------*/
- (IBAction)setGainSlider:(id)sender
{
    [hiFiToyPreset.masterVolume setDbPercent:self.gainSlider_outl.value];
    self.gainLabel_outl.text = [hiFiToyPreset.masterVolume getInfo];
    
    [hiFiToyPreset.masterVolume sendWithResponse:NO];
}

- (IBAction)setBassSlider:(id)sender
{
    [hiFiToyPreset.bassTreble.bassTreble127 setBassDbPercent:self.bassSlider_outl.value];
    self.bassLabel_outl.text = [NSString stringWithFormat:@"%ddB", hiFiToyPreset.bassTreble.bassTreble127.bassDb];
    
    [hiFiToyPreset.bassTreble sendWithResponse:NO];
}

- (IBAction)setTrebleSlider:(id)sender
{
    [hiFiToyPreset.bassTreble.bassTreble127 setTrebleDbPercent:self.trebleSlider_outl.value];
    self.trebleLabel_outl.text = [NSString stringWithFormat:@"%ddB", hiFiToyPreset.bassTreble.bassTreble127.trebleDb];
    
    [hiFiToyPreset.bassTreble sendWithResponse:NO];
}

- (IBAction)setLoudnessSlider:(id)sender
{
    [hiFiToyPreset.loudness.biquad setFreqPercent:self.loudnessSlider_outl.value];
    //round
    int freq = hiFiToyPreset.loudness.biquad.freq;
    [self freqRound:&freq];
    hiFiToyPreset.loudness.biquad.freq = freq;
    
    self.loudnessLabel_outl.text = [hiFiToyPreset.loudness getInfo];
    
    [hiFiToyPreset.loudness.biquad sendWithResponse:NO];
}


-(void) freqRound:(int *)freq {
    if (*freq > 1000){
        *freq = *freq / 100 * 100;
    } else if (*freq > 100){
        *freq = *freq / 10 * 10;
    }
}

@end
