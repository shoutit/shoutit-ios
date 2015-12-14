//
//  SHShoutPickerTableViewController.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 03/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

protocol SHShoutPickerTableViewControllerDelegate {
    func didFinishSelect(shout: SHShout)
}

class SHShoutPickerTableViewController: BaseTableViewController {

    private var viewModel: SHShoutPickerTableViewModel?
    var delegate: SHShoutPickerTableViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = viewModel
        self.tableView.delegate = viewModel
        self.edgesForExtendedLayout = UIRectEdge.None
        tableView.registerNib(UINib(nibName: Constants.TableViewCell.SHShoutTableViewCell, bundle: NSBundle.mainBundle()), forCellReuseIdentifier: Constants.TableViewCell.SHShoutTableViewCell)
        viewModel?.viewDidLoad()
    }
    
    override func initializeViewModel() {
        viewModel = SHShoutPickerTableViewModel(viewController: self)
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
