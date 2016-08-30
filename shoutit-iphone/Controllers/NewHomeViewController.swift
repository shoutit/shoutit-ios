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
        
        dataSource.active = true
        dataSource.currentTab = .MyFeed
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        dataSource.active = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
