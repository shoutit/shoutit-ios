//
//  SHConversationsTableViewModel.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 03/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHConversationsTableViewModel: NSObject, UITableViewDataSource, UITableViewDelegate {
    private let viewController: SHConversationsTableViewController
    private var conversations = [SHConversations]()
    private let shApiConversation = SHApiConversationService()
    private var lastTimeStamp = 0
    private var spinner: UIActivityIndicatorView?
    
    required init(viewController: SHConversationsTableViewController) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        refreshConversations()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("receivedMessage:"), name: Constants.Notification.kMessagePushNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("receivedMessage:"), name: "kApplicationDidBecomeActive", object: nil)
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
    
    func pullToRefresh() {
        spinner?.startAnimating()
        refreshConversations()
    }
    
    func receivedMessage (notification: NSNotification) {
        self.refreshConversations()
    }
    
    func editConversations (sender: AnyObject) {
        if(self.viewController.tableView.editing) {
            let edit = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: Selector("editConversations:"))
            self.viewController.navigationItem.leftBarButtonItem = edit
            self.viewController.tableView.setEditing(false, animated: true)
        } else {
            let done = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Done, target: self, action: Selector("editConversations:"))
            self.viewController.navigationItem.leftBarButtonItem = done
            self.viewController.tableView.setEditing(true, animated: true)
        }
    }
    
    //tableview
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return UITableViewCellEditingStyle.Delete
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == UITableViewCellEditingStyle.Delete) {
            if let conversationId = self.conversations[indexPath.row].id {
                self.shApiConversation.deleteConversationID(conversationId, completionHandler: { (response) -> Void in
                    if(response.result.isSuccess) {
                        log.verbose("Conversation has been deleted")
                    } else {
                        log.verbose("Conversation has not been deleted")
                    }
                })
            }
            self.conversations.removeAtIndex(indexPath.row)
            //self.viewController.tableView.beginUpdates()
            self.updateBottomNumber()
            //self.viewController.tableView.endUpdates()
        }
        self.viewController.tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.conversations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if self.conversations.count > 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCell.SHConversationTableViewCell, forIndexPath: indexPath) as! SHConversationTableViewCell
            cell.setConversation(self.conversations[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let detailMessage = UIStoryboard.getMessages().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHMESSAGES) as! SHMessagesViewController
       
        if let isRead = self.conversations[indexPath.row].isRead {
            if(!isRead) {
            }
        }
        self.conversations[indexPath.row].isRead = true
        
        detailMessage.title = self.conversations[indexPath.row].about?.title
        if let conversationId = self.conversations[indexPath.row].id {
            detailMessage.conversationID = conversationId
            detailMessage.shout = self.conversations[indexPath.row].about
        }
        self.viewController.navigationController?.pushViewController(detailMessage, animated: true)
    }
    
    func triggerLoadMore () {
        self.viewController.loadMoreView.showLoading()
        self.shApiConversation.loadConversationsNextPage(self.conversations, cacheResponse: { (shConversationsMeta) -> Void in
            //
            }) { (response) -> Void in
                self.viewController.tableView.pullToRefreshView.stopAnimating()
                self.viewController.tableView.infiniteScrollingView.stopAnimating()
                switch(response.result) {
                case .Success(let result):
                    self.viewController.tableView.beginUpdates()
                    var insertedIndexPaths: [NSIndexPath] = []
                    let currentCount = self.conversations.count
                    for (index, _) in result.results.enumerate() {
                        insertedIndexPaths += [NSIndexPath(forRow: index + currentCount, inSection: 0)]
                    }
                    self.conversations += result.results
                    self.viewController.tableView.insertRowsAtIndexPaths(insertedIndexPaths, withRowAnimation: UITableViewRowAnimation.Automatic)
                    self.viewController.tableView.endUpdates()
                case .Failure(let error):
                    log.error("Error getting shout response \(error.localizedDescription)")
                }
                
        }
    }
    
    // Private
    private func refreshConversations () {
        self.viewController.loadMoreView.showNoMoreContent()
        self.conversations = []
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.viewController.tableView.reloadData()
            self.updateFooterView()
            self.updateBottomNumber() 
            self.lastTimeStamp = Int(NSDate().timeIntervalSince1970)
            self.lastTimeStamp += 10
            self.shApiConversation.loadConversationsForBeforeDate(self.lastTimeStamp, cacheResponse: { (shConversationsMeta) -> Void in
                self.updateUI(shConversationsMeta)
                }, completionHandler: { (response) -> Void in
                    self.viewController.tableView.pullToRefreshView.stopAnimating()
                    //self.viewController.tableView.infiniteScrollingView.stopAnimating()
                    switch(response.result) {
                        case .Success(let result):
                            self.updateUI(result)
                        case .Failure(let error):
                            log.error("Refresh conversation failed \(error.localizedDescription)")
                    }
            })
        }
    }
    
    private func updateUI (conversationsMeta: SHConversationsMeta) {
        
        self.conversations = conversationsMeta.results
        self.viewController.tableView.reloadData()
        
        self.updateBottomNumber()
        self.updateFooterView()
    }
    
    private func updateBottomNumber () {
        if(self.conversations.count == 1) {
            self.viewController.loadMoreView.loadingLabel.text = String(format: "%lu %@", arguments: [self.conversations.count, NSLocalizedString("Conversation", comment: "Conversation")])
        } else {
            self.viewController.loadMoreView.loadingLabel.text = String(format: "%lu %@", arguments: [self.conversations.count, NSLocalizedString("Conversations", comment: "Conversations")])
        }
    }
    
    private func updateFooterView() {
        if(self.conversations.count == 0) {
            self.viewController.tableView.tableFooterView = self.viewController.emptyContentView
        } else {
            self.viewController.tableView.tableFooterView = self.viewController.loadMoreView
        }
    }
}
