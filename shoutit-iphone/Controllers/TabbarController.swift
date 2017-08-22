//
//  TabbarController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 01/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import ShoutitKit

final class TabbarController: UIViewController, Navigation {

    @IBOutlet var tabs: [TabbarButton]?
    
    fileprivate let disposeBag = DisposeBag()
    
    weak var rootController : RootController?
    
    var selectedNavigationItem : NavigationItem? {
        didSet {
            guard let tabs = tabs else {
                return
            }
            
            for button : TabbarButton in tabs {
                button.isSelected = button.tabNavigationItem() == self.selectedNavigationItem
            }
        }
    }
    
    override func viewDidLoad() {
        
        for button in tabs! {
            button
                .rx_tap
                .subscribeNext {[unowned self] in
                    self.tabs!.each { $0.isSelected = false }
                    button.isSelected = true
                    self.triggerActionWithItem(NavigationItem(rawValue: button.navigationItem)!)
                }
                .addDisposableTo(self.disposeBag)
        }
        
        Account.sharedInstance.statsSubject.subscribeNext { [weak self] (stats) in
            self?.fillBadgesWithStats(stats)
        }.addDisposableTo(disposeBag)
        
    }
    
    func triggerActionWithItem(_ navigationItem : NavigationItem) {
        if let root = self.rootController {
            root.openItem(navigationItem)
        }
    }
    
    fileprivate func fillBadgesWithStats(_ stats: ProfileStats?) {
        fillUnreadConversations(stats?.unreadConversationCount ?? 0)
        fillUnreadNotifications(stats?.unreadNotificationsCount ?? 0)
    }
    
    func fillUnreadNotifications(_ unread: Int) {
        let tab = tabButtonForNavigationItem(.Profile)
        tab.setBadgeNumber(unread)
    }
    
    func fillUnreadConversations(_ unread: Int) {
        let tab = tabButtonForNavigationItem(.Chats)
        tab.setBadgeNumber(unread)
    }
    
    fileprivate func tabButtonForNavigationItem(_ navigationItem: NavigationItem) -> TabbarButton {
        for button in self.tabs! {
            if button.navigationItem == navigationItem.rawValue {
                return button
            }
        }
        
        fatalError("Wrong Tab Selected")
    }
}
