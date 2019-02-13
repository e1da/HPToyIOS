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
}

- (void) viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.tableView reloadData];
    
}

/*-----------------------------------------------------------------------------------------
 UITableViewDataSource protocol
 -----------------------------------------------------------------------------------------*/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [hiFiToyPresetList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PresetCell *presetCell = [tableView dequeueReusableCellWithIdentifier:@"PresetCell"];
    
    if (presetCell == nil) {
        presetCell = [[PresetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PresetCell"];
    }
    
    
    if (indexPath.row < [hiFiToyPresetList count]){
        HiFiToyPreset *hiFiToyPreset = [hiFiToyPresetList.list.allValues objectAtIndex:indexPath.row];
        NSString *keyPreset = [hiFiToyPresetList.list.allKeys objectAtIndex:indexPath.row];
        
        presetCell.presetLabel_outl.text = NSLocalizedString(hiFiToyPreset.presetName, @"");
        presetCell.presetDetailButton_outl.tag = indexPath.row;

        
        //set color
        if ([keyPreset compare:self.hiFiToyDevice.activeKeyPreset] == NSOrderedSame){
            presetCell.presetLabel_outl.textColor = [UIColor blackColor];
        } else {
            presetCell.presetLabel_outl.textColor = [UIColor grayColor];
        }
    } else {
        presetCell.presetLabel_outl.text = @"err";
    }
    
    return presetCell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Detemine if it's in editing mode
    NSString *key = [hiFiToyPresetList.list.allKeys objectAtIndex:indexPath.row];
    if ( ([key compare:@"DefaultPreset"] != NSOrderedSame) && ([key compare:self.hiFiToyDevice.activeKeyPreset] != NSOrderedSame) ){
        return UITableViewCellEditingStyleDelete;
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
        NSString *key = [hiFiToyPresetList.list.allKeys objectAtIndex:indexPath.row];
        
        if ([self.hiFiToyDevice.activeKeyPreset compare:key] == NSOrderedSame){//if remove preset is active
            return;
        }
        //delete preset from list
        [hiFiToyPresetList removePresetWithKey:key];
        
        [self.tableView reloadData];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}


//load preset
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    HiFiToyPreset * preset = [hiFiToyPresetList.list.allValues objectAtIndex:indexPath.row];
    NSString * tempPresetKey = [hiFiToyPresetList.list.allKeys objectAtIndex:indexPath.row];
    
    if ([self.hiFiToyDevice.activeKeyPreset isEqualToString:tempPresetKey]){
        return;
    }
    
    //show dialog
    NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Are you sure you want to load '%@' preset?", @""),
                         NSLocalizedString(preset.presetName, @"")];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Warning", @"")
                                                                             message:message
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Yes"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         
                                                         self.hiFiToyDevice.activeKeyPreset = tempPresetKey;
                                                         [[HiFiToyDeviceList sharedInstance] saveDeviceListToFile];
                                                         
                                                         //[[self.hiFiToyDevice getActivePreset] sendWithResponse:YES];
                                                         [[self.hiFiToyDevice getActivePreset] storeToPeripheral];
                                                         
                                                         [self.tableView reloadData];
                                                     }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

/*-----------------------------------------------------------------------------------------
 Prepare for segue
 -----------------------------------------------------------------------------------------*/
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIButton *)sender {
    if ([[segue identifier] isEqualToString:@"showPresetDetail"]) {
        PresetDetailViewController * destination = (PresetDetailViewController * )segue.destinationViewController;

        NSString * presetKey = [hiFiToyPresetList.list.allKeys objectAtIndex:sender.tag];
        destination.hiFiToyPreset = [[HiFiToyPresetList sharedInstance] getPresetWithKey:presetKey];
        
    }
    
}

- (IBAction)addNewPreset:(id)sender {
    NSString * name = [[NSDate date] descriptionWithLocale:[NSLocale systemLocale]];
    
    //add new preset to presetList
    HiFiToyPreset *newPreset = [[self.hiFiToyDevice getActivePreset] copy];
    newPreset.presetName = name;
    [newPreset updateChecksum];
    
    [[HiFiToyPresetList sharedInstance] openPresetListFromFile];
    [[HiFiToyPresetList sharedInstance] updatePreset:newPreset withKey:newPreset.presetName];
    
    
    //set preset active in device
    self.hiFiToyDevice.activeKeyPreset = newPreset.presetName;
    [[HiFiToyDeviceList sharedInstance] saveDeviceListToFile];
    
    [[self.hiFiToyDevice getActivePreset] storeToPeripheral];
    
    [self.tableView reloadData];
}

@end
