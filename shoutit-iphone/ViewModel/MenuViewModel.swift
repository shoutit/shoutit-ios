//
//  MenuViewModel.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 05/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class MenuViewModel: AnyObject {
    
    let loginState: Account.LoginState?
    
    init(loginState: Account.LoginState?) {
        self.loginState = loginState
    }
    
    enum MenuSection  {
        case UserSwitch
        case Main
        case Secondary
        
        func cellIdentifier() -> String {
            switch self {
            case .UserSwitch: return "UserSwitchCellIdentifier"
            case .Main: return "MenuBasicCellIdentifier"
            case .Secondary: return "MenuSecondarySectionCellIdentifier"
            }
        }
        
        func menuItems(loginState: Account.LoginState?) -> [NavigationItem] {
            switch self {
            case .UserSwitch:
                guard case .Some(.Page) = loginState else {
                    fatalError()
                }
                return [.SwitchFromPageToUser]
            case .Main:
                let basicItems: [NavigationItem] = [.Home, .Discover, .Browse, .Chats]
                switch loginState {
                case .Some(.Logged):
                    return basicItems + [.Pages]
                case .Some(.Page):
                    return basicItems + [.Admins]
                default:
                    return basicItems
                }
            case .Secondary: return [.InviteFriends, .Settings, .Help]
            }
        }
    }
    
    func sections() -> [MenuSection] {
        let basicItems: [MenuSection] = [.Main, .Secondary]
        if case .Some(.Page) = loginState {
            return [.UserSwitch] + basicItems
        }
        return basicItems
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        return sections()[section].menuItems(loginState).count
    }
    
    func cellIdentifierForSection(section: Int) -> String {
        return sections()[section].cellIdentifier()
    }
    
    func navigationItemForIndexPath(indexPath: NSIndexPath) -> NavigationItem {
        return sections()[indexPath.section].menuItems(loginState)[indexPath.row]
    }
    
}
