//
//  UISearchBarAppearance.h
//  shoutit
//
//  Created by Abhijeet Chaudhary on 14/07/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

@interface UIBarButtonItem (UISearchBarAppearance)
// appearanceWhenContainedIn: is not available in Swift. This fixes that.
+ (instancetype)my_appearanceWhenContainedIn:(Class<UIAppearanceContainer>)containerClass;
@end
