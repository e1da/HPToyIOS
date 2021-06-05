//
//  MainViewController.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 07/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "MainViewController.h"
#import "DialogSystem.h"
#import "PresetViewController.h"
#import "OptionsViewController.h"
#import "FiltersViewController.h"

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
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setupOutlets)
                                                 name:@"SetupOutletsNotification"
                                               object:nil];
    
    hiFiToyControl = [HiFiToyControl sharedInstance];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    hiFiToyDevice = [[HiFiToyControl sharedInstance] activeHiFiToyDevice];
    
    [self setupOutlets];
}

- (void) setupOutlets {
    HiFiToyPreset * p = hiFiToyDevice.preset;
    
    _audioSourceSegment_outl.selectedSegmentIndex = hiFiToyDevice.audioSource;
    self.gainLabel_outl.text = [p.masterVolume getInfo];
    self.gainSlider_outl.value = [p.masterVolume getDbPercent];
    
    self.bassLabel_outl.text = [NSString stringWithFormat:@"%ddB", p.bassTreble.bassTreble127.bassDb];
    self.bassSlider_outl.value = [p.bassTreble.bassTreble127 getBassDbPercent];
    
    self.trebleLabel_outl.text = [NSString stringWithFormat:@"%ddB", p.bassTreble.bassTreble127.trebleDb];
    self.trebleSlider_outl.value = [p.bassTreble.bassTreble127 getTrebleDbPercent];
    
    self.loudnessGainLabel_outl.text = [p.loudness getInfo];
    self.loudnessGainSlider_outl.value = p.loudness.gain / 2;
    self.loudnessLabel_outl.text = [p.loudness getFreqInfo];
    self.loudnessSlider_outl.value = [p.loudness.biquad.biquadParam getFreqPercent];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    NSString *targetName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"TargetName"];
    int index = ([targetName isEqualToString:@"HiFiToy"]) ? (int)section : (int)section + 1;
    
    NSString * tittleSection;
    BOOL buttonVisibleFlag = NO;
    
    switch (index){
        case 0:
            tittleSection = @"AUDIO SOURCE";
            buttonVisibleFlag = YES;
            break;
        case 1:
            tittleSection = @"VOLUME CONTROL";
            break;
        case 2:
            tittleSection = @"BASS TREBLE CONTROL";
            buttonVisibleFlag = YES;
            break;
        case 3:
            tittleSection = @"LOUDNESS CONTROL";
            buttonVisibleFlag = YES;
            break;
        case 4:
            tittleSection = @"FILTERS CONTROL";
            buttonVisibleFlag = YES;
            break;
        case 5:
            tittleSection = @"COMPRESSOR CONTROL";
            buttonVisibleFlag = YES;
            break;
        case 6:
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
    NSString *targetName = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"TargetName"];
    int index = ([targetName isEqualToString:@"HiFiToy"]) ? (int)button.tag : (int)button.tag + 1;
    
    NSString * msgString = nil;
 
    switch (index) {
        case 0: //AUDIO SOURCE
            msgString = @"If the USB input selected, the amp is ready for 16-24/44.1-192 USB high-res audio, and after USB-host is off, it will be auto-switched to standby. If selected AUTO, after USB-host is off, the amp will be auto-switched to AUX input. AUX input could be either optical SPDIF or BT aptx stream, depends on which option is installed. After 5 minutes AUX input level less than Auto-Off threshold, the amp goes to standby. The wakeup event could be smartphone app connecting or USB-host On.";
            break;
        case 1: //VOLUME
            msgString = @"Volume info";
            break;
        case 2: //BASS TREBLE
            msgString = @"Classical HiFi knobs implemented with shelving filters";
            break;
        case 3: //LOUDNESS
            msgString = @"Fletcher-Munson loudness curves are implemented. You can control the Loudness boost frequency and Dry/Wet slider position defines less/more effect.";
            break;
        case 4: //FILTERS
            msgString = @"Filters let you fully control up to 7 Biquads: Parametric EQs, All-pass Filters, Text biquad mode, LPF and HPF, both are Butterworth 2 or 4 order. PEQ On/Off button bypassing PEQ's and All-pass Filters.";
            break;
        case 5: //DRC
            msgString = @"Flexible Compressor/Expander dynamic range control. Required some basic understanding to modify parameters successfully.";
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
    if ([[segue identifier] isEqualToString:@"showPresetManager"]) {
        PresetViewController *destination = (PresetViewController * )segue.destinationViewController;
        destination.hiFiToyDevice = hiFiToyDevice;
        
    }
    
    if ([[segue identifier] isEqualToString:@"showOptionsMenu"]) {
        OptionsViewController *destination = (OptionsViewController * )segue.destinationViewController;
        destination.hiFiToyDevice = hiFiToyDevice;
    }
    
    if ([[segue identifier] isEqualToString:@"showNewFilters"]) {
        FiltersViewController *dest = (FiltersViewController * )segue.destinationViewController;
        dest.filters = hiFiToyDevice.preset.filters;
    }
}

/*-----------------------------------------------------------------------------------------
 Events from outlet
 -----------------------------------------------------------------------------------------*/
- (IBAction)changeAudioSource:(id)sender {
    hiFiToyDevice.audioSource = self.audioSourceSegment_outl.selectedSegmentIndex;
    [hiFiToyDevice sendAudioSource];
}

- (IBAction)setGainSlider:(id)sender
{
    [hiFiToyDevice.preset.masterVolume setDbPercent:self.gainSlider_outl.value];
    self.gainLabel_outl.text = [hiFiToyDevice.preset.masterVolume getInfo];
    
    [hiFiToyDevice.preset.masterVolume sendWithResponse:NO];
}

- (IBAction)setBassSlider:(id)sender
{
    [hiFiToyDevice.preset.bassTreble.bassTreble127 setBassDbPercent:self.bassSlider_outl.value];
    self.bassLabel_outl.text = [NSString stringWithFormat:@"%ddB", hiFiToyDevice.preset.bassTreble.bassTreble127.bassDb];
    
    [hiFiToyDevice.preset.bassTreble sendWithResponse:NO];
}

- (IBAction)setTrebleSlider:(id)sender
{
    [hiFiToyDevice.preset.bassTreble.bassTreble127 setTrebleDbPercent:self.trebleSlider_outl.value];
    self.trebleLabel_outl.text = [NSString stringWithFormat:@"%ddB", hiFiToyDevice.preset.bassTreble.bassTreble127.trebleDb];
    
    [hiFiToyDevice.preset.bassTreble sendWithResponse:NO];
}

- (IBAction)setLoudnessGainSlider:(id)sender
{
    hiFiToyDevice.preset.loudness.gain = self.loudnessGainSlider_outl.value * 2;
    self.loudnessGainLabel_outl.text = [hiFiToyDevice.preset.loudness getInfo];
    
    [hiFiToyDevice.preset.loudness sendWithResponse:NO];
}

- (IBAction)setLoudnessSlider:(id)sender
{
    BiquadParam * p = hiFiToyDevice.preset.loudness.biquad.biquadParam;
    [p setFreqPercent:self.loudnessSlider_outl.value];
    
    //round
    p.freq = [self freqRound:p.freq];
    
    self.loudnessLabel_outl.text = [hiFiToyDevice.preset.loudness getFreqInfo];
    [hiFiToyDevice.preset.loudness.biquad sendWithResponse:NO];
}


-(int) freqRound:(int)freq {
    if (freq > 1000) {
        return freq / 100 * 100;
    } else if (freq > 100) {
        return freq / 10 * 10;
    }
    return freq;
}

- (IBAction)savePreset:(id)sender {
    //update checksum
    [hiFiToyDevice.preset updateChecksum];
    
    //get preset name from user and save to preset list
    [[DialogSystem sharedInstance] showSavePresetDialog:hiFiToyDevice.preset okHandler:^{
        //preset with new name saved to list and next
        //set key ref to new preset name
        self->hiFiToyDevice.activeKeyPreset = self->hiFiToyDevice.preset.presetName;
        [[HiFiToyDeviceList sharedInstance] saveDeviceListToFile];
        
        [self->hiFiToyDevice.preset storeToPeripheral];
    }];
}
@end
