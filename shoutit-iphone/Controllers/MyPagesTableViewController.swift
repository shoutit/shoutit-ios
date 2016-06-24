//
//  MyPagesTableViewController.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 23.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import ShoutitKit

class MyPagesTableViewController: UITableViewController {
    
    lazy var tableViewPlaceholder: TableViewPlaceholderView = {[unowned self] in
        let view = NSBundle.mainBundle().loadNibNamed("TableViewPlaceholderView", owner: nil, options: nil)[0] as! TableViewPlaceholderView
        view.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: self.tableView.bounds.height)
        return view
    }()
    
    var viewModel: MyPagesViewModel! {
        didSet {
            cellConfigurator = MyPageCellConfigurator(viewModel: viewModel, controller: self)
        }
    }
    weak var flowDelegate: FlowController?
    private var cellConfigurator: MyPageCellConfigurator!
    
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil)
        registerReusables()
        setupRX()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if tableViewPlaceholder.frame.size != tableView.bounds.size {
            tableViewPlaceholder.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: self.tableView.bounds.height)
            tableView.tableHeaderView = tableView.tableHeaderView
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.pager.refreshContent()
    }
    
    // MARK: - Setup
    
    private func registerReusables() {
        tableView.register(MyPageTableViewCell.self)
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
                case .Loaded, .LoadedAllContent, .LoadingMore, .Refreshing:
                    self?.tableView.tableHeaderView = nil
                case .NoContent:
                    self?.tableView.tableHeaderView = self?.tableViewPlaceholder
                    self?.tableViewPlaceholder.showMessage(NSLocalizedString("You have no pages", comment: "My pages empty placeholder text"))
                case .Error(let error):
                    self?.tableView.tableHeaderView = self?.tableViewPlaceholder
                    self?.tableViewPlaceholder.showMessage(error.sh_message)
                }
                self?.tableView.reloadData()
            }
            .addDisposableTo(disposeBag)
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
        guard let cells = viewModel.pager.getCellViewModels() else { preconditionFailure() }
        let cell: MyPageTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        let cellModel = cells[indexPath.row]
        cellConfigurator.configureCell(cell, withViewModel: cellModel)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let cells = viewModel.pager.getCellViewModels() else { assertionFailure(); return; }
        let cellViewModel = cells[indexPath.row]
        showActionSheetForPage(cellViewModel.profile)
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.bounds.height > scrollView.contentSize.height - 50 {
            viewModel.pager.fetchNextPage()
        }
    }
}

private extension MyPagesTableViewController {
    
    func showActionSheetForPage(page: Profile) {
        let viewPageString = NSLocalizedString("View Page", comment: "My pages acttion sheet option")
        let useAsPageString = NSLocalizedString("Use Shoutit as this Page", comment: "My pages acttion sheet option")
        let editPageString = NSLocalizedString("Edit Page", comment: "My pages acttion sheet option")
        
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let viewPageOption = UIAlertAction(title: viewPageString, style: .Default) { [weak self] (_) in
            self?.viewPage(page)
        }
        let useAsPageOption = UIAlertAction(title: useAsPageString, style: .Default) { [weak self] (_) in
            self?.useShoutitAsPage(page)
        }
        let editPageOption = UIAlertAction(title: editPageString, style: .Default) { [weak self] (_) in
            self?.editPage(page)
        }
        let cancelAction = UIAlertAction(title: LocalizedString.cancel, style: .Cancel, handler: nil)
        
        actionSheetController.addAction(viewPageOption)
        actionSheetController.addAction(useAsPageOption)
        actionSheetController.addAction(editPageOption)
        actionSheetController.addAction(cancelAction)
        
        presentViewController(actionSheetController, animated: true, completion: nil)
    }
    
    func viewPage(page: Profile) {
        flowDelegate?.showPage(page)
    }
    
    func useShoutitAsPage(page: Profile) {
        notImplemented()
    }
    
    func editPage(page: Profile) {
        notImplemented()
    }
}
