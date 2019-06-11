//
//  PresetRepoViewController.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 07/06/2019.
//  Copyright © 2019 Kerosinn_OSX. All rights reserved.
//

#import "PresetRepoViewController.h"
#import "DownloadPresetCell.h"
#import "DialogSystem.h"

@interface PresetRepoViewController ()

@end

@implementation PresetRepoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    presetsRefList = [NSMutableArray array];
}

- (void) viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
    
    NSURL * fileURL = [[NSURL alloc] initWithString:@"https://kerosinn.github.io/hptoy-repo/preset_list.txt"];

    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:fileURL
                                          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              if (error != nil) {
                                                  [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                                                      [[DialogSystem sharedInstance] showAlert:[error localizedDescription]];
                                                  }];
                                                  
                                              } else {
                                                  NSString * s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                                  //NSLog(@"%@", s);
                                                  
                                                  NSMutableArray * presetsRef = [NSMutableArray array];
                                                  [s enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
                                                      if ([line length] > 0) {
                                                          [presetsRef addObject:[line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
                                                      }
                                                  }];
                                                  
                                                  [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                                                      [self updatePresetRefList:presetsRef];
                                                  }];
                            
                                              }
                                          }];
    [downloadTask resume];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return presetsRefList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DownloadPresetCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DownloadPresetCell"];
    if (cell == nil) {
        cell = [[DownloadPresetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DownloadPresetCell"];
    }
        
    if (indexPath.row < presetsRefList.count){
        NSString * s = [presetsRefList objectAtIndex:indexPath.row];
        cell.downloadPresetName_outl.text = [s substringToIndex:[s rangeOfString:@"."].location];
        
    } else {
        cell.downloadPresetName_outl.text = @"err";
    }
        
    return cell;
}

- (void) updatePresetRefList:(NSArray *)presetsRef {
    
    presetsRefList = presetsRef;
    NSLog(@"%d", (int)presetsRefList.count);
    
    for (int i = 0; i < presetsRefList.count; i++) {
        NSLog(@"%@", [presetsRefList objectAtIndex:i]);
    }
    
    [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
        [self.tableView reloadData];
    }];
    
}

@end
