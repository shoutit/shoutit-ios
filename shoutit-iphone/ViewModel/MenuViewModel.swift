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
        case userSwitch
        case main
        case secondary
        
        func cellIdentifier() -> String {
            switch self {
            case .userSwitch: return "UserSwitchCellIdentifier"
            case .main: return "MenuBasicCellIdentifier"
            case .secondary: return "MenuSecondarySectionCellIdentifier"
            }
        }
        
        func menuItems(_ loginState: Account.LoginState?) -> [NavigationItem] {
            switch self {
            case .userSwitch:
                guard case .some(.page) = loginState else {
                    fatalError()
                }
                return [.SwitchFromPageToUser]
            case .main:
                let basicItems: [NavigationItem] = [.Home, .Discover, .Browse, .Chats, .Bookmarks]
                switch loginState {
                case .some(.logged):
                    return basicItems + [.Pages]
                case .some(.page):
                    return basicItems + [.Admins]
                default:
                    return basicItems
                }
            case .secondary: return [.InviteFriends, .Settings, .Help]
            }
        }
    }
    
    func sections() -> [MenuSection] {
        let basicItems: [MenuSection] = [.main, .secondary]
        if case .some(.page) = loginState {
            return [.userSwitch] + basicItems
        }
        return basicItems
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return sections()[section].menuItems(loginState).count
    }
    
    func cellIdentifierForSection(_ section: Int) -> String {
        return sections()[section].cellIdentifier()
    }
    
    func navigationItemForIndexPath(_ indexPath: IndexPath) -> NavigationItem {
        return sections()[indexPath.section].menuItems(loginState)[indexPath.row]
    }
    
}
