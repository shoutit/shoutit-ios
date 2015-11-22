//
//  SHStreamTableViewModel.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 14/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import Foundation

class SHStreamTableViewModel: NSObject, TableViewControllerModelProtocol, UITableViewDelegate, UITableViewDataSource, SHFilterViewControllerDelegate {
    
    private var viewController: SHStreamTableViewController
    private var filterViewController: SHFilterViewController?
    private var spinner: UIActivityIndicatorView?
    private var shShoutMeta: SHShoutMeta?
    private let shoutApi = SHApiShoutService()
    private var pulltoRefreshLabel: UILabel?
    
    required init(viewController: SHStreamTableViewController) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        self.viewController.tabBarItem.title = NSLocalizedString("Stream", comment: "Stream")
        self.viewController.tableView.scrollsToTop = true
        let mapB = UIBarButtonItem(image: UIImage(named: "mapButton"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("switchToMapView:"))
        self.viewController.navigationItem.rightBarButtonItem = mapB
        let loc = UIBarButtonItem(title: NSLocalizedString("Filter", comment: "Filter"), style: UIBarButtonItemStyle.Plain, target: self, action: Selector("selectFilter:"))
        self.viewController.navigationItem.leftBarButtonItem = loc
        self.viewController.edgesForExtendedLayout = UIRectEdge.None
        setupNavigationBar()
        // Navigation Setup
        self.viewController.navigationItem.leftBarButtonItem?.tintColor = UIColor.whiteColor()
        // Get Latest Shouts
        getLatestShouts()
        updateSubtitleLabel()
        
        // set Filter SB
        self.filterViewController = UIStoryboard.getFilter().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHFILTER)  as? SHFilterViewController
        self.filterViewController?.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "locationUpdated:", name: Constants.Notification.LocationUpdated, object: nil)
    }
    
    func locationUpdated(notification: NSNotification) {
        if let filterVC = self.filterViewController, let userInfo = notification.userInfo, let location = userInfo["Location"] as? SHAddress {
            self.viewController.location = location
            filterVC.filter?.isApplied = true
            filterVC.filter?.location = location
            let string = String(format: "%@, %@, %@", arguments: [location.city, location.state, location.country])
          //  filterVC.filters[2][0].setObject(string, forKey: Constants.Filter.kRightLablel)
          //  filterVC.filters[2][0].setObject(1, forKey: Constants.Filter.kIsApply)
            self.filterViewController?.applyAction(filterVC)
        }
        getLatestShouts()
        setupNavigationBar()
    }
    
    
    func viewWillAppear() {
        self.updateFooterView()
        self.viewController.searchBar.hidden = false
    }
    
    func viewDidAppear() {
        updateRefreshView()
    }
    
    func viewWillDisappear() {
        self.viewController.searchBar.hidden = true
        self.viewController.hideSearchBar(self.viewController.tableView)
    }
    
    func viewDidDisappear() {
        
    }
    
    func destroy() {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func updateRefreshView() {
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MMM d, h:mm a"
        let title = String(format: "%@: %@", NSLocalizedString("Last update", comment: "Last update"), formatter.stringFromDate(NSDate()))
        
        self.viewController.tableView.pullToRefreshView.subtitleLabel.text = title
    }
    
    func triggerSearchForBar() {
        self.shoutApi.resetPage()
        if let location = self.viewController.location, let query = self.viewController.searchQuery {
            self.shoutApi.searchStreamForLocation(location, type: self.viewController.shoutType, query: query, cacheResponse: { (shShoutMeta) -> Void in
                self.updateUI(shShoutMeta)
                }, completionHandler: { (response) -> Void in
                    self.viewController.tableView.pullToRefreshView.stopAnimating()
                    if(response.result.isSuccess) {
                        if let shShoutMeta = response.result.value {
                            self.updateUI(shShoutMeta)
                        }
                    } else {
                        // Do Nothing
                    }
            })
        }
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let currentPoint = scrollView.contentOffset
        let d = CGFloat(self.viewController.previousYOffset) -  (currentPoint.y)
        if(currentPoint.y < 0) {
            if(d >= 0) {
                self.viewController.showSearchBar(scrollView)
            }
        } else {
            if(fabs(Float(self.viewController.deltaYOffset) - Float(currentPoint.y)) > 50) {
                if(d < 0) {
                    self.viewController.hideSearchBar(scrollView)
                } else {
                    self.viewController.showSearchBar(scrollView)
                }
                self.viewController.deltaYOffset = 0
            }
        }
        self.viewController.deltaYOffset += d > 0 ? 1 : -1
        self.viewController.previousYOffset = Int(currentPoint.y)
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.viewController.previousYOffset = Int(scrollView.contentOffset.y)
        self.viewController.deltaYOffset = Int(scrollView.contentOffset.y)
    }
    
    func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        return scrollView.scrollsToTop
    }
    
    func updateFooterLabel () {
        if (self.viewController.shouts.count == 1) {
            self.viewController.loadMoreView.loadingLabel.text = String(format: "%lu %@", arguments: [self.viewController.shouts.count, NSLocalizedString("Shout", comment: "Shout")])
        } else {
            self.viewController.loadMoreView.loadingLabel.text = String(format: "%lu %@", arguments: [self.viewController.shouts.count, NSLocalizedString("Shouts", comment: "Shouts")])
        }
    }
    
    func pullToRefresh() {
        spinner?.startAnimating()
        getLatestShouts()
    }
    
    func switchToMapView(sender: AnyObject) {
        let mapViewController = UIStoryboard.getStream().instantiateViewControllerWithIdentifier(Constants.ViewControllers.STREAM_MAP) 
        UIView.beginAnimations("View Flip", context: nil)
        UIView.setAnimationDuration(0.50)
        UIView.setAnimationCurve(UIViewAnimationCurve.EaseInOut)
        UIView.setAnimationTransition(UIViewAnimationTransition.FlipFromRight, forView: (self.viewController.navigationController?.view)!, cache: false)
        self.viewController.navigationController?.pushViewController(mapViewController, animated: true)
        UIView.commitAnimations()
    }
    
    func selectFilter(sender: AnyObject) {
        let navController = SHNavigationViewController(rootViewController: self.filterViewController!)
        self.viewController.presentViewController(navController, animated: true, completion: nil)
    }
    
    // tableView
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
//        if(indexPath.row >= self.viewController.shouts.count - Constants.Common.SH_PAGE_SIZE / 3) {
//            self.triggerLoadMore()
//        }
        
        let shout = self.viewController.shouts[indexPath.row]
        if let type = shout.type where type == .Request {
            if(shout.videoUrl != "") {
                let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCell.SHRequestVideoTableViewCell, forIndexPath: indexPath) as! SHRequestVideoTableViewCell
                cell.setShout(shout)
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCell.SHRequestImageTableViewCell, forIndexPath: indexPath) as! SHRequestImageTableViewCell
                cell.setShout(shout)
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCell.SHShoutTableViewCell, forIndexPath: indexPath) as! SHShoutTableViewCell
            cell.setShout(shout)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
       
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (self.viewController.shoutType == .Offer) {
            return 100
        } else {
            return 348
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return self.viewController.shouts.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func updateFooterView() {
        if(self.viewController.shouts.count == 0) {
            self.viewController.tableView.tableFooterView = self.viewController.emptyContentView
        } else {
            self.viewController.tableView.tableFooterView = self.viewController.loadMoreView
        }
    }
    
    func triggerLoadMore () {
        if let location = self.viewController.location, let shShoutMeta = self.shShoutMeta where !shShoutMeta.next.isEmpty {
            self.viewController.loading = true
            self.viewController.loadMoreView.showLoading()
            self.shoutApi.loadShoutStreamNextPageForLocation(location, type: self.viewController.shoutType, query: self.viewController.searchQuery, cacheResponse: { (shShoutMeta) -> Void in
                // Do Nothing
                }, completionHandler: { (response) -> Void in
                    self.viewController.tableView.infiniteScrollingView.stopAnimating()
                    switch(response.result) {
                    case .Success(let result):
                        self.shShoutMeta = result
                        self.viewController.tableView.beginUpdates()
                        var insertedIndexPaths: [NSIndexPath] = []
                        let currentCount = self.viewController.shouts.count
                        for (index, _) in result.results.enumerate() {
                            insertedIndexPaths += [NSIndexPath(forRow: index + currentCount, inSection: 0)]
                        }
                        self.viewController.shouts += result.results
                        self.viewController.tableView.insertRowsAtIndexPaths(insertedIndexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
                        self.viewController.tableView.endUpdates()
                    case .Failure(let error):
                        log.error("Error getting shout response \(error.localizedDescription)")
                    }
            })
        } else {
            self.viewController.loadMoreView.showNoMoreContent()
            self.updateFooterLabel()
            self.updateFooterView()
        }
    }
    
    // MARK - SHFilterViewControllerDelegate
    func applyFilter(filter: SHFilter?, isApplied: Bool) {
        if let shFilter = filter {
//            if let location = shFilter.location {
//                self.viewController.location = location
//                self.updateSubtitleLabel()
//            }
//            if(shFilter.type == NSLocalizedString("Tag", comment: "Tag")) {
//                if(self.viewController.isSearchMode) {
//                    self.viewController.tagsApi.filter = shFilter
//                    if let query = self.viewController.searchQuery {
//                        self.viewController.tagsApi.searchTagQuery(query)
//                    }
//                    // TODO
////                    self.viewController.fetchedResultsController = self.viewController.tagsApi.tags
//                } else {
//                    self.viewController.tagsApi.filter = shFilter
//                    if let location = self.viewController.location {
//                        self.viewController.tagsApi.refreshTopTagsForLocation(location)
//                        // TODO
////                        self.viewController.fetchedResultsController = self.viewController.tagsApi.tags
//                    }
//                    
//                }
//                self.viewController.selectedSegment = 2
//                self.viewController.tableView.reloadData()
//                self.viewController.tableView.backgroundColor = UIColor.whiteColor()
//                self.viewController.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
//            } else if (shFilter.type == "Offer") {
//                self.viewController.shoutApi.filter = shFilter
                //self.fetchedResultsController = self.shoutModel.offerShouts;
//                self.viewController.selectedSegment = 0
//                if let location = self.viewController.location, let type = self.viewController.selectedSegment,
//                    let query = self.viewController.searchQuery {
//                        self.viewController.shoutApi.searchStreamForLocation(location, ofType: type, query: query, cacheResponse: { (shShoutMeta) -> Void in
//                            self.updateUI(shShoutMeta)
//                            }, completionHandler: { (response) -> Void in
//                                self.viewController.tableView.pullToRefreshView.stopAnimating()
//                                if(response.result.isSuccess) {
//                                    if let shShoutMeta = response.result.value {
//                                        self.updateUI(shShoutMeta)
//                                    }
//                                    
//                                } else {
//                                    // Do Nothing
//                                }
//                                
//                        })
//                        self.viewController.tableView.reloadData()
//                        self.viewController.tableView.backgroundColor = UIColor.whiteColor()
//                        self.viewController.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
//                }
                
//            } else {
//                self.viewController.shoutApi.filter = shFilter
                // TODO
//                self.viewController.fetchedResultsController = self.viewController.shoutApi.requestShouts
//                self.viewController.selectedSegment = 1
//                if let location = self.viewController.location, let type = self.viewController.selectedSegment,
//                    let query = self.viewController.searchQuery {
//                        self.viewController.shoutApi.searchStreamForLocation(location, ofType: type, query: query, cacheResponse: { (shShoutMeta) -> Void in
//                            self.updateUI(shShoutMeta)
//                            }, completionHandler: { (response) -> Void in
//                                self.viewController.tableView.pullToRefreshView.stopAnimating()
//                                if(response.result.isSuccess) {
//                                    if let shShoutMeta = response.result.value {
//                                        self.updateUI(shShoutMeta)
//                                    }
//                                    
//                                } else {
//                                    // Do Nothing
//                                }
//                                
//                        })
//                        self.viewController.tableView.reloadData()
//                }
//                self.viewController.tableView.backgroundColor = UIColor.groupTableViewBackgroundColor()
//                self.viewController.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
//            }
            // TODO
//            self.viewController.lastResultCount = self.viewController.fetchedResultsController.count
        }
        
//        self.selectedSegment = 0;
//        
//        [self.shoutModel setFilter:filter];
//        [self.topTagModel setFilter:filter];
//        [self.searchTagModel setFilter:filter];
//        
//        [[SHLocationManager getInstance] addressOfCurrentLocationSuccess:^(SHLocationManager *manager, SHAddress *address)
//            {
//            self.location = address;
//            
//            if (self.selectedSegment == 0 || self.selectedSegment == 1)
//            {
//            self.fetchedResultsController = self.shoutModel.offerShouts;
//            [self.shoutModel refreshStreamForLocation:self.location ofType:self.selectedSegment];
//            }else{
//            self.isSearchMode = NO;
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
//            ^{
//            [self.topTagModel refreshTopTagsForLocation:self.location];
//            });
//            }
//            } failure:^(SHLocationManager *manager, NSError *error, SHAddress *userAddress) {
//            self.location = userAddress;
//            if (self.selectedSegment == 0 || self.selectedSegment == 1)
//            {
//            self.fetchedResultsController = self.shoutModel.offerShouts;
//            [self.shoutModel refreshStreamForLocation:self.location ofType:self.selectedSegment];
//            }else{
//            self.isSearchMode = NO;
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
//            ^{
//            [self.topTagModel refreshTopTagsForLocation:self.location];
//            });
//            }
//            }];
        
    }
    
    func updateSubtitleLabel() {
        if let location = self.viewController.location {
            self.viewController.subTitleLabel?.text = String(format: "%@, %@, %@", arguments: [location.city, location.state, location.country])
            self.viewController.subTitleLabel?.sizeToFit()
            if var frame = self.viewController.subTitleLabel?.frame , let frameT = self.viewController.navigationItem.titleView?.frame {
                frame.origin.x = frameT.size.width / 2 - frame.size.width / 2
                self.viewController.subTitleLabel?.frame = frame
            }
            
        }
    }
    
    // MARK Private
    private func setupNavigationBar() {
        let titleLabel = UILabel(frame: CGRectMake(0, 0, 0, 0))
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.backgroundColor = UIColor.clearColor()
        titleLabel.textColor = UIColor.darkTextColor()
        titleLabel.font = UIFont.boldSystemFontOfSize(17)
        titleLabel.text = self.viewController.title
        titleLabel.sizeToFit()
        
        let subTitleLabel = UILabel(frame: CGRectMake(0, 22, 0, 0))
        subTitleLabel.textAlignment = NSTextAlignment.Center
        subTitleLabel.backgroundColor = UIColor.clearColor()
        subTitleLabel.textColor = UIColor.whiteColor()
        subTitleLabel.font = UIFont.systemFontOfSize(12)
        if let location = SHAddress.getUserOrDeviceLocation() {
            subTitleLabel.text = String(format: "%@, %@, %@", arguments: [location.city, location.state, location.country])
            subTitleLabel.sizeToFit()
        }
        let twoLineTitleView = UIView(frame: CGRectMake(0, 0, max(subTitleLabel.frame.size.width, titleLabel.frame.size.width), 30))
        twoLineTitleView.addSubview(titleLabel)
        twoLineTitleView.addSubview(subTitleLabel)
        let widthDiff = subTitleLabel.frame.size.width - titleLabel.frame.size.width
        if(widthDiff > 0) {
            var frame = titleLabel.frame
            frame.origin.x = widthDiff / 2
            titleLabel.frame = CGRectIntegral(frame)
        } else {
            var frame = subTitleLabel.frame
            frame.origin.x = abs(widthDiff) / 2
            subTitleLabel.frame =  CGRectIntegral(frame)
        }
        self.viewController.navigationItem.titleView =  twoLineTitleView
    }
    
    private func getLatestShouts() {
        self.viewController.searchQuery = nil
        self.viewController.searchBar.text = ""
        self.viewController.mode = "Search"
        self.viewController.searchBar.placeholder = self.viewController.mode
        self.viewController.loading = true
        self.viewController.loadMoreView.showNoMoreContent()
        self.viewController.shouts = []
        self.viewController.tableView.reloadData()
        self.updateFooterView()
        self.updateFooterLabel()
        self.shoutApi.resetPage()
        if let location = self.viewController.location {
            self.shoutApi.refreshStreamForLocation(location, type: self.viewController.shoutType, cacheResponse: { (shShoutMeta) -> Void in
                self.updateUI(shShoutMeta)
                }, completionHandler: { (response) -> Void in
                    self.viewController.tableView.pullToRefreshView.stopAnimating()
                    switch(response.result) {
                    case .Success(let result):
                        self.updateRefreshView()
                        self.updateUI(result)
                    case .Failure(let error):
                        log.error("Error while getting stream \(error.localizedDescription)")
                    }
            })
        }
    }
    
    private func updateUI(shShoutMeta: SHShoutMeta) {
        self.shShoutMeta = shShoutMeta
        if self.shoutApi.getCurrentPage() == 1 {
            self.viewController.shouts = []
        }
        self.viewController.shouts += shShoutMeta.results
        self.viewController.tableView.reloadData()
        self.updateFooterView()
    }
    
}
