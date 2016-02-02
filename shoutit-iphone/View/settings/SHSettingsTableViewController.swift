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
    var user: SHUser?
    
    @IBOutlet weak var fbLinkButton: UIButton!
    @IBOutlet weak var googleLinkButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = viewModel
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
    
    @IBAction func fbLinkAction(sender: AnyObject) {
        self.viewModel?.fbLinkAction()
    }
    
    @IBAction func googleLinkAction(sender: AnyObject) {
        self.viewModel?.googleLinkAction()
    }
    
    deinit {
        viewModel?.destroy()
    }

    
}