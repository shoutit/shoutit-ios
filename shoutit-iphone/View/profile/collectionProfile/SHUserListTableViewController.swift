//
//  SHUserListTableViewController.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 11/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHUserListTableViewController: BaseTableViewController, UISearchBarDelegate {

    private var viewModel: SHUserListTableViewModel?
    var param: String?
    var type: String?
    var user: SHUser?
    var isSearchMode: Bool?
    var searchQuery: String?
    var tap: UITapGestureRecognizer?
    var searchBar: UISearchBar?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = viewModel
        self.tableView.delegate = viewModel
        if(self.param == "listening" && self.type == "users" || self.type == "tags") {
            self.searchBar = UISearchBar()
            self.searchBar?.sizeToFit()
            self.searchBar?.placeholder = NSLocalizedString("Search", comment: "Search")
            self.searchBar?.delegate = self
            self.searchBar?.searchBarStyle = UISearchBarStyle.Minimal
            self.tableView.tableHeaderView = self.searchBar
        }
        self.tableView.registerNib(UINib(nibName: Constants.TableViewCell.SHUserTableViewCell, bundle: NSBundle.mainBundle()), forCellReuseIdentifier: Constants.TableViewCell.SHUserTableViewCell)
        self.tableView.registerNib(UINib(nibName: Constants.TableViewCell.SHTopTagTableViewCell, bundle: NSBundle.mainBundle()), forCellReuseIdentifier: Constants.TableViewCell.SHTopTagTableViewCell)
        self.edgesForExtendedLayout = UIRectEdge.None
        self.tap = UITapGestureRecognizer(target: self, action: Selector("dismissSearchKeyboard:"))
        self.tap?.numberOfTapsRequired = 1
        self.tableView.scrollsToTop = true
        // [self updateFooterLabel];

        if(self.type == nil || self.type == "users") {
            self.searchBar?.placeholder = NSLocalizedString("Search New Users", comment: "Search New Users")
        } else {
            self.searchBar?.placeholder = NSLocalizedString("Search New Tags", comment: "Search New Tags")
        }
        
        viewModel?.viewDidLoad()
    }
    
    override func initializeViewModel() {
        viewModel = SHUserListTableViewModel(viewController: self)
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
    
    func dismissSearchKeyboard (sender: AnyObject) {
        if let searchBar = self.searchBar, let tap = self.tap {
            if(searchBar.isFirstResponder()) {
                self.tableView.removeGestureRecognizer(tap)
                self.searchBar?.resignFirstResponder()
            }
        }
    }
    
    override func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        return scrollView.scrollsToTop
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        self.searchBar?.setShowsCancelButton(true, animated: true)
        if let tap = self.tap {
            self.tableView.addGestureRecognizer(tap)
        }
        return true
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        self.searchBar?.setShowsCancelButton(false, animated: true)
        if let tap = self.tap {
            self.tableView.removeGestureRecognizer(tap)
        }
        return true
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if(searchBar.text != "") {
            self.searchQuery = searchBar.text
            self.viewModel?.searchAction()
        }
    }
    
    func requestUsersAndTags(user: SHUser, param: String, type: String) {
        self.user = user
        self.param = param
        self.type = type
    }
    
    deinit {
        viewModel?.destroy()
    }


}
