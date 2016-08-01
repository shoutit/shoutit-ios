//
//  AdminsListTableViewController.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 24.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import ShoutitKit

final class AdminsListTableViewController: UITableViewController {
    
    // UI
    lazy var tableViewPlaceholder: TableViewPlaceholderView = {[unowned self] in
        let view = NSBundle.mainBundle().loadNibNamed("TableViewPlaceholderView", owner: nil, options: nil)[0] as! TableViewPlaceholderView
        view.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: self.tableView.bounds.height)
        return view
        }()
    
    var viewModel: AdminsListViewModel!
    weak var flowDelegate: FlowController?
    private let cellConfigurator = ProfileCellConfigurator()
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil)
        registerReusables()
        setupRX()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.pager.refreshContent()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if tableViewPlaceholder.frame.size != tableView.bounds.size {
            tableViewPlaceholder.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: self.tableView.bounds.height)
            tableView.tableHeaderView = tableView.tableHeaderView
        }
    }
    
    // MARK: Setup
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
                    self?.tableViewPlaceholder.showMessage(NSLocalizedString("There are no pages available in your country", comment: "Public pages empty message"))
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
        let cell: ProfileTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        let cellModel = cells[indexPath.row]
        
        cellConfigurator.configureCell(cell, cellViewModel: cellModel, showsListenButton: true)
        
        cell.listenButton.rx_tap.asDriver().driveNext {[weak self, weak cellModel] in
            guard let `self` = self else { return }
            guard self.checkIfUserIsLoggedInAndDisplayAlertIfNot() else { return }
            cellModel?.toggleIsListening()
                .observeOn(MainScheduler.instance)
                .subscribe({[weak cell] (event) in
                    switch event {
                    case .Next(let (listening, successMessage, newListnersCount, error)):
                        let listenButtonImage = listening ? UIImage.profileStopListeningIcon() : UIImage.profileListenIcon()
                        cell?.listenButton.setImage(listenButtonImage, forState: .Normal)
                        if let message = successMessage {
                            self.showSuccessMessage(message)
                            
                            guard let newListnersCount =  newListnersCount, profile = cellModel?.profile  else {
                                return
                            }
                            
                            do {
                                let newProfile : Profile = profile.copyWithListnersCount(newListnersCount)
                                
                                try self.viewModel.pager.replaceItemAtIndex(indexPath.row, withItem: newProfile)
                                
                                self.tableView.beginUpdates()
                                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
                                self.tableView.endUpdates()
                            } catch let error {
                                print(error)
                            }
                        }  else if let error = error {
                            self.showError(error)
                        }
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
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        guard let cells = viewModel.pager.getCellViewModels() else { assertionFailure(); return; }
        let cellViewModel = cells[indexPath.row]
        handleProfileTapped(cellViewModel.profile)
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.bounds.height > scrollView.contentSize.height - 50 {
            viewModel.pager.fetchNextPage()
        }
    }
}

private extension AdminsListTableViewController {
    
    func handleProfileTapped(profile: Profile) {
        if case .Page(let pageUser, _)? = Account.sharedInstance.loginState where profile.id == pageUser.id {
            showProfile(profile)
        } else {
            showActionSheetWithAdminProfile(profile)
        }
    }
    
    func showActionSheetWithAdminProfile(profile: Profile) {
        let showProfileActionString = NSLocalizedString("View Profile", comment: "Admins list action sheet option")
        let removeAdminActionString = NSLocalizedString("Remove Admin", comment: "Admins list action sheet option")
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let showProfileAction = UIAlertAction(title: showProfileActionString, style: .Default) { [weak self] (_) in
            self?.showProfile(profile)
        }
        let removeAdminAction = UIAlertAction(title: removeAdminActionString, style: .Default) { [weak self] (_) in
            self?.removeAdmin(profile)
        }
        let cancelAction = UIAlertAction(title: LocalizedString.cancel, style: .Cancel, handler: nil)
        
        actionSheet.addAction(showProfileAction)
        actionSheet.addAction(removeAdminAction)
        actionSheet.addAction(cancelAction)
        
        presentViewController(actionSheet, animated: true, completion: nil)
    }
    
    func showProfile(profile: Profile) {
        flowDelegate?.showProfile(profile)
    }
    
    func removeAdmin(profile: Profile) {
        viewModel.removeAdmin(profile)
    }
}
