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
        case HTML = "HTML"
        case Home = "Home"
        case Discover = "Discover"
        case Shout = "Shout"
        case Chats = "Chats"
        case Profile = "Profile"
        case Settings = "Settings"
        case Location = "Location"
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
    
    static func postSignupInterestsViewController() -> PostSignupInterestsViewController {
        return storyboard(.Login).instantiateViewControllerWithIdentifier("PostSignupInterestsViewController") as! PostSignupInterestsViewController
    }
    
    static func postSignupSuggestionsViewController() -> PostSignupSuggestionsWrappingViewController {
        return storyboard(.Login).instantiateViewControllerWithIdentifier("PostSignupSuggestionsWrappingViewController") as! PostSignupSuggestionsWrappingViewController
    }
    
    // MARK: - HTML storyboard view controllers
    
    static func htmlViewController() -> HTMLViewController {
        return storyboard(.HTML).instantiateInitialViewController() as! HTMLViewController
    }
    
    // MARK: - Home storyboard view controllers

    static func homeViewController() -> UIViewController {
        return storyboard(.Home).instantiateViewControllerWithIdentifier("homeRootController")
    }
    
    static func browseViewController() -> UIViewController {
        return storyboard(.Home).instantiateViewControllerWithIdentifier("IntroViewController")
    }
    
    static func ordersViewController() -> UIViewController {
        return UIViewController()
    }
    
    static func discoverViewController() -> DiscoverCollectionViewController {
        return storyboard(.Discover).instantiateViewControllerWithIdentifier("SHDiscoverCollectionViewController") as! DiscoverCollectionViewController
    }
    
    static func discoverShoutsViewController() -> DiscoverShoutsParentViewController {
        return storyboard(.Discover).instantiateViewControllerWithIdentifier("discoverShoutsParent") as! DiscoverShoutsParentViewController
    }
    
    static func shoutViewController() -> UIViewController {
        return storyboard(.Shout).instantiateViewControllerWithIdentifier("shCreateShoutTableViewController")
    }
    
    static func settingsViewController() -> SettingsTableViewController {
        return storyboard(.Settings).instantiateViewControllerWithIdentifier("SettingsTableViewController") as! SettingsTableViewController
    }
    
    static func helpViewController() -> UIViewController {
        return storyboard(.Help).instantiateViewControllerWithIdentifier("HelpRootController")
    }
    
    static func inviteFriendsViewController() -> UIViewController {
        return storyboard(.InviteFriends).instantiateViewControllerWithIdentifier("InviteFriendsRootController")
    }
    
    static func locationViewController() -> ChangeLocationTableViewController {
        return storyboard(.Location).instantiateViewControllerWithIdentifier("LocationRootController") as! ChangeLocationTableViewController
    }
    
    static func chatsViewController() -> UIViewController {
        return storyboard(.Chats).instantiateViewControllerWithIdentifier("SHConversationsTableViewController")
    }
    
    static func profileViewController() -> ProfileCollectionViewController {
        return storyboard(.Profile).instantiateViewControllerWithIdentifier("ProfileCollectionViewController") as! ProfileCollectionViewController
    }
    
    static func changeShoutLocationController() -> SelectShoutLocationViewController {
        return storyboard(.Location).instantiateViewControllerWithIdentifier("ShoutLocationController") as! SelectShoutLocationViewController
    }
}
