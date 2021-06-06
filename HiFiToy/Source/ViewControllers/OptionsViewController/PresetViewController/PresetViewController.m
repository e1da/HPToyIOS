//
//  PresetViewController.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 08/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "PresetViewController.h"
#import "PresetDetailViewController.h"
#import "HiFiToyControl.h"
#import "PresetCell.h"
#import "MergeToolCell.h"
#import "DialogSystem.h"

@implementation PresetViewController

/*-----------------------------------------------------------------------------------------
 ViewController Orientation Methods
 -----------------------------------------------------------------------------------------*/
- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}


- (void)awakeFromNib {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    hiFiToyPresetList = [HiFiToyPresetList sharedInstance];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(setupOutlets)
                                                 name: @"SetupOutletsNotification"
                                               object: nil];
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewWillAppear:(BOOL)animated {
    [self setupOutlets];
}

- (void) setupOutlets {
    [self.tableView reloadData];
}

/*-----------------------------------------------------------------------------------------
 UITableViewDataSource protocol
 -----------------------------------------------------------------------------------------*/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) { // for preset list
        return [hiFiToyPresetList count];
    } else if (section == 1) {
        return 2;
    }
    return 1; // for merge tool and preset repository menu
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"LOCAL PRESET LIST";
    } else if (section == 1) {
        return @"IMPORT PRESET";
    }
    return @"";
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) { // preset list
        PresetCell * presetCell = [tableView dequeueReusableCellWithIdentifier:@"PresetCell"];
        if (presetCell == nil) {
            presetCell = [[PresetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PresetCell"];
        }
    
        if (indexPath.row < [hiFiToyPresetList count]){
            HiFiToyPreset * p = [hiFiToyPresetList presetWithIndex:indexPath.row];
            //NSString *keyPreset = [[hiFiToyPresetList getKeys] objectAtIndex:indexPath.row];
        
            presetCell.presetLabel_outl.text = NSLocalizedString(p.presetName, @"");
            presetCell.presetDetailButton_outl.tag = indexPath.row;

            
            //set color
            if ([p.presetName isEqualToString:self.hiFiToyDevice.activeKeyPreset]){
                if (@available(iOS 13.0, *)) {
                    presetCell.presetLabel_outl.textColor = [UIColor labelColor];
                } else {
                    presetCell.presetLabel_outl.textColor = [UIColor blackColor];
                }
                
            } else {
                presetCell.presetLabel_outl.textColor = [UIColor grayColor];
            }
        } else {
            presetCell.presetLabel_outl.text = @"err";
        }
        
        return presetCell;
        
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) { // url import
            UITableViewCell * urlImportPresetCell = [tableView dequeueReusableCellWithIdentifier:@"UrlPresetImportCell"];
            if (urlImportPresetCell == nil) {
                urlImportPresetCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UrlPresetImportCell"];
            }
            return urlImportPresetCell;
        } else if (indexPath.row == 1) { // text import
            UITableViewCell * textImportPresetCell = [tableView dequeueReusableCellWithIdentifier:@"TextImportPresetCell"];
            if (textImportPresetCell == nil) {
                textImportPresetCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TextImportPresetCell"];
            }
            return textImportPresetCell;
            
        }
    } else if (indexPath.section == 2) { // merge tool
        MergeToolCell * mergeCell = [tableView dequeueReusableCellWithIdentifier:@"MergeToolCell"];
        if (mergeCell == nil) {
            mergeCell = [[MergeToolCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MergeToolCell"];
        }
        
        return mergeCell;
        
    }
    
    return nil;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        // Detemine if it's in editing mode
        NSString * name = [[hiFiToyPresetList presetWithIndex:indexPath.row] presetName];
        
        if ( (![name isEqualToString:@"No processing"]) && (![name isEqualToString:self.hiFiToyDevice.activeKeyPreset]) ){
            return UITableViewCellEditingStyleDelete;
        }
    }
    
    return UITableViewCellEditingStyleNone;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// call when delete preset
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        NSString * name = [[hiFiToyPresetList presetWithIndex:indexPath.row] presetName];
        
        if ([name isEqualToString:self.hiFiToyDevice.activeKeyPreset]){//if remove preset is active
            return;
        }
        //delete preset from list
        [hiFiToyPresetList removePresetWithName:name];
        
        [self.tableView reloadData];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) { //load preset
        HiFiToyPreset * preset = [hiFiToyPresetList presetWithIndex:indexPath.row];
        if ([preset.presetName isEqualToString:self.hiFiToyDevice.activeKeyPreset]) {
            return;
        }
  
        //show dialog
        DialogSystem * dialog = [DialogSystem sharedInstance];
        
        NSString *msg = [NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to load '%@' preset?", @""),
                             NSLocalizedString(preset.presetName, @"")];
        
        [dialog showDialog:NSLocalizedString(@"Warning", @"")
                       msg:msg
                     okBtn:@"Yes"
                 cancelBtn:@"Cancel"
              okBtnHandler:^(UIAlertAction * _Nonnull action) {
            
            self.hiFiToyDevice.activeKeyPreset = preset.presetName;
            [[HiFiToyDeviceList sharedInstance] saveDeviceListToFile];
            
            //update checksum and save
            [self.hiFiToyDevice.preset updateChecksum];
            [self->hiFiToyPresetList setPreset:self.hiFiToyDevice.preset];
            
            [self.hiFiToyDevice.preset storeToPeripheral];
                                                             
            [self.tableView reloadData];
            
        } cancelBtnHandler:nil];
        
        
    } else { // open merge tool
        
    }
    
}

/*-----------------------------------------------------------------------------------------
 Prepare for segue
 -----------------------------------------------------------------------------------------*/
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIButton *)sender {
    if ([[segue identifier] isEqualToString:@"showPresetDetail"]) {
        PresetDetailViewController * destination = (PresetDetailViewController * )segue.destinationViewController;

        destination.hiFiToyPreset = [hiFiToyPresetList presetWithIndex:sender.tag];
        
    }
    
}

@end
