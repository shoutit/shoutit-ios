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

final class ConversationListTableViewController: UITableViewController {
    
    fileprivate struct CellIdentifiers {
        static let directConversation = "directConversationCellIdentifier"
        static let groupConversation = "groupConversationCellIdentifier"
    }
    
    // UI
    lazy var tableViewPlaceholder: TableViewPlaceholderView = {[unowned self] in
        let view = Bundle.main.loadNibNamed("TableViewPlaceholderView", owner: nil, options: nil)?[0] as! TableViewPlaceholderView
        view.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: self.tableView.bounds.height)
        return view
        }()
    
    // dependencies
    var viewModel: ChatsListViewModel!
    weak var flowDelegate: FlowController?
    
    // RX
    fileprivate let disposeBag = DisposeBag()
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshConversationList()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.refreshControl?.endRefreshing()
    }
    
    // MARK: - Setup
    
    fileprivate func subscribeToPusherChannel() {
        
        
        Account.sharedInstance
            .pusherManager
            .mainChannelSubject
            .subscribeNext { [weak self] (event) in
                self?.viewModel.handlePusherEvent(event)
            }
            .addDisposableTo(disposeBag)
    }
    
    fileprivate func registerReusables() {
        tableView.register(ProfileTableViewCell.self)
    }
    
    fileprivate func setupPullToRefresh() {
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(ConversationListTableViewController.refreshConversationList), for: .valueChanged)
    }
    
    fileprivate func setupRX() {
        
        viewModel.pager.state
            .asObservable()
            .subscribeNext {[weak self] (state) in
                switch state {
                case .idle:
                    break
                case .loading:
                    self?.tableView.tableHeaderView = self?.tableViewPlaceholder
                    self?.tableViewPlaceholder.showActivity()
                case .loaded, .loadedAllContent, .loadingMore:
                    self?.tableView.tableHeaderView = nil
                    self?.refreshControl?.endRefreshing()
                case .refreshing:
                    self?.tableView.tableHeaderView = nil
                case .noContent:
                    self?.tableView.tableHeaderView = self?.tableViewPlaceholder
                    self?.tableViewPlaceholder.showMessage(NSLocalizedString("You can start new conversation in shout details or user profile.", comment: ""), title: NSLocalizedString("No conversations to show", comment: "No conversations message"))
                    self?.refreshControl?.endRefreshing()
                case .error(let error):
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
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let models = viewModel.pager.getCellViewModels() else { return 0 }
        return models.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let models = viewModel.pager.getCellViewModels() else { preconditionFailure() }
        let conversation = models[indexPath.row]
        let cell: ConversationTableViewCell
        switch conversation.type() {
        case .Chat:
            cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.directConversation, for: indexPath) as! ConversationTableViewCell
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: CellIdentifiers.groupConversation, for: indexPath) as! ConversationTableViewCell
        }
        cell.bindWithConversation(conversation)
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cells = viewModel.pager.getCellViewModels() else { return }
        let conversation = cells[indexPath.row]
        flowDelegate?.showConversation(.created(conversation: conversation))
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.bounds.height > scrollView.contentSize.height - 50 {
            viewModel.pager.fetchNextPage()
        }
    }
}
