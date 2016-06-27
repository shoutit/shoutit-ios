//
//  CreatePageInfoViewController.swift
//  shoutit
//
//  Created by Piotr Bernad on 27/06/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ShoutitKit
import RxSwift

class CreatePageInfoViewController: UITableViewController {

    var preselectedCategory : PageCategory?
    
    weak var flowDelegate: FlowController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = preselectedCategory?.name ?? NSLocalizedString("Create Page", comment: "create page screen title")
    }
    
}
