//
//  SHPostSignupViewController.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 1/12/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class SHPostSignupViewController: BaseViewController{

    private var viewModel: SHPostSignupViewModel?
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = viewModel
        self.tableView.delegate = viewModel
        viewModel?.viewDidLoad()
    }
    
    override func initializeViewModel() {
        viewModel = SHPostSignupViewModel(viewController: self)
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
    
    @IBAction func skipAction(sender: AnyObject) {
        
    }
    
    @IBAction func nextAction(sender: AnyObject) {
        
    }
    
    deinit {
        viewModel?.destroy()
    }

}
