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
import MBProgressHUD
import Pusher

protocol ConversationListTableViewControllerFlowDelegate: class, ChatDisplayable {}

final class ConversationListTableViewController: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {

    private var conversations : [Conversation] = []
    
    private let directConversationCellIdentifier = "directConversationCellIdentifier"
    private let groupConversationCellIdentifier = "groupConversationCellIdentifier"
    
    private let disposeBag = DisposeBag()
    private var conversationDisposeBag : DisposeBag?
    private var nextParams : String?
    private var loading = false
    
    weak var flowDelegate: ConversationListTableViewControllerFlowDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MBProgressHUD.showHUDAddedTo(self.tableView, animated: true)
        
        reloadConversationList()
        
        Account.sharedInstance.pusherManager.mainChannelSubject.subscribeNext { [weak self] (event) in
            
            if event.eventType() == .NewMessage {
                guard let message : Message = event.object() else {
                    return
                }
                
                if let conversation = self?.conversationWithId(message.conversationId), idx = self?.conversations.indexOf(conversation) {
                    let updatedConversation = conversation.copyWithLastMessage(message)
                    self?.conversations.removeAtIndex(idx)
                    self?.conversations.insert(updatedConversation, atIndex: idx)
                    self?.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: idx, inSection: 0)], withRowAnimation: .Automatic)
                } else {
                    APIChatsService.conversationWithId(message.conversationId!).subscribeNext({ (conver) in
                        self?.insertNewConversation(conver)
                    }).addDisposableTo((self?.disposeBag)!)
                }
                
            }
            
        }.addDisposableTo(disposeBag)
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(ConversationListTableViewController.reloadConversationList), forControlEvents: .ValueChanged)
        
        self.tableView.emptyDataSetDelegate = self
        self.tableView.emptyDataSetSource = self
    }
    
    func insertNewConversation(conversation: Conversation) {
        var newConversations = conversations
        
        newConversations.append(conversation)
        newConversations = newConversations.unique()
        
        self.conversations = newConversations
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        reloadConversationList()
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: NSLocalizedString("No conversations to show", comment: ""))
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: NSLocalizedString("You can start new conversation in shout details or user profile.", comment: ""))
    }
    
    func reloadConversationList() {
        loading = true
        
        APIChatsService.requestConversations().subscribe(onNext: { [weak self] (response) -> Void in
            self?.loading = false
            
            let conversations = response.results
            
            self?.nextParams = response.beforeParamsString()
            
            // clear existing conversations
            self?.conversations = []
            
            self?.appendConversations(conversations)
            
            MBProgressHUD.hideAllHUDsForView(self?.tableView, animated: true)
        }, onError: { [weak self] (error) -> Void in
            self?.refreshControl?.endRefreshing()
            MBProgressHUD.hideAllHUDsForView(self?.tableView, animated: true)
        }, onCompleted: nil , onDisposed: nil).addDisposableTo(disposeBag)
    }
    
    func appendConversations(cons: [Conversation]) {
        self.conversations = (self.conversations + cons).filter({ (conversation) -> Bool in
            return conversation.users?.count > 1
        }).unique()
        
        self.tableView.reloadData()
        self.refreshControl?.endRefreshing()
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
        if conversations[indexPath.row].type() == .Chat {
            return directConversationCellIdentifier
        }
        
        return groupConversationCellIdentifier
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let conversation = conversations[indexPath.row]
        
        self.flowDelegate?.showConversation(conversation)
    }
    
    func conversationWithId(conversationId: String?) -> Conversation? {
        guard let conversationId = conversationId else {
            return nil
        }
        
        let candidates = self.conversations.filter { (conversation) -> Bool in
            if conversation.id == conversationId {
                return true
            }
            return false
        }
        
        return candidates.first
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.bounds.height > scrollView.contentSize.height - 50 {
            loadNextPage()
        }
    }
    
    func loadNextPage() {
        if loading {
            return
        }
        
        guard self.nextParams != nil else {
            return
        }
        
        loading = true
        
        APIChatsService.requestMoreConversations(self.nextParams).subscribeOn(MainScheduler.instance).subscribe { [weak self] (event) in
            switch event {
            case .Next(let response):
                let conversations = response.results

                self?.nextParams = response.beforeParamsString()
                
                self?.loading = false
                
                self?.appendConversations(conversations)
            case .Error:
                self?.loading = false
            default:
                break;
            }
            
        }.addDisposableTo(disposeBag)
        
 
    }
}
