//
//  DownloadPresetCellTableViewCell.m
//  HiFiToy
//
//  Created by Kerosinn_OSX on 07/06/2019.
//  Copyright © 2019 Kerosinn_OSX. All rights reserved.
//

#import "DownloadPresetCell.h"
#import "HiFiToyPreset.h"
#import "DialogSystem.h"

@implementation DownloadPresetCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)downloadPreset:(id)sender {
    NSString * headerUrl = @"https://kerosinn.github.io/hptoy-repo/";
    NSString * name = [headerUrl stringByAppendingString:self.downloadPresetName_outl.text];
    name = [name stringByAppendingString:@".tpr"];
    NSURL * fileURL = [[NSURL alloc] initWithString:name];
    
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:fileURL
                                          completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                              if (error != nil) {
                                                  [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                                                      [[DialogSystem sharedInstance] showAlert:[error localizedDescription]];
                                                  }];
                                                  
                                              } else {
                                                  //NSString * s = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                                  //NSLog(@"%@", s);
                                                  
                                                  [[NSOperationQueue mainQueue] addOperationWithBlock:^ {
                                                      HiFiToyPreset * importPreset = [HiFiToyPreset getDefault];
                                                      [importPreset importFromXmlWithData:data      withName:self.downloadPresetName_outl.text];
                                                  }];
                                                  
                                                  
                                                  
                                              }
                                          }];
    [downloadTask resume];
}
@end
