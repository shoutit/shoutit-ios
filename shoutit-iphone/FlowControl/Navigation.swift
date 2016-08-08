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
    case Credits = "credits"
    case CreditsTransations = "credit_transactions"
    case Pages = "pages"
    case Bookmarks = "bookmarks"
    case Admins = "admins"
    case SwitchFromPageToUser = "switch_to_user"
    case StaticPage = "static"
    
    func title() -> String {
        switch self {
        case .Home: return NSLocalizedString("Home",comment: "Menu Item Title")
        case .Discover: return NSLocalizedString("Discover",comment: "Menu Item Title")
        case .Browse: return NSLocalizedString("Browse",comment: "Menu Item Title")
        case .PublicChats: return NSLocalizedString("Public Chats",comment: "Menu Item Title")
        case .Conversation: return NSLocalizedString("Conversation",comment: "Menu Item Title")
        case .Chats: return NSLocalizedString("Chats",comment: "Menu Item Title")
        case .Bookmarks: return NSLocalizedString("Bookmarks",comment: "Menu Item Title")
        case .Orders: return NSLocalizedString("Orders",comment: "Menu Item Title")
        case .Settings: return NSLocalizedString("Settings",comment: "Menu Item Title")
        case .Help: return NSLocalizedString("Help",comment: "Menu Item Title")
        case .InviteFriends: return NSLocalizedString("Invite Friends",comment: "Menu Item Title")
        case .Pages: return NSLocalizedString("Pages",comment: "Menu item")
        case .Admins: return NSLocalizedString("Admins",comment: "Menu item")
        case .SwitchFromPageToUser:
            guard case .Some(.Page(let user, _)) = Account.sharedInstance.loginState else {
                fallthrough
            }
            return String.localizedStringWithFormat(NSLocalizedString("Use Shoutit as %@", comment: "Menu Item Title"), user.name)
        default: return NSLocalizedString("Unsupported Title",comment: "Dont need to be translated")
        }
    }
    
    func icon() -> UIImage? {
        switch self {
        case .Home: return UIImage(named: "sidemenu_home")
        case .Discover: return UIImage(named: "sidemenu_discover")
        case .Browse: return UIImage(named: "sidemenu_browse")
        case .Chats: return UIImage(named: "sidemenu_chats")
        case .Orders: return UIImage(named: "sidemenu_orders")
        case .Admins: return UIImage(named: "sidemenu_admins")
        case .Pages: return UIImage(named: "sidemenu_pages")
        case .Bookmarks: return UIImage(named: "sidemenu_bookmarks")
        default: return nil
        }
    }
}

protocol Navigation: class {
    
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