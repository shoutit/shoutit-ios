//
//  TabbarController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 01/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class TabbarController: UIViewController, Navigation {

    @IBOutlet var tabs: [TabbarButton]?
    
    private let disposeBag = DisposeBag()
    
    var rootController : RootController?
    
    var selectedNavigationItem : NavigationItem? {
        didSet {
            tabs?.each { button in
                button.selected = button.tabNavigationItem() == self.selectedNavigationItem
            }
        }
    }
    
    override func viewDidLoad() {
        
        NotificationManager.sharedManager.unreadNotificationsCountSubject.subscribeNext { [weak self] (count) in
            self?.fillUnreadNotifications(count)
        }.addDisposableTo(disposeBag)
        
        tabs!.each { button in
            button.rx_tap.subscribeNext {
                self.tabs!.each { $0.selected = false }
                
                button.selected = true
                
                self.triggerActionWithItem(NavigationItem(rawValue: button.navigationItem)!)
                
            }.addDisposableTo(self.disposeBag)
        }
        
        Account.sharedInstance.statsSubject.subscribeNext { [weak self] (stats) in
            self?.fillBadges()
        }.addDisposableTo(disposeBag)
        
    }
    
    func triggerActionWithItem(navigationItem : NavigationItem) {
        if let root = self.rootController {
            root.openItem(navigationItem)
        }
    }
    
    private func fillBadges() {
        if let detailedUser = Account.sharedInstance.loggedUser, stats = detailedUser.stats {
            fillUnreadConversations(stats.unreadConversationCount)
            fillUnreadNotifications(stats.unreadNotificationsCount)
        }
    }
    
    func fillUnreadNotifications(unread: Int) {
        let tab = tabButtonForNavigationItem(.Profile)
        tab.setBadgeNumber(unread)
    }
    
    func fillUnreadConversations(unread: Int) {
        let tab = tabButtonForNavigationItem(.Chats)
        tab.setBadgeNumber(unread)
    }
    
    private func tabButtonForNavigationItem(navigationItem: NavigationItem) -> TabbarButton {
        for button in self.tabs! {
            if button.navigationItem == navigationItem.rawValue {
                return button
            }
        }
        
        fatalError("Wrong Tab Selected")
    }
}
