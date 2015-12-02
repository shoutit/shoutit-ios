//
//  SHSettingsTableViewController.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 28/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHSettingsTableViewController: BaseTableViewController{
    private var viewModel: SHSettingsTableViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel?.viewDidLoad()
    }
    
    override func initializeViewModel() {
        viewModel = SHSettingsTableViewModel(viewController: self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        viewModel?.viewDidAppear()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewModel?.viewWillAppear()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel?.viewWillDisappear()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel?.viewDidDisappear()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        viewModel?.destroy()
    }

    
}
