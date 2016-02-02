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
        case Home = "ShoutList"
        case Discover = "Discover"
        case Shout = "Shout"
        case Chats = "Chats"
        case Profile = "Profile"
    }
    
    // General
    
    static func storyboard(storyboard: Storyboard) -> UIStoryboard {
        return UIStoryboard(name: storyboard.rawValue, bundle: nil)
    }
    
    // MARK: - Login storyboard view controllers
    
    static func introViewController() -> IntroViewController {
        return storyboard(.Login).instantiateViewControllerWithIdentifier("IntroViewController") as! IntroViewController
    }
    
    static func loginMethodChoiceViewController() -> LoginMethodChoiceViewController {
        return storyboard(.Login).instantiateViewControllerWithIdentifier("LoginMethodChoiceViewController") as! LoginMethodChoiceViewController
    }
    
    static func homeViewController() -> UIViewController {
        return storyboard(.Home).instantiateViewControllerWithIdentifier("shoutListViewController")
    }
    
    static func browseViewController() -> UIViewController {
        return storyboard(.Home).instantiateViewControllerWithIdentifier("IntroViewController")
    }
    
    static func ordersViewController() -> UIViewController {
        return storyboard(.Home).instantiateViewControllerWithIdentifier("IntroViewController")
    }
    
    static func discoverViewController() -> UIViewController {
        return storyboard(.Discover).instantiateViewControllerWithIdentifier("SHDiscoverCollectionViewController")
    }
    
    static func shoutViewController() -> UIViewController {
        return storyboard(.Shout).instantiateViewControllerWithIdentifier("shCreateShoutTableViewController")
    }
    
    static func chatsViewController() -> UIViewController {
        return storyboard(.Chats).instantiateViewControllerWithIdentifier("SHConversationsTableViewController")
    }
    
    static func profileViewController() -> UIViewController {
        return storyboard(.Profile).instantiateViewControllerWithIdentifier("SHProfileCollectionViewController")
    }
}
