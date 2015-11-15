//
//  SHSinglePickerTableViewController.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 16/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHSinglePickerTableViewController: BaseTableViewController {

    private var viewModel: SHSinglePickerTableViewModel?
    
    static func presentPickerFromViewController(parent: UIViewController, stringList: [String], title: String, allowNoneOption: Bool, onSelection: ((String) -> ())?) {
        let vc = SHSinglePickerTableViewController(style: UITableViewStyle.Plain)
        vc.viewModel?.onSelection = onSelection
        vc.viewModel?.stringList = stringList
        vc.viewModel?.allowNoneOption = allowNoneOption
        vc.title = title
        parent.navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delegate = viewModel
        self.tableView.dataSource = viewModel
        viewModel?.viewDidLoad()
    }
    
    override func initializeViewModel() {
        viewModel = SHSinglePickerTableViewModel(viewController: self)
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
