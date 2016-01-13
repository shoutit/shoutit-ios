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
    var selectedCategories = [String]()
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomSpaceToNextBtn: NSLayoutConstraint!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = viewModel
        self.tableView.delegate = viewModel
        self.tableView.layer.borderColor = UIColor(colorLiteralRed: 88/255, green: 88/255, blue: 88/255, alpha: 0.5).CGColor
        self.tableView.layer.borderWidth = 1
        self.tableView.layer.cornerRadius = 5
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
        bottomSpaceToNextBtn.constant = UIScreen.mainScreen().bounds.height / 11.91
        tableViewHeight.constant = UIScreen.mainScreen().bounds.height / 1.395
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
        SHOauthToken.goToDiscover()
    }
    
    @IBAction func nextAction(sender: AnyObject) {
        SHOauthToken.goToDiscover()
    }
    
    deinit {
        viewModel?.destroy()
    }

}
