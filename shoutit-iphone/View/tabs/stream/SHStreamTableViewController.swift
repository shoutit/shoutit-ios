//
//  SHStreamTableViewController.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 14/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHStreamTableViewController: BaseTableViewController, UISearchBarDelegate, DOPDropDownMenuDataSource, DOPDropDownMenuDelegate {

    private var viewModel: SHStreamTableViewModel?
    private var tap: UITapGestureRecognizer?
    private var dropMenu: DOPDropDownMenu?
//    @IBOutlet var tableView: UITableView!
    
    var searchBar = UISearchBar()
    var mode: String?
    var searchQuery: String?
    var shouts: [SHShout] = []
    var shoutType: ShoutType = .Offer
    let tagsApi = SHApiTagsService()
    var isSearchMode = false
    var location: SHAddress?
    var previousYOffset = 0
    var deltaYOffset = 0
    var subTitleLabel: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set Datasource and Delegate
        self.tableView.delegate = viewModel
        self.tableView.dataSource = viewModel
        // Register cells
        self.tableView.registerNib(UINib(nibName: "SHShoutTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "SHShoutTableViewCell")
        self.tableView.registerNib(UINib(nibName: "SHRequestImageTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "SHRequestImageTableViewCell")
        self.tableView.registerNib(UINib(nibName: "SHRequestVideoTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "SHRequestVideoTableViewCell")
        self.tableView.registerNib(UINib(nibName: "SHTopTagTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "SHTopTagTableViewCell")
        self.location = SHAddress.getUserOrDeviceLocation()
        self.mode = "Search"
        self.tap = UITapGestureRecognizer(target: self, action: Selector("dismissSearchKeyboard:"))
        self.tap?.numberOfTapsRequired = 1
        // SearchBar
        self.searchBar = UISearchBar(frame: CGRectMake(0, 20, self.view.frame.size.width, 44))
        self.searchBar.delegate = self
        self.searchBar.placeholder = NSLocalizedString("Search", comment: "Search")
        self.navigationController?.view.insertSubview(self.searchBar, belowSubview: (self.navigationController?.navigationBar)!)
        self.showSearchBar(self.tableView)
        self.tableView.keyboardDismissMode = .OnDrag
        
        viewModel?.viewDidLoad()
    }
    
    override func initializeViewModel() {
        viewModel = SHStreamTableViewModel(viewController: self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        setPullToRefresh()
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
    
    func dismissSearchKeyboard(sender: AnyObject) {
        if (self.searchBar.isFirstResponder()) {
            if let tap = self.tap {
                self.tableView.removeGestureRecognizer(tap)
            }
            self.searchBar.resignFirstResponder()
        }
    }
    
    func showSearchBar(sender: UIScrollView) {
        let currentPoint: CGPoint = sender.contentOffset
        if let navBar = self.navigationController?.navigationBar {
            let yMin = navBar.frame.origin.y
            let yMax = yMin + navBar.frame.size.height
            if (self.searchBar.frame.origin.y < yMax) {
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.searchBar.center = CGPointMake(self.searchBar.center.x, self.searchBar.frame.size.height/2 + yMax)
                    if(currentPoint.y < 0) {
                        let point: CGPoint = CGPointMake(currentPoint.x, -44)
                        self.tableView.setContentOffset(point, animated: true)
                    }
                    self.tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0)
                    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(44, 0, 0, 0)
                })
            }
        }
    }
    
    func hideSearchBar(sender: UIScrollView) {
        if let navBar = self.navigationController?.navigationBar {
            let yMin = navBar.frame.origin.y
            let yMax = yMin + navBar.frame.size.height
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.searchBar.center = CGPointMake(self.searchBar.center.x, -self.searchBar.frame.size.height/2.0 + yMax)
                self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
                self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0)
            })
            
        }
    }
    
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        self.tableView.addGestureRecognizer(self.tap!)
        return true
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        self.tableView.removeGestureRecognizer(self.tap!)
        return true
    }
    
    func searchBar(searchBar: UISearchBar, var textDidChange searchText: String) {
        if(self.mode == "Tag") {
            searchText = searchText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
            self.searchBar.text = searchText
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if (searchBar.text != "") {
            self.searchQuery = searchBar.text
            self.shouts = []
            self.tableView.reloadData()
            self.loading = true
            loadMoreView.showLoading()
            loadMoreView.loadingLabel.text = ""
            
            viewModel?.triggerSearchForBar()
            self.isSearchMode = true
        } else {
            self.isSearchMode = false
        }
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        self.isSearchMode = searchBar.text != ""
        self.dismissSearchKeyboard(searchBar)
    }
    
    func searchBarResultsListButtonClicked(searchBar: UISearchBar) {
        self.dropMenu = DOPDropDownMenu(origin: CGPointMake(self.searchBar.frame.origin.x, self.searchBar.frame.origin.y + self.searchBar.frame.size.height), andHeight: 1)
        self.dropMenu?.dataSource = self
        self.dropMenu?.delegate = self
        if let menu = dropMenu {
            self.view.addSubview(menu)
        }
        self.dropMenu?.present()
    }
    
    func menu(menu: DOPDropDownMenu!, didSelectRowAtIndexPath indexPath: DOPIndexPath!) {
        switch (indexPath.row) {
        case 0:
            self.searchBar.placeholder = NSLocalizedString("Search", comment: "Search")
        case 1:
            self.searchBar.placeholder = NSLocalizedString("Tag", comment: "Tag")
        default:
            break
        }
        self.dropMenu!.hide()
        self.mode = self.searchBar.placeholder
    }
    
    func menu(menu: DOPDropDownMenu!, numberOfRowsInColumn column: Int) -> Int {
        return 2
    }
    
    func menu(menu: DOPDropDownMenu!, titleForRowAtIndexPath indexPath: DOPIndexPath!) -> String! {
        switch (indexPath.row) {
        case 0:
            return NSLocalizedString("Search", comment: "Search")
        case 1:
            return NSLocalizedString("Tag", comment: "Tag")
        default:
            break
        }
        return ""
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
    
    // MARK - Private
    private func setPullToRefresh() {
        self.tableView?.addPullToRefreshWithActionHandler({ () -> Void in
            self.viewModel?.pullToRefresh()
        })

        self.tableView?.addInfiniteScrollingWithActionHandler({ () -> Void in
            self.viewModel?.triggerLoadMore()
        })
    }
    
    deinit {
        viewModel?.destroy()
        self.searchBar.delegate = nil
        if let tap = self.tap {
            self.tableView.removeGestureRecognizer(tap)
        }
        self.tap = nil
    }
    
}



