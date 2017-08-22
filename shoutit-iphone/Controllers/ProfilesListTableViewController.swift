//
//  ProfilesListTableViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import FBSDKShareKit
import Social
import RxSwift
import ShoutitKit

class ProfilesListTableViewController: UITableViewController {
    
    // UI
    lazy var tableViewPlaceholder: TableViewPlaceholderView = {[unowned self] in
        let view = Bundle.main.loadNibNamed("TableViewPlaceholderView", owner: nil, options: nil)?[0] as! TableViewPlaceholderView
        view.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: self.tableView.bounds.height)
        return view
        }()
    
    // dependencies
    var viewModel: ProfilesListViewModel!
    var eventHandler: ProfilesListEventHandler!
    var dismissAfterSelection = false
    var autoDeselct = false
    var cellConfigurator : ProfileCellConfigurator! = ProfileCellConfigurator()
    
    // RX
    fileprivate let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        precondition(viewModel != nil)
        assert(eventHandler != nil)

        registerReusables()
        setupRX()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.pager.refreshContent()
    }
    
    override func prefersTabbarHidden() -> Bool {
        return true
    }
    
    // MARK: - Setup
    
    fileprivate func registerReusables() {
        tableView.register(ProfileTableViewCell.self)
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
                case .loaded, .loadedAllContent, .loadingMore, .refreshing:
                    self?.tableView.tableHeaderView = nil
                case .noContent:
                    self?.tableView.tableHeaderView = self?.tableViewPlaceholder
                    self?.tableViewPlaceholder.showMessage(NSLocalizedString("No users were found", comment: "User search empty message"))
                case .error(let error):
                    self?.tableView.tableHeaderView = self?.tableViewPlaceholder
                    self?.tableViewPlaceholder.showMessage(error.sh_message)
                }
                self?.tableView.reloadData()
            }
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
        let cell: ProfileTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        let cellModel = cells[indexPath.row]
        
        cellConfigurator.configureCell(cell, cellViewModel: cellModel, showsListenButton: viewModel.showsListenButtons)
        
        guard viewModel.showsListenButtons else {
            cell.listenButton.isHidden = true
            return cell
        }
        
        cell.listenButton.rx_tap.asDriver().driveNext {[weak self, weak cellModel] in
            guard let `self` = self else { return }
            guard self.checkIfUserIsLoggedInAndDisplayAlertIfNot() else { return }
            cellModel?.toggleIsListening()
                .observeOn(MainScheduler.instance)
                .subscribe({[weak cell] (event) in
                    switch event {
                    case .next(let (listening, successMessage, newListnersCount, error)):
                        let listenButtonImage = listening ? UIImage.profileStopListeningIcon() : UIImage.profileListenIcon()
                        cell?.listenButton.setImage(listenButtonImage, for: UIControlState())
                        if let message = successMessage {
                            self.showSuccessMessage(message)
                            
                            guard let newListnersCount =  newListnersCount, let profile = cellModel?.profile  else {
                                return
                            }
                            
                            do {
                                let newProfile : Profile = profile.copyWithListnersCount(newListnersCount, isListening: listening)
                                
                                try self.viewModel.pager.replaceItemAtIndex(indexPath.row, withItem: newProfile)
                                
                                self.tableView.beginUpdates()
                                self.tableView.reloadRows(at: [indexPath], with: .automatic)
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            guard let cells = viewModel.pager.getCellViewModels() else { assertionFailure(); return; }
            let cellViewModel = cells[indexPath.row]
            eventHandler.handleUserDidTapProfile(cellViewModel.profile)
        
        if autoDeselct {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        if dismissAfterSelection {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.bounds.height > scrollView.contentSize.height - 50 {
            viewModel.pager.fetchNextPage()
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sectionTitle
    }
    
    fileprivate func inviteFriendsByFacebookUsingCode(_ code: InvitationCode) {
        let inviteContent = FBSDKAppInviteContent()
        
        inviteContent.appLinkURL = URL(string: Constants.Invite.facebookURL)
        inviteContent.promotionCode = code.code
        inviteContent.promotionText = NSLocalizedString("Join Shoutit", comment: "")
        
        FBSDKAppInviteDialog.show(from: self, with: inviteContent, delegate: self)
    }
    
}

extension ProfilesListTableViewController : FBSDKAppInviteDialogDelegate {
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: NSError!) {
        
    }
    
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [AnyHashable: Any]!) {
        
    }

}
