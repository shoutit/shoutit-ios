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
    
    required init(viewController: SHConversationsTableViewController) {
        self.viewController = viewController
    }
    
    func viewDidLoad() {
        refreshConversations()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("receivedMessage:"), name: "kMessagePushNotification", object: nil)
        let edit = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Edit, target: self, action: Selector("editConversations:"))
        self.viewController.navigationItem.leftBarButtonItem = edit
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
            self.viewController.tableView.beginUpdates()
            self.updateBottomNumber()
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.conversations.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(Constants.TableViewCell.SHConversationTableViewCell, forIndexPath: indexPath) as! SHConversationTableViewCell
        cell.setConversation(self.conversations[indexPath.row])
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let detailMessage = UIStoryboard.getMessages().instantiateViewControllerWithIdentifier(Constants.ViewControllers.SHMESSAGES) as! SHMessagesViewController
       
        if let isRead = self.conversations[indexPath.row].isRead {
            if(isRead) {
            }
        }
        self.conversations[indexPath.row].isRead = true
        
//        detailMessage.title = [[self.fetchedResultsController[indexPath.row] aboutShout]title];
//        [detailMessage getMessages:[self.fetchedResultsController[indexPath.row] conversation_id]];
//        [detailMessage setShout:[self.fetchedResultsController[indexPath.row] aboutShout]];
//        [detailMessage.model setConversation:self.fetchedResultsController[indexPath.row]];
        self.viewController.hidesBottomBarWhenPushed = true
        self.viewController.navigationController?.pushViewController(detailMessage, animated: true)
        self.viewController.hidesBottomBarWhenPushed = false
    }
    
    
    // Private
    private func refreshConversations () {
        self.viewController.loadMoreView.showNoMoreContent()
        self.conversations = []
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.viewController.tableView.reloadData()
            self.viewController.updateFooterView()
            self.updateBottomNumber()
            self.lastTimeStamp = Int(NSDate().timeIntervalSince1970)
            self.lastTimeStamp += 10
            self.shApiConversation.loadConversationsForBeforeDate(self.lastTimeStamp, cacheResponse: { (shConversationsMeta) -> Void in
                self.updateUI(shConversationsMeta)
                }, completionHandler: { (response) -> Void in
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
        updateBottomNumber()
    }
    
    private func updateBottomNumber () {
        if(self.conversations.count == 1) {
            self.viewController.loadMoreView.loadingLabel.text = String(format: "%lu %@", arguments: [self.conversations.count, NSLocalizedString("Conversation", comment: "Conversation")])
        } else {
            self.viewController.loadMoreView.loadingLabel.text = String(format: "%lu %@", arguments: [self.conversations.count, NSLocalizedString("Conversations", comment: "Conversations")])
        }
    }

}
