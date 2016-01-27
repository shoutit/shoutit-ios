//
//  Wireframe.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 27.01.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

struct Wireframe {
    
    enum Storyboard: String {
        case Main = "Main"
        case Login = "LoginStoryboard"
    }
    
    // General
    
    static func storyboard(storyboard: Storyboard) -> UIStoryboard {
        return UIStoryboard(name: storyboard.rawValue, bundle: nil)
    }
    
    // MARK: - Login storyboard view controllers
    
    static func introViewController() -> IntroViewController {
        return storyboard(.Login).instantiateViewControllerWithIdentifier("IntroViewController") as! IntroViewController
    }
}
