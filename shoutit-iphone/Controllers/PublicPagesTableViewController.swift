//
//  PublicPagesTableViewController.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 23.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class PublicPagesTableViewController: UITableViewController {
    
    var viewModel: PublicPagesViewModel!
    weak var flowDelegate: FlowController?
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil)
        registerReusables()
    }
    
    private func registerReusables() {
        tableView.register(ProfileTableViewCell.self)
    }
}
