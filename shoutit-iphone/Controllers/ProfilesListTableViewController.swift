//
//  ProfilesListTableViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class ProfilesListTableViewController: UITableViewController {
    
    // UI
    lazy var tableViewPlaceholder: TableViewPlaceholderView = {[unowned self] in
        let view = NSBundle.mainBundle().loadNibNamed("TableViewPlaceholderView", owner: nil, options: nil)[0] as! TableViewPlaceholderView
        view.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: self.tableView.bounds.height)
        return view
        }()
    
    // dependencies
    var viewModel: ProfilesListViewModel!
    var eventHandler: ProfilesListEventHandler!
    var dismissAfterSelection = false
    var cellConfigurator : ProfileCellConfigurator! = ProfileCellConfigurator()
    
    // RX
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil)
        assert(eventHandler != nil)
        
        registerReusables()
        setupRX()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.pager.refreshContent()
    }
    
    override func prefersTabbarHidden() -> Bool {
        return true
    }
    
    // MARK: - Setup
    
    private func registerReusables() {
        tableView.register(ProfileTableViewCell.self)
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
                    self?.tableViewPlaceholder.showMessage(NSLocalizedString("No users were found", comment: "User search empty message"))
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
        
        switch viewModel.pager.state.value {
        case .LoadedAllContent(let cells, _):
            return cells.count
        case .Loaded(let cells, _, _):
            return cells.count
        case .LoadingMore(let cells, _, _):
            return cells.count
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cells: [ProfilesListCellViewModel]
        switch viewModel.pager.state.value {
        case .LoadedAllContent(let c, _):
            cells = c
        case .Loaded(let c, _, _):
            cells = c
        case .LoadingMore(let c, _, _):
            cells = c
        default:
            preconditionFailure()
        }
        
        let cell: ProfileTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        let cellModel = cells[indexPath.row]
        
        cellConfigurator.configureCell(cell, cellViewModel: cellModel, showsListenButton: viewModel.showsListenButtons)
        
        guard viewModel.showsListenButtons else {
            cell.listenButton.hidden = true
            return cell
        }
        
        cell.listenButton.rx_tap.asDriver().driveNext {[weak self, weak cellModel] in
            guard let `self` = self else { return }
            guard self.checkIfUserIsLoggedInAndDisplayAlertIfNot() else { return }
            cellModel?.toggleIsListening().observeOn(MainScheduler.instance).subscribe({[weak cell] (event) in
                switch event {
                case .Next(let (listening, successMessage, error)):
                    let listenButtonImage = listening ? UIImage.profileStopListeningIcon() : UIImage.profileListenIcon()
                    cell?.listenButton.setImage(listenButtonImage, forState: .Normal)
                    if let message = successMessage {
                        self.showSuccessMessage(message)
                    } else if let error = error {
                        self.showError(error)
                    }
                case .Completed:
                    self.viewModel.pager.reloadItemAtIndex(indexPath.row)
                default:
                    break
                }
                }).addDisposableTo(cell.reuseDisposeBag)
        }.addDisposableTo(cell.reuseDisposeBag)
        
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cells: [ProfilesListCellViewModel]
        switch viewModel.pager.state.value {
        case .LoadedAllContent(let c, _):
            cells = c
        case .Loaded(let c, _, _):
            cells = c
        case .LoadingMore(let c, _, _):
            cells = c
        default:
            preconditionFailure()
        }
        let cellViewModel = cells[indexPath.row]
        eventHandler.handleUserDidTapProfile(cellViewModel.profile)
        
        if dismissAfterSelection {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.bounds.height > scrollView.contentSize.height - 50 {
            viewModel.pager.fetchNextPage()
        }
    }
}
