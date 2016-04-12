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
    func hasFakeNavigationBar() -> Bool
}

extension UIViewController: NavigationBarContext {
    
    func prefersNavigationBarHidden() -> Bool {
        return false
    }
    
    func hasFakeNavigationBar() -> Bool {
        return false
    }
    
    func ignoresToggleMenu() -> Bool {
        return false
    }
}
