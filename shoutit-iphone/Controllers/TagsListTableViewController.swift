//
//  TagsListTableViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 23.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import ShoutitKit

final class TagsListTableViewController: UITableViewController {
    
    // UI
    lazy var tableViewPlaceholder: TableViewPlaceholderView = {[unowned self] in
        let view = NSBundle.mainBundle().loadNibNamed("TableViewPlaceholderView", owner: nil, options: nil)[0] as! TableViewPlaceholderView
        view.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: self.tableView.bounds.height)
        return view
        }()
    
    // dependencies
    var viewModel: InterestsTagsListViewModel!
    weak var flowDelegate: FlowController?
    
    // RX
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
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
        let cellViewModel = cells[indexPath.row]
        let listenButtonImage = cellViewModel.isListening ? UIImage.profileStopListeningIcon() : UIImage.profileListenIcon()
        
        cell.nameLabel.text = cellViewModel.tag.name
        cell.listenersCountLabel.text = cellViewModel.listeningCountString()
        cell.thumbnailImageView.sh_setImageWithURL(cellViewModel.tag.imagePath?.toURL(), placeholderImage: UIImage.squareAvatarPlaceholder())
        cell.listenButton.setImage(listenButtonImage, forState: .Normal)
        
        cell.listenButton.rx_tap.asDriver().driveNext {[weak self, weak cellViewModel] in
            guard let `self` = self else { return }
            guard self.checkIfUserIsLoggedInAndDisplayAlertIfNot() else { return }
            cellViewModel?.toggleIsListening().observeOn(MainScheduler.instance).subscribe({[weak cell] (event) in
                switch event {
                case .Next(let (listening, successMessage, newListnersCount, error)):
                    let listenButtonImage = listening ? UIImage.profileStopListeningIcon() : UIImage.profileListenIcon()
                    cell?.listenButton.setImage(listenButtonImage, forState: .Normal)
                    if let message = successMessage {
                        self.showSuccessMessage(message)
                        
                        guard let newListnersCount =  newListnersCount, profile = cellViewModel?.tag  else {
                            return
                        }
                        
                        do {
                            let newProfile : Tag = profile.copyWithListnersCount(newListnersCount, isListening: listening)
                            
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
        guard let cells = viewModel.pager.getCellViewModels() else { assertionFailure(); return; }
        let cellViewModel = cells[indexPath.row]
        flowDelegate?.showTag(cellViewModel.tag)
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.bounds.height > scrollView.contentSize.height - 50 {
            viewModel.pager.fetchNextPage()
        }
    }
}
