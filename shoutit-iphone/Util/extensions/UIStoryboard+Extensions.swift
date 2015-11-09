//
//  UIStoryboard+Extensions.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 08/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

extension UIStoryboard {

    static func getDiscover() -> UIStoryboard {
        return UIStoryboard(name: "Discover", bundle: nil)
    }
    
    static func getLogin() -> UIStoryboard {
        return UIStoryboard(name: "LoginStoryboard", bundle: nil)
    }
    
}
