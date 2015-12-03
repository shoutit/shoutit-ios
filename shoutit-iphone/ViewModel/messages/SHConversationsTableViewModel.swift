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
            
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier(<#T##identifier: String##String#>, forIndexPath: <#T##NSIndexPath#>)
//        
//        SHConversationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SHConversationTableViewCell" forIndexPath:indexPath];
//        [cell setConversation:self.fetchedResultsController[indexPath.row]];
//        
//        return cell;
        return UITableViewCell()
    }
    
    
    // Private
    private func refreshConversations () {
        self.viewController.loadMoreView.showNoMoreContent()
        self.conversations = []
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.viewController.tableView.reloadData()
            self.viewController.updateFooterView()
            if(self.conversations.count == 1) {
                self.viewController.loadMoreView.loadingLabel.text = String(format: "%lu %@", arguments: [self.conversations.count, NSLocalizedString("Conversation", comment: "Conversation")])
            } else {
                self.viewController.loadMoreView.loadingLabel.text = String(format: "%lu %@", arguments: [self.conversations.count, NSLocalizedString("Conversations", comment: "Conversations")])
            }
            self.lastTimeStamp = Int(NSDate().timeIntervalSince1970)
            self.lastTimeStamp += 10
            self.shApiConversation.loadConversationsForBeforeDate(self.lastTimeStamp, cacheResponse: { (shConversations) -> Void in
                self.updateUI(shConversations)
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
    
    private func updateUI (conversations: SHConversations) {
       // self.conversations = conversations
        
    }
    
    

}
