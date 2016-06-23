//
//  MyPagesTableViewController.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 23.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

class MyPagesTableViewController: UITableViewController {
    
    var viewModel: MyPagesViewModel!
    weak var flowDelegate: FlowController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil)
        registerReusables()
    }
    
    private func registerReusables() {
        tableView.register(MyPageTableViewCell.self)
    }
}
