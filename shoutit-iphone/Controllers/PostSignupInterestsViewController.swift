//
//  PostSignupInterestsViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 05.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class PostSignupInterestsViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    // view model
    var viewModel: PostSignupInterestsViewModel!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
}

extension PostSignupInterestsViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}

extension PostSignupInterestsViewController: UITableViewDelegate {
    
}

