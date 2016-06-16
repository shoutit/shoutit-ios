//
//  PromotedShoutTableViewController.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 16.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class PromotedShoutTableViewController: UITableViewController {
    
    var viewModel: PromotedShoutViewModel!
    weak var flowDelegate : FlowController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil)
    }
}
