//
//  Navigation.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 01/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import UIKit
import DeepLinkKit

enum NavigationItem : String {
    case Home = "home"
    case Discover = "discover"
    case Shout = "shout"
    case CreateShout = "create_shout"
    case Chats = "chats"
    case Notifications = "notifications"
    case Conversation = "conversation"
    case PublicChats = "public_chats"
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
        case .PublicChats: return NSLocalizedString("Public Chats",comment: "")
        case .Conversation: return NSLocalizedString("Conversation",comment: "")
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
    var selectedNavigationItem : NavigationItem? {get set}
    
    func triggerActionWithItem(navigationItem: NavigationItem)
}

protocol DeepLinkHandling {
    func handleDeeplink(deepLink: DPLDeepLink)
}

extension DPLDeepLink {
    var navigationItem : NavigationItem? {
        if let host = self.URL.host {
            return NavigationItem(rawValue: host)
        }
        
        return nil
    }
}