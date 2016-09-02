//
//  NewHomeViewController.swift
//  shoutit
//
//  Created by Piotr Bernad on 29/08/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class NewHomeViewController: UIViewController {

    @IBOutlet var homeView : HomeStackView!
    
    let dataSource = HomeDataSource()
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource.componentsChanged = { (newComponents) in
            self.homeView.applyComponents(newComponents)
        }
        
        dataSource.currentTab = .MyFeed
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        dataSource.active = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        dataSource.active = true
    }

    @IBAction func switchCurrentTab(sender: UIButton) {
        self.homeView.switchToTab(sender.tag)
        
        switch sender.tag {
        case 0:
            dataSource.currentTab = .MyFeed
        case 1:
            dataSource.currentTab = .ShoutitPicks
        case 2:
            dataSource.currentTab = .Discover
        default:
            break
        }
    }
}
