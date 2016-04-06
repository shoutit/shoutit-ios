//
//  PhotoBrowser.m
//  shoutit-iphone
//
//  Created by Piotr Bernad on 04/04/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

#import "PhotoBrowser.h"

@implementation PhotoBrowser


- (void)viewDidLoad {
    [super viewDidLoad];

    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    
    [button setImage:[UIImage imageNamed:@"backThin"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(pop) forControlEvents:UIControlEventTouchUpInside];
    [button setTintColor:[UIColor whiteColor]];
    
    UIBarButtonItem *barbutton = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    self.navigationItem.leftBarButtonItem = barbutton;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:0.28 green:0.69 blue:0.29 alpha:1];
}

- (void)pop {
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)ignoresToggleMenu {
    return true;
}

@end
