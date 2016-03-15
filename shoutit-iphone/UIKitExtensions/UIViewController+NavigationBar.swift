//
//  UIViewController+NavigationBar.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 14.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

protocol NavigationBarContext {
    func prefersNavigationBarHidden() -> Bool
}

extension UIViewController {
    
    func prefersNavigationBarHidden() -> Bool {
        return false
    }
}
