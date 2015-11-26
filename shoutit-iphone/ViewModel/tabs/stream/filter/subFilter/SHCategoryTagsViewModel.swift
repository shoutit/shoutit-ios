//
//  SHCategoryTagsViewModel.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 20/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHCategoryTagsViewModel: NSObject, TableViewControllerModelProtocol, UITableViewDelegate, UITableViewDataSource{
    
    private let viewController: SHCategoryTagsViewController
    private var shTagMeta: SHTagMeta?
    private var spinner: UIActivityIndicatorView?
    
    required init(viewController: SHCategoryTagsViewController) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        if let _ = self.viewController.category {
            self.getTagsForCategory()
        }
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
        spinner?.frame = CGRectMake(0, 0, 24, 24)
        spinner?.startAnimating()
        
        self.viewController.tableView?.pullToRefreshView?.setCustomView(spinner!, forState: 10)
        self.viewController.tableView?.infiniteScrollingView?.hidden = true
        self.viewController.tableView?.infiniteScrollingView?.stopAnimating()
    }
    
    func viewWillDisappear() {
//        if(self.viewController.navigationController?.viewControllers.indexOf(self.viewController) == NSNotFound) {
//            let indexes = NSMutableIndexSet()
//            for key in self.viewController.selectedDict.keys {
//                if let dictKey = self.viewController.selectedDict[key] as? Int where dictKey == 1 {
//                    indexes.addIndex(dictKey)
//                }
//            }
//            if let block = self.viewController.selectedBlock {
//                block(self.viewController.fetchedResultsController.objectsAtIndexes(indexes))
//            }
////            if var block = self.viewController.selectedBlock {
////                block = (self.viewController.fetchedResultsController.objectAtIndex(dictKey))
////            }
////            if((self.viewController.selectedBlock) != nil) {
////               if(self.selectedBlock) self.selectedBlock([[self.fetchedResultsController objectsAtIndexes:indexs] mutableCopy]);
//        }
        
    }
    
    func viewDidDisappear() {
        
    }
    
    func destroy() {
        
    }
    
    func getTagsForCategory() {
        self.viewController.loading = true
        self.viewController.loadMoreView.showNoMoreContent()
        self.viewController.lastResultCount = 0
        self.viewController.fetchedResultsController = []
        self.viewController.tableView.reloadData()
        self.viewController.updateFooterView()
        self.updateFooterLabel()
        
        let filter = SHFilter()
        filter.isApplied = true
        filter.category = self.viewController.category
        filter.type = "Tag"
        self.viewController.shTagsApi.filter = filter
        self.viewController.shTagsApi.reset()
        self.viewController.shTagsApi.refreshTagsWithQuery("", cacheResponse: { (shTagMeta) -> Void in
            
            self.updateUI(shTagMeta)
            }, completionHandler: { (response) -> Void in
                self.viewController.tableView.pullToRefreshView.stopAnimating()
                self.viewController.tableView?.infiniteScrollingView?.stopAnimating()
                if(response.result.isSuccess) {
                    if let shTagMeta = response.result.value {
                        self.updateUI(shTagMeta)
                    }
                    
                } else {
                    // Do Nothing
                }
        })
    }
    
    func updateUI(shTagMeta: SHTagMeta) {
        self.shTagMeta = shTagMeta
        if shTagMeta.results.count > 0 {
            self.viewController.fetchedResultsController = shTagMeta.results
            self.viewController.tableView.reloadData()
        }
        self.viewController.updateFooterView()
        updateFooterLabel()
    }
    
    func updateFooterLabel () {
        if(self.viewController.fetchedResultsController.count == 1) {
            self.viewController.loadMoreView.loadingLabel.text = String(format: "%d %@", arguments: [self.viewController.fetchedResultsController.count, NSLocalizedString("Tag", comment: "Tag") ])
        } else {
            self.viewController.loadMoreView.loadingLabel.text = String(format: "%d %@", arguments: [self.viewController.fetchedResultsController.count, NSLocalizedString("Tags", comment: "Tags")])
        }
    }
    
    func pullToRefresh() {
        getTagsForCategory()
    }
    
    func infiniteScroll() {
        if let shTagsMeta = self.shTagMeta where !shTagsMeta.next.isEmpty {
            self.viewController.loadMoreView.showLoading()
            self.viewController.shTagsApi.loadTagsNextPageWithQuery("", cacheResponse: { (shTagsMeta) -> Void in
                // Do Nothing
                }) { (response) -> Void in
                    self.viewController.tableView.pullToRefreshView.stopAnimating()
                    self.viewController.tableView?.infiniteScrollingView?.stopAnimating()
                    switch (response.result) {
                    case .Success(let result):
                        self.shTagMeta = result
                        self.viewController.tableView.beginUpdates()
                        var insertedIndexPaths: [NSIndexPath] = []
                        let currentCount = self.viewController.fetchedResultsController.count
                        for (index, _) in result.results.enumerate() {
                            insertedIndexPaths += [NSIndexPath(forRow: index + currentCount, inSection: 0)]
                        }
                        self.viewController.fetchedResultsController += result.results as [AnyObject]
                        self.viewController.tableView.insertRowsAtIndexPaths(insertedIndexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
                        self.viewController.tableView.endUpdates()
                    case .Failure(let error):
                        log.error("Error getting tags : \(error.localizedDescription)")
                    }
            }
        } else {
            self.viewController.loadMoreView.showNoMoreContent()
            self.updateFooterLabel()
            self.viewController.updateFooterView()
            self.viewController.tableView?.showsInfiniteScrolling = false
        }
    }
    
    // mark - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewController.fetchedResultsController.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let tag = self.viewController.fetchedResultsController[indexPath.row]
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCell.SHTopTagTableViewCell, forIndexPath: indexPath) as! SHTopTagTableViewCell
        cell.listenButton.hidden = true
        cell.setTagCell(tag as! SHTag)
        if let row = self.viewController.selectedDict["\(indexPath.row)"] as? Int {
            if (row == 1) {
                cell.accessoryType = UITableViewCellAccessoryType.Checkmark
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.None
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if(self.viewController.selectedDict["\(indexPath.row)"] as? Int == 1) {
            self.viewController.selectedDict["\(indexPath.row)"] = 0
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.None
        } else {
            self.viewController.selectedDict["\(indexPath.row)"] = 1
            tableView.cellForRowAtIndexPath(indexPath)?.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        if let block = self.viewController.selectedBlock {
            if let tag = self.viewController.fetchedResultsController[indexPath.row] as? SHTag {
                self.viewController.navigationController?.popViewControllerAnimated(true)
                self.viewController.tableView?.userInteractionEnabled = false
                block([tag])
            }
        }
    }
    
}
