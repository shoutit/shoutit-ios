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
    
    required init(viewController: SHCategoryTagsViewController) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        getTagsForCategory("")
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
    
    func viewWillDisappear() {
        if(self.viewController.navigationController?.viewControllers.indexOf(self.viewController) == NSNotFound) {
            let indexes = NSMutableIndexSet()
            for key in self.viewController.selectedDict.keys {
                if let dictKey = self.viewController.selectedDict[key] as? Int {
                    if(dictKey == 1) {
                       indexes.addIndex(dictKey)
                    }
                    
                }
            }
            if let block = self.viewController.selectedBlock {
                block(self.viewController.fetchedResultsController.objectsAtIndexes(indexes))
            }
//            if var block = self.viewController.selectedBlock {
//                block = (self.viewController.fetchedResultsController.objectAtIndex(dictKey))
//            }
//            if((self.viewController.selectedBlock) != nil) {
//               if(self.selectedBlock) self.selectedBlock([[self.fetchedResultsController objectsAtIndexes:indexs] mutableCopy]);
        }
        
    }
    
    func viewDidDisappear() {
        
    }
    
    func destroy() {
        
    }
    
    func getTagsForCategory (category: String) {
        self.viewController.category = category
        self.viewController.loading = true
       // self.viewController.loadMoreView.showNoMoreContent()
        self.viewController.lastResultCount = 0
        self.viewController.fetchedResultsController = []
        self.viewController.tableView.reloadData()
        //[self updateFooterView];
       // self.updateFooterLabel()
        
        let filter = SHFilter()
        filter.isApplied = true
        filter.category = category
        filter.type = "Tag"
        self.viewController.shTagsApi.filter = filter
       // if(self.viewController.hardCodedTags.count > 0) {
            self.viewController.shTagsApi.refreshTagsWithQuery("", cacheResponse: { (shTagMeta) -> Void in
                
                self.updateUI(shTagMeta)
                }, completionHandler: { (response) -> Void in
                    if(response.result.isSuccess) {
                        if let shTagMeta = response.result.value {
                            self.updateUI(shTagMeta)
                        }
                        
                    } else {
                        // Do Nothing
                    }
            })
       // }

    }
    
    func updateUI(shShoutMeta: SHTagMeta) {
        if shShoutMeta.results.count > 0 {
            self.viewController.fetchedResultsController = shShoutMeta.results
            self.viewController.tableView.reloadData()
        }
    }
    
    func updateFooterLabel () {
        if(self.viewController.fetchedResultsController.count == 1) {
            self.viewController.loadMoreView.loadingLabel.text = String(format: "%d %@", arguments: [self.viewController.fetchedResultsController.count, NSLocalizedString("Tag", comment: "Tag") ])
        } else {
            self.viewController.loadMoreView.loadingLabel.text = String(format: "%d %@", arguments: [self.viewController.fetchedResultsController.count, NSLocalizedString("Tags", comment: "Tags")])
        }
    }
    
    // mark - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewController.fetchedResultsController.count
    }
    
    func triggerLoadMore() {
        if let loading = self.viewController.loading {
            if(!loading && self.viewController.shTagsApi.isMore()) {
                self.viewController.lastResultCount = self.viewController.fetchedResultsController.count
                self.viewController.loading = true
                self.viewController.loadMoreView.showLoading()
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
                    self.viewController.shTagsApi.loadTagsNextPageWithQuery("", cacheResponse: { (shTagMeta) -> Void in
                        // Do Nothing
                        }, completionHandler: { (response) -> Void in
                            // Do Nothing
                    })
                })
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(self.viewController.hardCodedTags.count == 0) {
            if(indexPath.row >= (self.viewController.fetchedResultsController.count - Constants.Common.SH_PAGE_SIZE / 3 )) {
                self.triggerLoadMore()
            }
        }
        
        let tag = self.viewController.fetchedResultsController[indexPath.row]
        if let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCell.SHTopTagTableViewCell, forIndexPath: indexPath) as? SHTopTagTableViewCell {
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
        return UITableViewCell()
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
        self.viewController.navigationController?.popViewControllerAnimated(true)
    }
    
}
