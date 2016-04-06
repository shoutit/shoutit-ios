//
//  PhotoBrowser.m
//  shoutit-iphone
//
//  Created by Piotr Bernad on 04/04/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

#import "PhotoBrowser.h"

@implementation PhotoBrowser

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"")
                                                                             style:UIBarButtonSystemItemCancel
                                                                            target:self
                                                                            action:@selector(pop)];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.28 green:0.69 blue:0.29 alpha:1];
}

- (void)pop {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)ignoresToggleMenu {
    return true;
}

@end
