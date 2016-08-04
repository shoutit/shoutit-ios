//
//  SHAppearanceBridge.m
//  shoutit
//
//  Created by Łukasz Kasperek on 10.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

#import "SHAppearanceBridge.h"

#if LOCAL
    #import "Shoutit_Local-Swift.h"
#else
    #import "Shoutit-Swift.h"
#endif

@implementation SHAppearanceBridge

+ (void)applyNavigationBarAppearanceWithColor:(UIColor *)color {
    [UINavigationBar appearanceWhenContainedIn:[LoginNavigationViewController class], nil].tintColor = color;
    [UINavigationBar appearanceWhenContainedIn:[LoginNavigationViewController class], nil].titleTextAttributes = @{NSForegroundColorAttributeName : color};
}

@end
