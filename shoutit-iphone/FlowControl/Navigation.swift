//
//  Navigation.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 01/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

enum NavigationItem : String {
    case Home = "home"
    case Discover = "discover"
    case Shout = "shout"
    case Chats = "chats"
    case Profile = "profile"
    case Browse = "browse"
    case Orders = "orders"
    case Settings = "settings"
    case Help = "help"
    case InviteFriends = "inviteFriends"
    case Search = "search"
}

protocol Navigation {
    weak var rootController : RootController? {get set}
    
    func triggerActionWithItem(navigationItem: NavigationItem)
}