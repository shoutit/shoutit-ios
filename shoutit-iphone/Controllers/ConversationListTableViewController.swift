//
//  ConversationListTableViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 14.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import DZNEmptyDataSet

class ConversationListTableViewController: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {

    private var conversations : [Conversation] = []
    
    private let directConversationCellIdentifier = "directConversationCellIdentifier"
    private let groupConversationCellIdentifier = "groupConversationCellIdentifier"
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reloadConversationList()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "reloadConversationList", forControlEvents: .ValueChanged)
        
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: NSLocalizedString("No conversations to show", comment: ""))
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: NSLocalizedString("You can start new conversation in shout details or user profile.", comment: ""))
    }
    
    func reloadConversationList() {
        APIChatsService.requestConversations().subscribe(onNext: { (conversations) -> Void in
            self.conversations = conversations
            self.tableView.reloadData()
            self.refreshControl?.endRefreshing()
        }, onError: { (error) -> Void in
            self.refreshControl?.endRefreshing()
        }, onCompleted: nil , onDisposed: nil).addDisposableTo(disposeBag)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifierForIndexPath(indexPath), forIndexPath: indexPath) as! ConversationTableViewCell
        
        let conversation = conversations[indexPath.row]
        
        cell.bindWithConversation(conversation)
        
        return cell
    }
    
    func cellIdentifierForIndexPath(indexPath: NSIndexPath) -> String {
        return directConversationCellIdentifier
    }
}
