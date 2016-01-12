//
//  SHStreamTableViewModel.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 14/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit
import Foundation

class SHStreamTableViewModel: NSObject, TableViewControllerModelProtocol, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    private var viewController: SHStreamTableViewController
    private var spinner: UIActivityIndicatorView?
    private var shShoutMeta: SHShoutMeta?
    private var pulltoRefreshLabel: UILabel?
    private var tag: SHTag?
    
    required init(viewController: SHStreamTableViewController) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        // Get Latest Shouts
        getLatestShouts()
        updateSubtitleLabel()
        if let tagName = self.viewController.tagName {
            self.getTagProfile(tagName)
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "locationUpdated:", name: Constants.Notification.LocationUpdated, object: nil)
        //ShoutDeleted Notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("shoutDeleted:"), name: "shoutDeleted", object: nil)
    }
    
    func shoutDeleted(notification: NSNotification) {
        guard let _ = notification.object else {
            return
        }
        self.pullToRefresh()
    }
    
    func locationUpdated(notification: NSNotification) {
        self.viewController.location = SHAddress.getUserOrDeviceLocation()
        getLatestShouts()
        setupNavigationBar()
    }
    
    func viewWillAppear() {
        self.updateFooterView()
        self.viewController.searchBar.hidden = false
    }
    
    func viewDidAppear() {
        self.viewController.tableView.infiniteScrollingView.hidden = true
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
        self.viewController.shoutApi.resetPage()
        if let location = self.viewController.location, let query = self.viewController.searchQuery {
            self.viewController.shoutApi.searchStreamForLocation(location, type: self.viewController.shoutType, query: query, cacheResponse: { (shShoutMeta) -> Void in
                self.updateUI(shShoutMeta)
                }, completionHandler: { (response) -> Void in
                    self.viewController.tableView.pullToRefreshView.stopAnimating()
                    self.viewController.tableView.infiniteScrollingView.stopAnimating()
                    switch response.result {
                    case .Success(let result):
                        self.updateFooterLabel()
                        self.updateRefreshView()
                        self.updateFooterView()
                        self.updateUI(result)
                    case .Failure(let error):
                        log.error("Error getting values \(error.localizedDescription)")
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
    
    // tableView
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0{
            if (self.viewController.streamType == StreamType.Tag) {
                let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCell.SHStreamTagTableViewCell, forIndexPath: indexPath) as! SHStreamTagTableViewCell
                if let tag = self.tag {
                    cell.setTagCell(tag, viewController: self.viewController)
                    self.viewController.searchBar.hidden = true
                    let titleLabel = UILabel(frame: CGRectMake(0, 0, 0, 0))
                    titleLabel.textAlignment = NSTextAlignment.Center
                    titleLabel.backgroundColor = UIColor.clearColor()
                    titleLabel.textColor = UIColor.darkTextColor()
                    titleLabel.font = UIFont.boldSystemFontOfSize(17)
                    titleLabel.text = self.viewController.tagName
                    titleLabel.sizeToFit()
                    let tagNavigationView = UIView(frame: CGRect(x: 0, y: 10, width: titleLabel.frame.width, height: titleLabel.frame.height))
                    tagNavigationView.addSubview(titleLabel)
                    self.viewController.navigationItem.titleView = tagNavigationView
                }
                //cell.setTagCell(shout.)
                return cell
            }
        }
        
        let shout: SHShout
        if self.viewController.streamType == .Tag {
            shout = self.viewController.shouts[indexPath.row - 1]
        } else {
            shout = self.viewController.shouts[indexPath.row]
        }
        
        if shout.type == .Request {
                let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCell.SHRequestImageTableViewCell, forIndexPath: indexPath) as! SHRequestImageTableViewCell
                cell.setShout(shout)
                return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCell.SHShoutTableViewCell, forIndexPath: indexPath) as! SHShoutTableViewCell
            cell.setShout(shout)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let shout: SHShout
        if self.viewController.streamType == .Tag {
            if indexPath.row == 0 {
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
                return
            }
            shout = self.viewController.shouts[indexPath.row - 1]
        } else {
            shout = self.viewController.shouts[indexPath.row]
        }
        if let detailView = UIStoryboard.getStream().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHSHOUTDETAIL) as? SHShoutDetailTableViewController {
            detailView.title = shout.title
            if let shoutId = shout.id {
                detailView.getShoutDetails(shoutId)
            }
            // [detailView getDetailShouts:self.fetchedResultsController[indexPath.row]];
            self.viewController.navigationController?.pushViewController(detailView, animated: true)
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let shout: SHShout
        if (self.viewController.streamType == StreamType.Tag) {
            if indexPath.row == 0 {
                return 100
            }
            shout = self.viewController.shouts[indexPath.row - 1]
        } else {
            shout = self.viewController.shouts[indexPath.row]
        }
        if (shout.type == .Offer) {
            return 100
        } else {
            return 348
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (self.viewController.streamType == StreamType.Tag) {
            return self.viewController.shouts.count + 1
        }
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
            self.viewController.shoutApi.loadShoutStreamNextPageForLocation(location, type: self.viewController.shoutType, query: self.viewController.searchQuery, cacheResponse: { (shShoutMeta) -> Void in
                // Do Nothing
                }, completionHandler: { (response) -> Void in
                    self.viewController.tableView.pullToRefreshView.stopAnimating()
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
    func setupNavigationBar() {
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
        }else if let city = NSUserDefaults.standardUserDefaults().stringForKey("MyLocality"), country = NSUserDefaults.standardUserDefaults().stringForKey("MyCountry"){
            subTitleLabel.text = String(format: "%@, %@", arguments: [city, country])
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
    
    func getLatestShouts() {
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
        self.viewController.shoutApi.resetPage()
      //  if let location = self.viewController.location {
            self.viewController.shoutApi.refreshStreamForLocation(self.viewController.location, type: self.viewController.shoutType, cacheResponse: { (shShoutMeta) -> Void in
                self.updateUI(shShoutMeta)
                }, completionHandler: { (response) -> Void in
                    self.viewController.tableView.pullToRefreshView.stopAnimating()
                    self.viewController.tableView.infiniteScrollingView.stopAnimating()
                    switch(response.result) {
                    case .Success(let result):
                        self.updateRefreshView()
                        self.updateFooterLabel()
                        self.updateUI(result)
                    case .Failure(let error):
                        log.error("Error while getting stream \(error.localizedDescription)")
                    }
            })
      //  }
    }
    
    private func updateUI(shShoutMeta: SHShoutMeta) {
        self.shShoutMeta = shShoutMeta
        if self.viewController.shoutApi.getCurrentPage() == 1 {
            self.viewController.shouts = []
        }
        self.viewController.shouts += shShoutMeta.results
      //  self.viewController.tableView.reloadData()
        let range = NSMakeRange(0, self.viewController.tableView.numberOfSections)
        let sections = NSIndexSet(indexesInRange: range)
        self.viewController.tableView.reloadSections(sections, withRowAnimation: .Bottom)
        
        if Constants.Common.SH_PAGE_SIZE != shShoutMeta.results.count {
            self.viewController.loading = false
            self.viewController.loadMoreView.showNoMoreContent()
            self.updateFooterLabel()
        }
        
        self.updateFooterView()
    }
    
    private func getTagProfile(tagName: String) {
        self.viewController.tagsApi.loadProfileForTag(tagName, cacheResponse: { (shTag) -> Void in
            //
            }) { (response) -> Void in
                switch(response.result) {
                    case .Success(let result):
                        self.tag = result
                    self.viewController.tableView.reloadData()
                       // self.viewController.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
                    case .Failure(let error):
                        log.error("Error getting Tag Profile \(error.localizedDescription)")
                }
        }
    
    }
    
}
