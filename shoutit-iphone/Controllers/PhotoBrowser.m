//
//  PhotoBrowser.m
//  shoutit-iphone
//
//  Created by Piotr Bernad on 04/04/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

#import "PhotoBrowser.h"
#import <WebImage/WebImage.h>
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@implementation PhotoBrowser


- (void)viewDidLoad {
    [super viewDidLoad];

    [self changeBackButtonImage];
    [self changeRightBarButtonItem];
}

- (void)changeBackButtonImage {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    
    if ([UIApplication sharedApplication].userInterfaceLayoutDirection == UIUserInterfaceLayoutDirectionRightToLeft) {
        [button setImage:[UIImage imageNamed:@"rtl_backThin"] forState:UIControlStateNormal];
    } else {
        [button setImage:[UIImage imageNamed:@"backThin"] forState:UIControlStateNormal];
    }
    
    [button addTarget:self action:@selector(pop) forControlEvents:UIControlEventTouchUpInside];
    [button setTintColor:[UIColor whiteColor]];
    
    UIBarButtonItem *barbutton = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    self.navigationItem.leftBarButtonItem = barbutton;
}

- (void)changeRightBarButtonItem {
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                    target:self
                                    action:@selector(shareAction:)];
    self.navigationItem.rightBarButtonItem = shareButton;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:53.0f/255.0f green:221.0f/255.0f blue:105.0f/255.0f alpha:1];
}

- (void)pop {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)ignoresToggleMenu {
    return true;
}

- (void)shareAction:(UIButton *)sender {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Media Options", nil) message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Save", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self saveCurrentPhoto];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)savePhotoWithPhotosFramework:(MWPhoto *)photo {
    
}

- (void)saveCurrentPhoto {
    
    MWPhoto *photo = [self.delegate photoBrowser:self photoAtIndex:self.currentIndex];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"9.0")) {
        [self savePhotoWithPhotosFramework: photo];
        return;
    }
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    if ([photo isVideo]) {
        [library writeVideoAtPathToSavedPhotosAlbum:photo.videoURL completionBlock:^(NSURL *assetURL, NSError *error) {
            NSLog(@"asset: %@, error: %@", assetURL, error);
        }];
    } else if ([photo image]) {
    
        [library writeImageToSavedPhotosAlbum:photo.image.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
            NSLog(@"asset: %@, error: %@", assetURL, error);
        }];
    } else {
        
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        [manager downloadImageWithURL:photo.photoURL
                              options:0
                             progress:nil
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                if (image) {
                                    // do something with image
                                    [library writeImageToSavedPhotosAlbum:image.CGImage metadata:nil completionBlock:^(NSURL *assetURL, NSError *error) {
                                        NSLog(@"asset: %@, error: %@", assetURL, error);
                                    }];
                                    
                                }
                            }];
    }
}

@end
