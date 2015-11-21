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
    
    static func getStream() -> UIStoryboard {
        return UIStoryboard(name: "StreamStoryboard", bundle: nil)
    }
    
    static func getCreateShout() -> UIStoryboard {
        return UIStoryboard(name: "CreateShoutStoryboard", bundle: nil)
    }
    
    static func getCamera() -> UIStoryboard {
        return UIStoryboard(name: "CameraStoryboard", bundle: nil)
    }
    
    static func getFilter() -> UIStoryboard {
        return UIStoryboard(name: "FilterStoryboard", bundle: nil)
    }
    
    static func getTag() -> UIStoryboard {
        return UIStoryboard(name: "TagStoryboard", bundle: nil)
    }
    
}
