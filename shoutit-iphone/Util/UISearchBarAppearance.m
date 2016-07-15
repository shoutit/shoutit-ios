//
//  UISearchBarAppearance.m
//  shoutit
//
//  Created by Abhijeet Chaudhary on 14/07/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@implementation UIBarButtonItem (UISearchBarAppearance)
+ (instancetype)my_appearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass {
    return [self appearanceWhenContainedIn:containerClass, nil];
}
@end