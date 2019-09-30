//
//  PhotosViewControllerCollectionViewController.m
//  BackgroundFR
//
//  Created by Kerosinn_OSX on 03/09/2019.
//  Copyright © 2019 Kerosinn_OSX. All rights reserved.
//

#import "PhotosViewController.h"
#import "PhotoViewCell.h"
#import "BackFR.h"
#import "AdjustBackFRViewController.h"
#import "DialogSystem.h"

@interface PhotosViewController () {
    PHFetchResult<PHAsset *> * fetchResult;
    CGSize thumbnailSize;
}

@end

@implementation PhotosViewController

- (BOOL)shouldAutorotate {
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscape;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeLeft;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    //[self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"GridViewCell"];
    self.title = @"Photos";
    
    [self getPhotos];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Determine the size of the thumbnails to request from the PHCachingImageManager.
    CGFloat scale = UIScreen.mainScreen.scale;
    CGSize cellSize = self.collectionFlowViewLayout.itemSize;
    
    thumbnailSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale);

}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    CGFloat width = self.view.bounds.size.width;
    int columnCount = floor(width / 80);
    CGFloat itemLength = (width - columnCount - 1) / columnCount;
    self.collectionFlowViewLayout.itemSize = CGSizeMake(itemLength, itemLength);
    
}

- (void) viewDidDisappear:(BOOL)animated {
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    [super viewDidDisappear:animated];
}

- (void) getPhotos {
    PHFetchOptions * opt = [[PHFetchOptions alloc] init];
    NSSortDescriptor * sort = [NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES];
    opt.sortDescriptors = [NSArray arrayWithObjects:sort, nil];
    opt.predicate = [NSPredicate predicateWithFormat:@"mediaType = %d",PHAssetMediaTypeImage];
    fetchResult = [PHAsset fetchAssetsWithOptions:opt];
    
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
}


- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    PHFetchResultChangeDetails * changes = [changeInstance changeDetailsForFetchResult:fetchResult];
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        if (changes) {
            self->fetchResult = changes.fetchResultAfterChanges;
        } else {
            [self getPhotos];
        }
        
        [self.collectionView reloadData];
    });
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return fetchResult.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GridViewCell" forIndexPath:indexPath];
    
    PHAsset * asset = [fetchResult objectAtIndex:indexPath.item];
    

    [[PHCachingImageManager defaultManager] requestImageForAsset:asset
                                                      targetSize:thumbnailSize/*PHImageManagerMaximumSize*/
                                                     contentMode:PHImageContentModeAspectFill
                                                         options:nil
                                                   resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                       
                                                       cell.photoImage.image = result;
                                                   }];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>


// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset * asset = [fetchResult objectAtIndex:indexPath.item];
    
    DialogSystem * dialog = [DialogSystem sharedInstance];
    [dialog showProgressDialog:@""];
    dialog.progressController.message = @"Getting image 0%";
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self requestImage:asset];
    });
    

    return YES;
}

- (void) requestImage:(PHAsset *) asset {
    PHImageRequestOptions * opt = [[PHImageRequestOptions alloc] init];
    opt.resizeMode = PHImageRequestOptionsResizeModeNone;
    opt.networkAccessAllowed = YES;
    opt.synchronous = YES;
    
    opt.progressHandler = ^(double progress, NSError *error, BOOL *stop, NSDictionary *info) {
        //follow progress + update progress bar
        dispatch_async(dispatch_get_main_queue(), ^{
            DialogSystem * dialog = [DialogSystem sharedInstance];
   
            if ([dialog isProgressDialogVisible]) {
                dialog.progressController.message = [NSString stringWithFormat:@"Getting image %d%%.", (int)(progress * 100)];
            }
        });
        
    };
    
    [[PHCachingImageManager defaultManager] requestImageForAsset:asset
                                                  targetSize:CGSizeMake(asset.pixelWidth, asset.pixelHeight)//PHImageManagerMaximumSize
                                                 contentMode:PHImageContentModeAspectFit
                                                     options:opt
                                               resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                        dispatch_async(dispatch_get_main_queue(), ^{
                                                            [self responseImage:result];
                                                        });
                                                }];
    
}

- (void)responseImage:(UIImage *)img {
    DialogSystem * dialog = [DialogSystem sharedInstance];
    dialog.progressController.message = @"Getting image 100%";
    
    [dialog dismissProgressDialog:^{
        
        [[BackFR sharedInstance] setImage:img];
        
        if (!img) {
            [dialog showAlert:@"Download image error. Please check internet connection and available storage."];
            
        } else {
            //cell.photoImage.image = result;
            NSLog(@"Get media image = %@", img.description);
            
            [self.navigationController popViewControllerAnimated:YES];
            //show adjust view controller
            UIViewController * vc = [[AdjustBackFRViewController alloc] init];
            [self.navigationController pushViewController:vc animated:NO];
        }
        
    }];
}

@end
