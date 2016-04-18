//
//  Navigation.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 01/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import UIKit

enum NavigationItem : String {
    case Home = "home"
    case Discover = "discover"
    case Shout = "shout"
    case Chats = "chats"
    case Profile = "profile"
    case Location = "location"
    case Browse = "browse"
    case Orders = "orders"
    case Settings = "settings"
    case Help = "help"
    case InviteFriends = "inviteFriends"
    case Search = "search"
    
    func title() -> String {
        switch self {
        case .Home: return NSLocalizedString("Home",comment: "")
        case .Discover: return NSLocalizedString("Discover",comment: "")
        case .Browse: return NSLocalizedString("Browse",comment: "")
        case .Chats: return NSLocalizedString("Chats",comment: "")
        case .Orders: return NSLocalizedString("Orders",comment: "")
        case .Settings: return NSLocalizedString("Settings",comment: "")
        case .Help: return NSLocalizedString("Help",comment: "")
        case .InviteFriends: return NSLocalizedString("Invite Friends",comment: "")
        default: return NSLocalizedString("Unsupported Title",comment: "")
        }
    }
    
    func icon() -> UIImage? {
        switch self {
        case .Home: return UIImage(named: "sidemenu_home")
        case .Discover: return UIImage(named: "sidemenu_discover")
        case .Browse: return UIImage(named: "sidemenu_browse")
        case .Chats: return UIImage(named: "sidemenu_chats")
        case .Orders: return UIImage(named: "sidemenu_orders")
        default: return nil
        }
    }
}

protocol Navigation {
    weak var rootController : RootController? {get set}
    
    func triggerActionWithItem(navigationItem: NavigationItem)
    
    var selectedNavigationItem : NavigationItem? {get set}
}