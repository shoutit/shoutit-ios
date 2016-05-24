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
import Pusher

final class ConversationListTableViewController: UITableViewController {
    
    private struct CellIdentifiers {
        static let directConversation = "directConversationCellIdentifier"
        static let groupConversation = "groupConversationCellIdentifier"
    }
    
    // UI
    lazy var tableViewPlaceholder: TableViewPlaceholderView = {[unowned self] in
        let view = NSBundle.mainBundle().loadNibNamed("TableViewPlaceholderView", owner: nil, options: nil)[0] as! TableViewPlaceholderView
        view.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: self.tableView.bounds.height)
        return view
        }()
    
    // dependencies
    var viewModel: ChatsListViewModel!
    weak var flowDelegate: FlowController?
    
    // RX
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil)
        
        setupPullToRefresh()
        registerReusables()
        setupRX()
        subscribeToPusherChannel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableViewPlaceholder.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: tableView.bounds.height)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        refreshConversationList()
    }
    
    // MARK: - Setup
    
    private func subscribeToPusherChannel() {
        
        Account.sharedInstance
            .pusherManager
            .mainChannelSubject
            .subscribeNext { [weak self] (event) in
                self?.viewModel.handlePusherEvent(event)
            }
            .addDisposableTo(disposeBag)
    }
    
    private func registerReusables() {
        tableView.register(ProfileTableViewCell.self)
    }
    
    private func setupPullToRefresh() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(ConversationListTableViewController.refreshConversationList), forControlEvents: .ValueChanged)
    }
    
    private func setupRX() {
        
        viewModel.pager.state
            .asObservable()
            .subscribeNext {[weak self] (state) in
                switch state {
                case .Idle:
                    break
                case .Loading:
                    self?.tableView.tableHeaderView = self?.tableViewPlaceholder
                    self?.tableViewPlaceholder.showActivity()
                case .Loaded, .LoadedAllContent, .LoadingMore:
                    self?.tableView.tableHeaderView = nil
                    self?.refreshControl?.endRefreshing()
                case .Refreshing:
                    self?.tableView.tableHeaderView = nil
                case .NoContent:
                    self?.tableView.tableHeaderView = self?.tableViewPlaceholder
                    self?.tableViewPlaceholder.showMessage(NSLocalizedString("You can start new conversation in shout details or user profile.", comment: ""), title: NSLocalizedString("No conversations to show", comment: ""))
                    self?.refreshControl?.endRefreshing()
                case .Error(let error):
                    self?.tableView.tableHeaderView = self?.tableViewPlaceholder
                    self?.tableViewPlaceholder.showMessage(error.sh_message)
                    self?.refreshControl?.endRefreshing()
                }
                self?.tableView.reloadData()
            }
            .addDisposableTo(disposeBag)
    }
    
    // MARK: - Actions
    
    func refreshConversationList() {
        viewModel.pager.refreshContent()
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let models = viewModel.pager.getCellViewModels() else { return 0 }
        return models.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let models = viewModel.pager.getCellViewModels() else { preconditionFailure() }
        let conversation = models[indexPath.row]
        let cell: ConversationTableViewCell
        switch conversation.type() {
        case .Chat:
            cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifiers.directConversation, forIndexPath: indexPath) as! ConversationTableViewCell
        default:
            cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifiers.groupConversation, forIndexPath: indexPath) as! ConversationTableViewCell
        }
        cell.bindWithConversation(conversation)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let cells = viewModel.pager.getCellViewModels() else { return }
        let conversation = cells[indexPath.row]
        flowDelegate?.showConversation(.Created(conversation: conversation))
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.bounds.height > scrollView.contentSize.height - 50 {
            viewModel.pager.fetchNextPage()
        }
    }
}
