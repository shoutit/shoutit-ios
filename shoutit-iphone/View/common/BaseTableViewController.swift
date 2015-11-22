//
//  BaseTableViewController.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 02/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class BaseTableViewController: UITableViewController {
    
    var fetchedResultsController = []
    var emptyContentView = SHEmptyContentView()
    var loadMoreView = SHLoadMoreView()
    var loading: Bool?
    var visible: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeViewModel()
        
        self.tableView.keyboardDismissMode = .OnDrag
        
        var nibs = NSBundle.mainBundle().loadNibNamed("SHEmptyContentView", owner: self, options: nil)
        if let emptyContentView = nibs.last as? SHEmptyContentView {
            self.emptyContentView = emptyContentView
        }
        
        nibs = NSBundle.mainBundle().loadNibNamed("SHLoadMoreView", owner: self, options: nil)
        if let loadMoreView = nibs.last as? SHLoadMoreView {
            self.loadMoreView = loadMoreView
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func initializeViewModel() {
        assertionFailure("You must override this method in child class [e.g - \nviewModel = ClubFeedViewModel(viewController: self)\n]")
    }
    
}

