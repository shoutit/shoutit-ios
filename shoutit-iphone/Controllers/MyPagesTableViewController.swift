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
        let view = Bundle.main.loadNibNamed("TableViewPlaceholderView", owner: nil, options: nil)?[0] as! TableViewPlaceholderView
        view.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: self.tableView.bounds.height)
        return view
    }()
    
    var viewModel: MyPagesViewModel! {
        didSet {
            cellConfigurator = MyPageCellConfigurator(viewModel: viewModel, controller: self)
        }
    }
    weak var flowDelegate: FlowController?
    fileprivate var cellConfigurator: MyPageCellConfigurator!
    
    fileprivate let disposeBag = DisposeBag()
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.pager.refreshContent()
    }
    
    // MARK: - Setup
    
    fileprivate func registerReusables() {
        tableView.register(MyPageTableViewCell.self)
    }
    
    fileprivate func setupRX() {
        
        viewModel.pager.state
            .asObservable()
            .subscribe(onNext: {[weak self] (state) in
                switch state {
                case .idle:
                    break
                case .loading:
                    self?.tableView.tableHeaderView = self?.tableViewPlaceholder
                    self?.tableViewPlaceholder.showActivity()
                case .loaded, .loadedAllContent, .loadingMore, .refreshing:
                    self?.tableView.tableHeaderView = nil
                case .noContent:
                    self?.tableView.tableHeaderView = self?.tableViewPlaceholder
                    self?.tableViewPlaceholder.showMessage(NSLocalizedString("You have no pages", comment: "My pages empty placeholder text"))
                case .error(let error):
                    self?.tableView.tableHeaderView = self?.tableViewPlaceholder
                    self?.tableViewPlaceholder.showMessage(error.sh_message)
                }
                self?.tableView.reloadData()
            })
            .addDisposableTo(disposeBag)
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
        guard let cells = viewModel.pager.getCellViewModels() else { preconditionFailure() }
        let cell: MyPageTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        let cellModel = cells[indexPath.row]
        cellConfigurator.configureCell(cell, withViewModel: cellModel)
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let cells = viewModel.pager.getCellViewModels() else { assertionFailure(); return; }
        let cellViewModel = cells[indexPath.row]
        showActionSheetForPage(cellViewModel.profile)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.bounds.height > scrollView.contentSize.height - 50 {
            viewModel.pager.fetchNextPage()
        }
    }
}

private extension MyPagesTableViewController {
    
    func showActionSheetForPage(_ page: Profile) {
        let viewPageString = NSLocalizedString("View Page", comment: "My pages acttion sheet option")
        let useAsPageString = NSLocalizedString("Use Shoutit as this Page", comment: "My pages acttion sheet option")
        let editPageString = NSLocalizedString("Edit Page", comment: "My pages acttion sheet option")
        
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let viewPageOption = UIAlertAction(title: viewPageString, style: .default) { [weak self] (_) in
            self?.viewPage(page)
        }
        let useAsPageOption = UIAlertAction(title: useAsPageString, style: .default) { [weak self] (_) in
            self?.useShoutitAsPage(page)
        }
        let editPageOption = UIAlertAction(title: editPageString, style: .default) { [weak self] (_) in
            self?.editPage(page)
        }
        let cancelAction = UIAlertAction(title: LocalizedString.cancel, style: .cancel, handler: nil)
        
        actionSheetController.addAction(viewPageOption)
        actionSheetController.addAction(useAsPageOption)
        actionSheetController.addAction(editPageOption)
        actionSheetController.addAction(cancelAction)
        
        present(actionSheetController, animated: true, completion: nil)
    }
    
    func viewPage(_ page: Profile) {
        flowDelegate?.showPage(page)
    }
    
    func useShoutitAsPage(_ page: Profile) {
        showProgressHUD()
        viewModel.fetchPage(page).observeOn(MainScheduler.instance).subscribe {[weak self] (event) in
            self?.hideProgressHUD()
            switch event {
            case .next(let detailedPage):
                Account.sharedInstance.switchToPage(detailedPage)
            case .error(let error):
                self?.showError(error)
            case .completed:
                return
            }
        }.addDisposableTo(disposeBag)
    }
    
    func editPage(_ page: Profile) {
        self.flowDelegate?.showEditPage(page)
        
    }
}
