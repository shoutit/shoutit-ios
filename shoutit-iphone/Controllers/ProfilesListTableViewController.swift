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
        guard let models = viewModel.pager.getCellViewModels() else { return 0 }
        return models.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        guard let cells = viewModel.pager.getCellViewModels() else { preconditionFailure() }
        let cell: ProfileTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        let cellModel = cells[indexPath.row]
        
        cell.nameLabel.text = cellModel.profile.name
        cell.listenersCountLabel.text = cellModel.listeningCountString()
        cell.thumbnailImageView.sh_setImageWithURL(cellModel.profile.imagePath?.toURL(), placeholderImage: UIImage.squareAvatarPlaceholder())
        
        guard viewModel.showsListenButtons else {
            cell.listenButton.hidden = true
            return cell
        }
        
        let listenButtonImage = cellModel.isListening ? UIImage.profileStopListeningIcon() : UIImage.profileListenIcon()
        cell.listenButton.setImage(listenButtonImage, forState: .Normal)
        cell.listenButton.hidden = cellModel.hidesListeningButton()
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
        guard let cells = viewModel.pager.getCellViewModels() else { assertionFailure(); return; }
        let cellViewModel = cells[indexPath.row]
        eventHandler.handleUserDidTapProfile(cellViewModel.profile)
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.bounds.height > scrollView.contentSize.height - 50 {
            viewModel.pager.fetchNextPage()
        }
    }
}
