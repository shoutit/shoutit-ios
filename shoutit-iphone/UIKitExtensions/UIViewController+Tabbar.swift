//
//  UIViewController+Tabbar.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 01.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

protocol TabbarContext {
    func prefersTabbarHidden() -> Bool
}

extension UIViewController: TabbarContext {
    
    func prefersTabbarHidden() -> Bool {
        return false
    }
}