//
//  MenuTableViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 02/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController, Navigation {
    
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
            case .Main: return [.Home, .Discover, .Browse, .Chats, .Orders]
            case .Help: return [.Settings, .Help, .InviteFriends]
            }
        }
    }
    
    var rootController : RootController?
    
    var overlayView : UIView? {
        didSet {
            guard let overlay = overlayView else {
                oldValue?.removeFromSuperview()
                return
            }
            
            let tapGesture = UITapGestureRecognizer(target: self, action:  "dismiss")
            overlay.addGestureRecognizer(tapGesture)
        }
    }
    
    func dismiss() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func triggerActionWithItem(navigationItem: NavigationItem) {
        if let root = self.rootController {
            root.openItem(navigationItem)
        }
    }
    
    func sections() -> [MenuSection] {
        return [MenuSection.Main, MenuSection.Help]
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections().count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MenuSection.menuItems(MenuSection(rawValue: section)!)().count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cellIdentifier = MenuSection.cellIdentifier(MenuSection(rawValue: indexPath.section)!)()
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)! as! MenuCell
        let item = MenuSection.menuItems(MenuSection(rawValue: indexPath.section)!)()[indexPath.row]
        
        cell.bindWith(item)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let item = MenuSection.menuItems(MenuSection(rawValue: indexPath.section)!)()[indexPath.row]
        triggerActionWithItem(item)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 48.0
    }
}
