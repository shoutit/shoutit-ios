//
//  SHFilterCheckmarkTableViewController.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 20/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import Foundation

class SHFilterCheckmarkTableViewController: BaseTableViewController {
    
    var dataArray = [String]()
    var selectedRow: Int?
    var selectedBlock: ((selectedTitle: String, index: Int) -> ())?
    let shApiMisc = SHApiMiscService()
    var isCategories = false
    
    private var viewModel: SHFilterCheckmarkTableViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = viewModel
        self.tableView.delegate = viewModel
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        viewModel?.viewDidLoad()
    }
    
    override func initializeViewModel() {
        viewModel = SHFilterCheckmarkTableViewModel(viewController: self)
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
    
    func setData (array: [String], index: Int) {
        self.dataArray = array
        self.selectedRow = index
        self.tableView.reloadData()
    }
    
    deinit {
        viewModel?.destroy()
    }
    
}
