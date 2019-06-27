//
//  PresetDetailViewController.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 08/06/2018.
//  Copyright © 2018 Kerosinn_OSX. All rights reserved.
//

#import "PresetDetailViewController.h"
#import "HiFiToyControl.h"
#import "HiFiToyDeviceList.h"

@implementation PresetDetailViewController

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


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _name_outl.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    _name_outl.text = self.hiFiToyPreset.presetName;
    
    if ([self.hiFiToyPreset.presetName isEqualToString:@"No processing"]){
        _name_outl.text = self.hiFiToyPreset.presetName;
        _name_outl.enabled = NO;
    } else {
        [_name_outl becomeFirstResponder];
    }
}

- (IBAction)editNamePreset:(id)sender {
    NSString *tempPresetKey = [self.hiFiToyPreset.presetName copy];
    [self.hiFiToyPreset rename:_name_outl.text];
    
    //if current preset is active we must re-change activeKeyPreset
    //becuse he is change in rename: method
    HiFiToyDevice * d = [[HiFiToyControl sharedInstance] activeHiFiToyDevice];
    if ([d.activeKeyPreset isEqualToString:tempPresetKey]) {
        [d changeKeyPreset:self.hiFiToyPreset.presetName];
    }
    
}

- (IBAction)sharePreset:(id)sender {
    //get xml data
    XmlData * xmlData = [self.hiFiToyPreset toXmlData];
    NSData * exportData = [xmlData toNSData];
    
    //save data to Document directory
    NSString *rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
    NSString * filename = [NSString stringWithFormat:@"%@.tpr", self.hiFiToyPreset.presetName];
    NSString * presetPath = [rootPath stringByAppendingPathComponent:filename];
    [exportData writeToFile:presetPath atomically:YES];
    
    //get url and create share activity
    NSURL * url = [NSURL fileURLWithPath:presetPath];
    UIActivityViewController * shareActivity = [[UIActivityViewController alloc] initWithActivityItems:@[url]
                                                                                 applicationActivities:nil];
    [shareActivity setCompletionWithItemsHandler:^(UIActivityType __nullable activityType,
                                                   BOOL completed,
                                                   NSArray * __nullable returnedItems,
                                                   NSError * __nullable activityError) {
        //delete preset from NSDocumentsDirectory after complete
        NSError * error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:presetPath error:&error];
        if (error){
            NSLog(@"%@", [error description]);
        } else {
            NSLog(@"Temp preset is delete success.");
        }
    }];
    
    if ( [shareActivity respondsToSelector:@selector(popoverPresentationController)] ) {
        shareActivity.popoverPresentationController.barButtonItem = self.share_outl;
    }
    
    //show share activity
    [self presentViewController:shareActivity animated:YES completion:nil];
}


/*-----------------------------------------------------------------------------------------
 UITextFieldDelegate
 -----------------------------------------------------------------------------------------*/
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    //[textField resignFirstResponder];
    [self.navigationController popViewControllerAnimated:TRUE];
    return NO;
}


@end
