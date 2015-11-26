//
//  SHStreamTableViewController.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 14/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

enum StreamType {
    case Stream
    case Discover
    case Tag
}

class SHStreamTableViewController: BaseTableViewController, UISearchBarDelegate, DOPDropDownMenuDataSource, DOPDropDownMenuDelegate, SHFilterViewControllerDelegate {

    private var viewModel: SHStreamTableViewModel?
    private var tap: UITapGestureRecognizer?
    private var dropMenu: DOPDropDownMenu?
    
    var searchBar = UISearchBar()
    var mode: String?
    var searchQuery: String?
    var shouts: [SHShout] = []
    var shoutType: ShoutType = .Offer
    let tagsApi = SHApiTagsService()
    let shoutApi = SHApiShoutService()
    var isSearchMode = false
    var location: SHAddress?
    var previousYOffset = 0
    var deltaYOffset = 0
    var subTitleLabel: UILabel?
    
    var streamType: StreamType = .Stream
    var discoverId: String?
    var tagName: String?
    
    private var filterViewController: SHFilterViewController?
    
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
        self.tableView.registerNib(UINib(nibName: "SHStreamTagTableViewCell", bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "SHStreamTagTableViewCell")
        self.location = SHAddress.getUserOrDeviceLocation()
        self.mode = "Search"
        self.tap = UITapGestureRecognizer(target: self, action: Selector("dismissSearchKeyboard:"))
        self.tap?.numberOfTapsRequired = 1
        // SearchBar
        self.searchBar = UISearchBar(frame: CGRectMake(0, 20, self.view.frame.size.width, 44))
        self.searchBar.delegate = self
        self.searchBar.placeholder = NSLocalizedString("Search", comment: "Search")
        self.navigationController?.view.insertSubview(self.searchBar, belowSubview: (self.navigationController?.navigationBar)!)
        self.tableView.keyboardDismissMode = .OnDrag
        if streamType == .Stream {
            self.tabBarItem.title = NSLocalizedString("Stream", comment: "Stream")
            self.tableView.scrollsToTop = true
            let mapB = UIBarButtonItem(image: UIImage(named: "mapButton"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("switchToMapView:"))
            self.navigationItem.rightBarButtonItem = mapB
            let loc = UIBarButtonItem(title: NSLocalizedString("Filter", comment: "Filter"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("selectFilter:"))
            self.navigationItem.leftBarButtonItem = loc
        }
        self.edgesForExtendedLayout = UIRectEdge.None
        viewModel?.setupNavigationBar()
        // Navigation Setup
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        
        // set Filter SB
        self.filterViewController = UIStoryboard.getFilter().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHFILTER) as? SHFilterViewController
        self.filterViewController?.delegate = self
        
        
        if streamType == .Discover {
            shoutApi.discoverId = self.discoverId
        } else if streamType == .Tag {
            shoutApi.tagName = self.tagName
        }
        
        viewModel?.viewDidLoad()
    }
    
    override func initializeViewModel() {
        viewModel = SHStreamTableViewModel(viewController: self)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.contentInset = UIEdgeInsetsMake(44, 0, 0, 0)
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(44, 0, 0, 0)
        setPullToRefresh()
        viewModel?.viewDidAppear()
        
        if streamType != .Stream {
            self.hideSearchBar(self.tableView)
        }
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
    
    func switchToMapView(sender: AnyObject) {
        let mapViewController = UIStoryboard.getStream().instantiateViewControllerWithIdentifier(Constants.ViewControllers.STREAM_MAP)
        UIView.beginAnimations("View Flip", context: nil)
        UIView.setAnimationDuration(0.50)
        UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
        UIView.setAnimationTransition(UIViewAnimationTransition.FlipFromRight, forView: (self.navigationController?.view)!, cache: false)
        self.navigationController?.pushViewController(mapViewController, animated: true)
        UIView.commitAnimations()
    }
    
    func selectFilter(sender: AnyObject) {
        if let filterVC = self.filterViewController {
            let navController = SHNavigationViewController(rootViewController: filterVC)
            self.presentViewController(navController, animated: true, completion: nil)
        }
    }
    
    // MARK - SHFilterViewControllerDelegate
    func applyFilter(shFilter: SHFilter?, isApplied: Bool) {
        if let filter = shFilter {
            if let location = filter.location {
                if let oauthToken = SHOauthToken.getFromCache() where oauthToken.isSignedIn(), let userName = oauthToken.user?.username, let latitude = location.latitude, let longitude = location.longitude {
                    // Update User's Location
                    SHProgressHUD.show(NSLocalizedString("UpdatingLocation", comment: "Updating Location..."))
                    SHApiUserService().updateLocation(userName, latitude: latitude, longitude: longitude, completionHandler: { (response) -> Void in
                            SHProgressHUD.dismiss()
                            if response.result.isSuccess {
                                NSUserDefaults.standardUserDefaults().setBool(true, forKey: Constants.SharedUserDefaults.CUSTOM_LOCATION)
                                oauthToken.updateUser(response.result.value)
                            }
                        NSNotificationCenter.defaultCenter().postNotificationName(Constants.Notification.LocationUpdated, object: nil)
                    })
                }
            }
            shoutApi.filter = filter
            viewModel?.getLatestShouts()
        }
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



