//
//  SHUserListTableViewModel.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 11/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHUserListTableViewModel: NSObject, UITableViewDataSource, UITableViewDelegate {

    private let viewController: SHUserListTableViewController
    private var userTags = []
    let shApiUser = SHApiUserService()
    
    required init(viewController: SHUserListTableViewController) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        if let username = self.viewController.user?.username, let param = self.viewController.param, let type = self.viewController.type {
        self.requestUsersAndTags(username, param: param, type: type)
        }
    }
    
    func viewWillAppear() {
        
    }
    
    func viewDidAppear() {
        
    }
    
    func viewWillDisappear() {
        
    }
    
    func viewDidDisappear() {
        
    }
    
    func destroy() {
        
    }
    
    func requestUsersAndTags (username: String, param: String, type: String) {
        if (type != "tags") {
            self.viewController.loadMoreView.showLoading()
            shApiUser.loadUsersFor(username, param: param, type: type, page: 1, cacheResponse: { (shUserMeta) -> Void in
                self.updateUI(shUserMeta, shUsersTag: nil)
                }) { (response) -> Void in
                    switch(response.result) {
                    case .Success(let result):
                        self.updateUI(result, shUsersTag: nil)
                    case .Failure(let error):
                        log.error("Error getting the results \(error.localizedDescription)")
                    }
            }
        } else {
            shApiUser.loadUserTags(username, param: param, type: type, page: 1, cacheResponse: { (shTagMeta) -> Void in
                self.updateUI(nil, shUsersTag: shTagMeta)
                }, completionHandler: { (response) -> Void in
                    switch(response.result) {
                    case .Success(let result):
                        self.updateUI(nil, shUsersTag: result)
                    case .Failure(let error):
                        log.error("Error getting the results \(error.localizedDescription)")
                    }
            })
        }
        
    }
    
    // Search Action
    func searchAction() {
        self.userTags = []
        self.viewController.tableView.reloadData()
        self.viewController.loadMoreView.showLoading()
        self.viewController.loadMoreView.loadingLabel.text = ""
        if let searchQuery = self.viewController.searchQuery, let param = self.viewController.param {
            self.shApiUser.searchUserQuery(searchQuery, page: 1, param: param, cacheResponse: { (shUsersMeta) -> Void in
                self.updateUI(shUsersMeta, shUsersTag: nil)
                }) { (response) -> Void in
                    switch(response.result){
                    case .Success(let result):
                        self.updateUI(result, shUsersTag: nil)
                    case .Failure(let error):
                        log.error("Error searching the user \(error.localizedDescription)")
                    }
            }
        }
    }
    
    //#pragma mark - Table view data source
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(self.viewController.type == "users" || self.viewController.param == "listeners") {
            return 55
        } else {
            return 44
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userTags.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(self.viewController.type == "users" || self.viewController.type == nil) {
            return NSLocalizedString("Users", comment: "Users")
        } else {
            return NSLocalizedString("Tags", comment: "Tags")
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(self.userTags[indexPath.row].isKindOfClass(SHUser)) {
            let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCell.SHUserTableViewCell, forIndexPath: indexPath) as! SHUserTableViewCell
            cell.setUser(self.userTags[indexPath.row] as! SHUser)
            return cell
        } else if (self.userTags[indexPath.row].isKindOfClass(SHTag)) {
            let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCell.SHTopTagTableViewCell, forIndexPath: indexPath) as! SHTopTagTableViewCell
            cell.setTagCell(self.userTags[indexPath.row] as! SHTag)
            cell.listenButton.hidden = true
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(self.userTags[indexPath.row].isKindOfClass(SHUser)) {
            let profileViewController = UIStoryboard.getProfile().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHPROFILE) as! SHProfileCollectionViewController
            profileViewController.requestUser(self.userTags[indexPath.row] as! SHUser)
            self.viewController.navigationController?.pushViewController(profileViewController, animated: true)
        } else if (self.userTags[indexPath.row].isKindOfClass(SHTag)) {
            //            SHTagProfileTableViewController* tagViewController = [SHNavigator viewControllerFromStoryboard:@"TagStoryboard" withViewControllerId:@"SHTagProfileTableViewController"];
            //            [tagViewController requestTag:self.fetchedResultsController[indexPath.row]];
            //            [self.navigationController pushViewController:tagViewController animated:YES];
            //
            
        }
    }
    
    private func updateUI(shUsersMeta: SHUsersMeta?, shUsersTag: SHTagMeta?) {
        if let users = shUsersMeta {
            self.userTags = users.users
            self.viewController.tableView.reloadData()
        } else if let tags = shUsersTag {
            self.userTags = tags.tags
            self.viewController.tableView.reloadData()
        }
        self.updateFooterlabel()
        self.updateFooterView()
    }
    
    private func updateFooterlabel() {
        if let param = self.viewController.param, let type = self.viewController.type {
            if(param == "listeners" || type == "users") {
                if(self.userTags.count == 1) {
                    self.viewController.loadMoreView.loadingLabel.text = String(format: "%lu %@", arguments: [Int64(self.userTags.count), NSLocalizedString("User", comment: "User")])
                } else {
                    self.viewController.loadMoreView.loadingLabel.text = String(format: "%lu %@", arguments: [Int64(self.userTags.count), NSLocalizedString("Users", comment: "Users")])
                }
            } else {
                if(self.userTags.count == 1) {
                    self.viewController.loadMoreView.loadingLabel.text = String(format: "%lu %@", arguments: [Int64(self.userTags.count), NSLocalizedString("Tag", comment: "Tag")])
                } else {
                    self.viewController.loadMoreView.loadingLabel.text = String(format: "%lu %@", arguments: [Int64(self.userTags.count), NSLocalizedString("Tags", comment: "Tags")])
                }
            }
        }
    }
    
    private func updateFooterView() {
        if(self.userTags.count == 0) {
            self.viewController.tableView.tableFooterView = self.viewController.emptyContentView
        } else {
            self.viewController.tableView.tableFooterView = self.viewController.loadMoreView
        }
    }
}
