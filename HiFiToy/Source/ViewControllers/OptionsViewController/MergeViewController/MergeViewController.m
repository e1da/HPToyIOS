//
//  MergeViewController.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 13/02/2019.
//  Copyright © 2019 Kerosinn_OSX. All rights reserved.
//

#import "MergeViewController.h"
#import "HiFiToyPresetList.h"
#import "BaseCell.h"
#import "MergeNavigationViewCell.h"

typedef enum {
    VOLUME_STATE, BASS_TREBLE_STATE, LOUDNESS_STATE, FILTERS_STATE, COMPRESSOR_STATE
} MergesState_t;

@interface MergeViewController () {
    HiFiToyPresetList * presetList;
    
    MergesState_t state;
    
    MergeNavigationViewCell * navCell;
    
    HiFiToyPreset * volumeSource;
    HiFiToyPreset * bassTrebleSource;
    HiFiToyPreset * loudnessSource;
    HiFiToyPreset * filtersSource;
    HiFiToyPreset * compressorSource;
}

@end

@implementation MergeViewController

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    presetList = [HiFiToyPresetList sharedInstance];
    [self resetMergeTool];
}

- (void) viewWillAppear:(BOOL)animated {
    navCell = [self.tableView dequeueReusableCellWithIdentifier:@"NavigationCell"];
    if (navCell == nil) {
        navCell = [[MergeNavigationViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NavigationCell"];
    }
    [navCell.prevButton_outl addTarget:self action:@selector(prevState) forControlEvents:UIControlEventTouchUpInside];
    [navCell.nextButton_outl addTarget:self action:@selector(nextState) forControlEvents:UIControlEventTouchUpInside];
    
    [super viewWillAppear:animated];
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    }
    return [presetList count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 50;
    }
    return 40;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString * tittleSection;
    
    switch (section){
        case 0:
            tittleSection = @"PRESET ELEMENT";
            break;
        case 1:
            tittleSection = @"PLEASE CHOOSE SOURCE PRESET";
            break;
        default:
            tittleSection = @"err";
    }
    
    CGRect frame = tableView.frame;
    //create Label
    UILabel *title = [[UILabel alloc] init];
    title.frame = (section) ? CGRectMake(20, 15, frame.size.width - 40, 20) : CGRectMake(20, 25, frame.size.width - 40, 20);
    
    title.font = [UIFont fontWithName:@"Helvetica" size:13];
    title.textColor = [UIColor grayColor];
    title.text = tittleSection;
    title.textAlignment = NSTextAlignmentCenter;
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    [headerView addSubview:title];
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell * cell = nil;
    
    if (indexPath.section == 0) {
        navCell.itemLabel_outl.text = [self getStateString];
        if (state == COMPRESSOR_STATE) {
            [navCell.nextButton_outl setTitle:@"Merge" forState:UIControlStateNormal];
        } else {
            [navCell.nextButton_outl setTitle:@"Next" forState:UIControlStateNormal];
        }
        
        if (state == VOLUME_STATE) {
            [navCell.prevButton_outl setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        } else {
            [navCell.prevButton_outl setTitleColor:[UIColor colorWithRed:31.0/255 green:135.0/255 blue:255.0/255 alpha:1.0]
                                          forState:UIControlStateNormal];
        }
        
        if ([self getPresetForState]) {
            [navCell.nextButton_outl setTitleColor:[UIColor colorWithRed:31.0/255 green:135.0/255 blue:255.0/255 alpha:1.0]
                                          forState:UIControlStateNormal];
        } else {
            [navCell.nextButton_outl setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
        
        cell = navCell;
        
    } else if (indexPath.section == 1) {
        BaseCell * baseCell = [tableView dequeueReusableCellWithIdentifier:@"BaseCell"];
        if (baseCell == nil) {
            baseCell = [[BaseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"BaseCell"];
        }
        
        if (indexPath.row < [presetList count]){
            HiFiToyPreset * preset = [presetList presetWithIndex:indexPath.row];
            baseCell.label_outl.text = NSLocalizedString(preset.presetName, @"");
            
            HiFiToyPreset * cmpPreset = [self getPresetForState];
            
            if ( (cmpPreset) && (preset.presetName == cmpPreset.presetName) ) {
                baseCell.accessoryType = UITableViewCellAccessoryCheckmark;
            } else {
                baseCell.accessoryType = UITableViewCellAccessoryNone;
            }
            
        } else {
            baseCell.label_outl.text = @"err";
        }
        
        cell = baseCell;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        HiFiToyPreset * preset = [presetList presetWithIndex:indexPath.row];
        
        switch (state) {
            case VOLUME_STATE:
                volumeSource = preset;
                break;
            case BASS_TREBLE_STATE:
                bassTrebleSource = preset;
                break;
            case LOUDNESS_STATE:
                loudnessSource = preset;
                break;
            case FILTERS_STATE:
                filtersSource = preset;
                break;
            case COMPRESSOR_STATE:
                compressorSource = preset;
        }
        
        [self.tableView reloadData];
    }
}



- (IBAction)reset:(id)sender {
    [self resetMergeTool];
    [self.tableView reloadData];
}

- (void) resetMergeTool {
    state = VOLUME_STATE;
    
    volumeSource = nil;
    bassTrebleSource = nil;
    loudnessSource = nil;
    filtersSource = nil;
    compressorSource = nil;
    
}

- (void) nextState {
    HiFiToyPreset * p = [self getPresetForState];
    
    if (p) {
        if (state < COMPRESSOR_STATE) {
            state++;
        } else if (state == COMPRESSOR_STATE) {
            HiFiToyPreset * mergePreset = [self merge];
            if (mergePreset) {
                mergePreset.presetName = [[NSDate date] descriptionWithLocale:[NSLocale systemLocale]];
                [self showInputNameDialog:mergePreset renameFlag:NO];
            } else {
                [self resetMergeTool];
            }
        }
    }
    
    [self.tableView reloadData];
}

- (void) prevState {
    if (state > VOLUME_STATE) state--;
    
    [self.tableView reloadData];
}

- (HiFiToyPreset *) merge {
    if ( (!volumeSource) || (!bassTrebleSource) || (!loudnessSource) ||
        (!filtersSource) || (!compressorSource) ) return nil;
    
    HiFiToyPreset * mergePreset = [[HiFiToyPreset alloc] init];
    mergePreset.masterVolume = [volumeSource.masterVolume copy];
    mergePreset.bassTreble = [bassTrebleSource.bassTreble copy];
    mergePreset.loudness = loudnessSource.loudness;
    mergePreset.filters = [filtersSource.filters copy];
    mergePreset.drc = [compressorSource.drc copy];
    [mergePreset initCharacteristicsPointer];
    [mergePreset updateChecksum];
    
    return mergePreset;
}

- (HiFiToyPreset *) getPresetForState {
    HiFiToyPreset * p = nil;
    switch (state) {
        case VOLUME_STATE:
            p = volumeSource;
            break;
        case BASS_TREBLE_STATE:
            p = bassTrebleSource;
            break;
        case LOUDNESS_STATE:
            p = loudnessSource;
            break;
        case FILTERS_STATE:
            p = filtersSource;
            break;
        case COMPRESSOR_STATE:
            p = compressorSource;
            break;
        default:
            p = nil;
    }
    
    return p;
}


- (NSString *) getStateString {
    switch (state) {
        case VOLUME_STATE:
            return @"Volume";
        case BASS_TREBLE_STATE:
            return @"Bass&Treble";
        case LOUDNESS_STATE:
            return @"Loudness";
        case FILTERS_STATE:
            return @"Filters";
        case COMPRESSOR_STATE:
            return @"Compressor";
        default:
            return @"err";
    }
    return @"err";
}

- (void) showInputNameDialog:(HiFiToyPreset *) mergePreset renameFlag:(BOOL)renameFlag {
    NSString * s;
    
    if (renameFlag) {
        s = [NSString stringWithFormat:@"Preset with name \"%@\" already exists. Please input another name.", mergePreset.presetName ];
    } else {
        s = @"Please input name for merge preset.";
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@""
                                                                             message:s
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = mergePreset.presetName;
    }];

    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleDestructive
                                                         handler:nil];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         UITextField *name = alertController.textFields.firstObject;
                                                         mergePreset.presetName = (![name.text isEqualToString:@""]) ? name.text : @" ";
                                                         
                                                         if ([[HiFiToyPresetList sharedInstance] isPresetExist:name.text] == NO) {
                                                             [[HiFiToyPresetList sharedInstance] setPreset:mergePreset];
                                                             
                                                             [self.navigationController popViewControllerAnimated:YES];
                                                         } else {
                                                             [self showInputNameDialog:mergePreset renameFlag:YES];
                                                         }
                                                     }];

    [alertController addAction:cancelAction];
    [alertController addAction:okAction];

    [self presentViewController:alertController animated:YES completion:nil];
}


@end
