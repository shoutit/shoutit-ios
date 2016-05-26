//
//  MenuViewModel.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 05/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class MenuViewModel: AnyObject {
    enum MenuSection : Int {
        case Main = 0
        case Help = 1
        
        func cellIdentifier() -> String {
            switch self {
            case .Main: return "MenuBasicCellIdentifier"
            case .Help: return "MenuHelpCellIdentifier"
            }
        }
        
        func menuItems() -> [NavigationItem] {
            switch self {
            case .Main: return [.Home, .Discover, .Browse, .Chats]
            case .Help: return [.Settings, .Help, .InviteFriends]
            }
        }
    }
    
    func sections() -> [MenuSection] {
        return [MenuSection.Main, MenuSection.Help]
    }
    
    func numberOfRowsInSection(section: Int) -> Int {
        return MenuSection.menuItems(MenuSection(rawValue: section)!)().count
    }
    
    func cellIdentifierForSection(section: Int) -> String {
        return MenuSection.cellIdentifier(MenuSection(rawValue: section)!)()
    }
    
    func navigationItemForIndexPath(indexPath: NSIndexPath) -> NavigationItem {
        return MenuSection.menuItems(MenuSection(rawValue: indexPath.section)!)()[indexPath.row]
    }
    
}
