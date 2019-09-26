//
//  PhotosViewControllerCollectionViewController.h
//  BackgroundFR
//
//  Created by Kerosinn_OSX on 03/09/2019.
//  Copyright © 2019 Kerosinn_OSX. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photos/Photos.h"

NS_ASSUME_NONNULL_BEGIN

@interface PhotosViewController : UICollectionViewController <PHPhotoLibraryChangeObserver>


@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *collectionFlowViewLayout;

@end

NS_ASSUME_NONNULL_END
