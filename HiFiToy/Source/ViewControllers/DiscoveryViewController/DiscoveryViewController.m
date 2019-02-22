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
#import "DialogSystem.h"

@interface DiscoveryViewController(){
    //UIAlertView *connectingAlert;
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
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(handleEnteredForeground)
                                                 name: UIApplicationWillEnterForegroundNotification
                                               object: nil];
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyfobDidFound)
                                                 name: @"KeyfobDidFoundNotification"
                                               object: nil];
    
    
    hiFiToyControl = [HiFiToyControl sharedInstance];
    
}

- (void) handleEnteredForeground
{
    [hiFiToyControl startDiscovery];
    [self.tableView reloadData];
}

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
            if (!hiFiToyControl.foundHiFiToyDevices.count){
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
        case 0: return hiFiToyControl.foundHiFiToyDevices.count;
        case 1: return 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FoundCell * foundCell = [tableView dequeueReusableCellWithIdentifier:@"FoundCell"];
    if (!foundCell) {
        foundCell = [[FoundCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FoundCell"];
    }
    
    if (indexPath.section == 0){
        if (indexPath.row < hiFiToyControl.foundHiFiToyDevices.count){
            HiFiToyDevice * hiFiToyDevice = [hiFiToyControl.foundHiFiToyDevices objectAtIndex:indexPath.row];
            foundCell.DspFoundUdid_outl.text = hiFiToyDevice.name;
            
        } else {
            foundCell.DspFoundUdid_outl.text = @"err";
        }
        
    } else {
        foundCell.DspFoundUdid_outl.text = @"Demo Mode";
    }
    
    return foundCell;
}

/*------------------------------------ Prepare for segue ---------------------------------------*/
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ConnectSegue"]) {
        
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForCell:sender];
        
        if ((selectedIndexPath.section == 0) && (selectedIndexPath.row < hiFiToyControl.foundHiFiToyDevices.count)){
            
            HiFiToyDevice * device = [hiFiToyControl.foundHiFiToyDevices objectAtIndex:selectedIndexPath.row];
            [hiFiToyControl connect:device];
            
            //for re-connect draw connectingAlert
            //[self showConnectAlert];
            
        } else {//demomode
            [hiFiToyControl demoConnect];
        }
    }

    [hiFiToyControl stopDiscovery];
}


- (void) showHint:(UIButton *)button
{
    NSString * bundleName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleName"];
    NSString * msgString = [NSString stringWithFormat:@"This window shows all available online %@ devices, which you may choose to control. Also you can rename UUID number for any simple name in the Options/Name menu.", bundleName];

    [[DialogSystem sharedInstance] showAlert:msgString];
}



- (void) keyfobDidFound
{
    NSLog(@"keyfobDidFound");
    [self.tableView reloadData];
}

@end
