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
    
    private let disposeBag = DisposeBag()
    
    var rootController : RootController?
    
    var selectedNavigationItem : NavigationItem? {
        didSet {
            guard let tabs = tabs else {
                return
            }
            
            for button : TabbarButton in tabs {
                button.selected = button.tabNavigationItem() == self.selectedNavigationItem
            }
        }
    }
    
    override func viewDidLoad() {
        
        for button in tabs! {
            button
                .rx_tap
                .subscribeNext {[unowned self] in
                    self.tabs!.each { $0.selected = false }
                    button.selected = true
                    self.triggerActionWithItem(NavigationItem(rawValue: button.navigationItem)!)
                }
                .addDisposableTo(self.disposeBag)
        }
        
        Account.sharedInstance.statsSubject.subscribeNext { [weak self] (stats) in
            self?.fillBadgesWithStats(stats)
        }.addDisposableTo(disposeBag)
        
    }
    
    func triggerActionWithItem(navigationItem : NavigationItem) {
        if let root = self.rootController {
            root.openItem(navigationItem)
        }
    }
    
    private func fillBadgesWithStats(stats: ProfileStats?) {
        fillUnreadConversations(stats?.unreadConversationCount ?? 0)
        fillUnreadNotifications(stats?.unreadNotificationsCount ?? 0)
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
