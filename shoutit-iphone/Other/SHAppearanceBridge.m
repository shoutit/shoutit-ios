//
//  SHAppearanceBridge.m
//  shoutit
//
//  Created by Łukasz Kasperek on 10.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

#import "SHAppearanceBridge.h"
#import "Shoutit-Swift.h"

@implementation SHAppearanceBridge

+ (void)applyNavigationBarAppearanceWithColor:(UIColor *)color {
    [UINavigationBar appearanceWhenContainedIn:[LoginNavigationViewController class], nil].tintColor = color;
    [UINavigationBar appearanceWhenContainedIn:[LoginNavigationViewController class], nil].titleTextAttributes = @{NSForegroundColorAttributeName : color};
}

@end
