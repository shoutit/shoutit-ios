//
//  Assets.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 01.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

extension UIImage {
    
    static func navBarLogoImage() -> UIImage {
        return UIImage(named: "logo_navbar")!
    }
    
    static func backButton() -> UIImage {
        return UIImage(named: "backThin")!
    }
    
    static func menuHamburger() -> UIImage {
        return UIImage(named: "navMenu")!
    }
    
    static func suggestionAccessoryView() -> UIImage {
        return UIImage(named: "suggestions_accessory_view")!
    }
    
    static func suggestionAccessoryViewSelected() -> UIImage {
        return UIImage(named: "suggestions_accessory_view_selected")!
    }
}
