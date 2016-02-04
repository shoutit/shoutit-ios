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
        case Root = "Root"
        case Login = "LoginStoryboard"
        case Home = "ShoutList"
        case Discover = "Discover"
        case Shout = "Shout"
        case Chats = "Chats"
        case Profile = "Profile"
        case Settings = "Settings"
        case Help = "Help"
        case InviteFriends = "InviteFriends"
    }
    
    // General
    
    static func storyboard(storyboard: Storyboard) -> UIStoryboard {
        return UIStoryboard(name: storyboard.rawValue, bundle: nil)
    }
    
    // MARK: - Root storyboard view controller
    
    static func mainInterfaceViewController() -> RootController {
        return storyboard(.Root).instantiateViewControllerWithIdentifier("RootController") as! RootController
    }
    
    // MARK: - Login storyboard view controllers
    
    static func introViewController() -> IntroViewController {
        return storyboard(.Login).instantiateViewControllerWithIdentifier("IntroViewController") as! IntroViewController
    }
    
    static func loginMethodChoiceViewController() -> LoginMethodChoiceViewController {
        return storyboard(.Login).instantiateViewControllerWithIdentifier("LoginMethodChoiceViewController") as! LoginMethodChoiceViewController
    }
    
    static func loginWithEmailViewController() -> LoginWithEmailViewController {
        return storyboard(.Login).instantiateViewControllerWithIdentifier("LoginWithEmailViewController") as! LoginWithEmailViewController
    }
    
    static func signupViewController() -> SignupViewController {
        return storyboard(.Login).instantiateViewControllerWithIdentifier("SignupViewController") as! SignupViewController
    }
    
    static func loginViewController() -> LoginViewController {
        return storyboard(.Login).instantiateViewControllerWithIdentifier("LoginViewController") as! LoginViewController
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
    
    static func settingsViewController() -> UIViewController {
        return storyboard(.Settings).instantiateViewControllerWithIdentifier("SHSettingsTableViewController")
    }
    
    static func helpViewController() -> UIViewController {
        return storyboard(.Help).instantiateViewControllerWithIdentifier("HelpRootController")
    }
    
    static func inviteFriendsViewController() -> UIViewController {
        return storyboard(.InviteFriends).instantiateViewControllerWithIdentifier("InviteFriendsRootController")
    }
    
    static func chatsViewController() -> UIViewController {
        return storyboard(.Chats).instantiateViewControllerWithIdentifier("SHConversationsTableViewController")
    }
    
    static func profileViewController() -> UIViewController {
        return storyboard(.Profile).instantiateViewControllerWithIdentifier("SHProfileCollectionViewController")
    }
}
