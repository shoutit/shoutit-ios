//
//  TabbarController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 01/02/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TabbarController: UIViewController, Navigation {

    @IBOutlet var tabs: [TabbarButton]!
    
    let disposeBag = DisposeBag()
    
    var rootController : RootController?
    
    override func viewDidLoad() {
        
        tabs.each { button in
            button.rx_tap.subscribeNext {
                self.tabs.each { $0.selected = false }
                
                button.selected = true
                
                self.triggerActionWithItem(NavigationItem(rawValue: button.navigationItem)!)
                
            }.addDisposableTo(self.disposeBag)
        }
        
        tabs.first?.selected = true
    }
    
    func triggerActionWithItem(navigationItem : NavigationItem) {
        if let root = self.rootController {
            root.openItem(navigationItem)
        }
    }
}