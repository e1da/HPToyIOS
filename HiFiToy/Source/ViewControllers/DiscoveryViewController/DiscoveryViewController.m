//
//  DiscoveryViewController.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 07/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "DiscoveryViewController.h"
#import "FoundCell.h"
#import "DemoCell.h"
#import "HiFiToyPresetList.h"

@interface DiscoveryViewController(){
    //UIAlertView *connectingAlert;
    
    HiFiToyPreset * hiFiToyPreset;
    HiFiToyPreset * tempPreset;
    
    HiFiToyDevice * hiFiToyDevice;
}

- (void) showHint:(UIButton *)button;

@end

@implementation DiscoveryViewController

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
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleEnteredForeground)
                                                 name: UIApplicationWillEnterForegroundNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyfobDidFound)
                                                 name: @"KeyfobDidFoundNotification"
                                               object: nil];
    /*[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didGetPresetImportNotification:)
                                                 name:@"PresetImportNotification"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didGetPresetImportFailNotification:)
                                                 name:@"PresetImportFailNotification"
                                               object:nil];*/
    
    
    hiFiToyControl = [HiFiToyControl sharedInstance];
    hiFiToyDeviceList = [HiFiToyDeviceList sharedInstance];
    
}

- (void) handleEnteredForeground
{
    if (![hiFiToyControl isConnected]){
        [hiFiToyControl startDiscovery];
        /*[dspControl.peripherals removeAllObjects];
        [self.tableView reloadData];
        
        [NSTimer scheduledTimerWithTimeInterval:(float)1.0 target:self selector:@selector(scanTimer:) userInfo:nil repeats:NO];*/
    }
}

/*- (void) scanTimer:(NSTimer *)timer {
    [dspControl disconnectPeripheral];
    [dspControl.peripherals removeAllObjects];
    
    [dspControl findBLEPeripheralsWithName:@"HiFiToy"];
    
}*/

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self handleEnteredForeground];
    
    //create Button
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
    addButton.frame = CGRectMake(self.view.frame.size.width - 60, 10, 20, 20);
    
    [addButton addTarget:self action:@selector(showHint:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
}

/*-------------------------------- UITableViewDataSource protocol -----------------------------------*/
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section){
        case 0:
            if (![hiFiToyControl getPeripherals].count){
                return @"Devices found: none";
            } else {
                return @"Devices found:";
            }
        case 1: return @"";
    }
    return @"";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section){
        case 0: return [hiFiToyControl getPeripherals].count;
        case 1: return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *tableIdentifier;
    UITableViewCell *cell;
    NSArray * peripherals = [hiFiToyControl getPeripherals];
    
    if (indexPath.section == 0){
        FoundCell *foundCell;
        tableIdentifier = @"FoundCell";
        foundCell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
        
        if (foundCell == nil) {
            foundCell = [[FoundCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableIdentifier];
        }
        if (indexPath.row < peripherals.count){
            CBPeripheral *peripheral = [peripherals objectAtIndex:indexPath.row];
            NSString *uuidString = peripheral.identifier.UUIDString;
            
            if (![hiFiToyDeviceList findNameForUUID:uuidString]){
                HiFiToyDevice *device = [[HiFiToyDevice alloc] init];
                [device loadDefaultDspDevice];
                device.name = [uuidString substringFromIndex:(uuidString.length - 15)];
                [hiFiToyDeviceList updateForUUID:uuidString withDevice:device];
            }
            
            foundCell.DspFoundUdid_outl.text = [[hiFiToyDeviceList findNameForUUID:uuidString] name];
        } else {
            foundCell.DspFoundUdid_outl.text = @"err";
        }
        cell = foundCell;
    } else {
        tableIdentifier = @"DemoCell";
        cell = [tableView dequeueReusableCellWithIdentifier:tableIdentifier];
        
        if (![hiFiToyDeviceList findNameForUUID:@"demo"]){
            HiFiToyDevice *device = [[HiFiToyDevice alloc] init];
            [device loadDefaultDspDevice];
            device.name = @"demo";
            [hiFiToyDeviceList updateForUUID:@"demo" withDevice:device];
        }
        
        if (cell == nil) {
            cell = [[DemoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableIdentifier];
        }
    }
    
    return cell;
}

/*------------------------------------ Prepare for segue ---------------------------------------*/
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ConnectSegue"]) {
        
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:sender];
        NSArray * peripherals = [hiFiToyControl getPeripherals];
        
        if ((selectedIndexPath.section == 0) && (selectedIndexPath.row < peripherals.count)){
            
            CBPeripheral * p = [peripherals objectAtIndex:selectedIndexPath.row];
            
            [[HiFiToyPresetList sharedInstance] openPresetListFromFile];//update preset
            [hiFiToyControl connect:p];
            
            //for re-connect draw connectingAlert
            //[self showConnectAlert];
            
            [hiFiToyDeviceList setActiveDeviceWithKey:p.identifier.UUIDString];
            
        } else {//demomode
            [hiFiToyControl disconnect];
            [hiFiToyDeviceList setActiveDeviceWithKey:@"demo"];
        }
        
        
    }
    if ([segue.identifier isEqualToString:@"DemoConnectSegue"]) {
        
        [hiFiToyControl disconnect];
        [hiFiToyDeviceList setActiveDeviceWithKey:@"demo"];
    }
    
    [hiFiToyControl stopDiscovery];
}


- (void) showHint:(UIButton *)button
{
    NSString * msgString = @"This window shows all available online iWoofer devices, which you may choose to control. Also you can rename UUID number for any simple name in the Options/Name menu.";
    
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@""
                                          message:msgString
                                          preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *closeAction = [UIAlertAction
                                  actionWithTitle:@"Close"
                                  style:UIAlertActionStyleDestructive
                                  handler:nil];
    [alertController addAction:closeAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void) keyfobDidFound
{
    NSLog(@"keyfobDidFound");
    [self.tableView reloadData];
}

@end
