//
//  SearchUserResultsTableViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 17.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

protocol SearchUserResultsTableViewControllerFlowDelegate: class, ProfileDisplayable {}

final class SearchUserResultsTableViewController: UITableViewController {
    
    // consts
    private let cellReuseId = "ProfileTableViewCell"
    
    // UI
    lazy var tableViewPlaceholder: TableViewPlaceholderView = {[unowned self] in
        let view = NSBundle.mainBundle().loadNibNamed("TableViewPlaceholderView", owner: nil, options: nil)[0] as! TableViewPlaceholderView
        view.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: self.tableView.bounds.height)
        return view
    }()
    
    // view model
    var viewModel: SearchUserResultsViewModel!
    
    // navigation
    weak var flowDelegate: SearchUserResultsTableViewControllerFlowDelegate?
    
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
        viewModel.reloadContent()
    }
    
    override func prefersTabbarHidden() -> Bool {
        return true
    }
    
    // MARK: - Setup
    
    private func registerReusables() {
        tableView.registerNib(UINib(nibName: cellReuseId, bundle: nil) , forCellReuseIdentifier: cellReuseId)
    }
    
    private func setupRX() {
        
        viewModel.state
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

        switch viewModel.state.value {
        case .LoadedAllContent(let cells, _):
            return cells.count
        case .Loaded(let cells, _):
            return cells.count
        case .LoadingMore(let cells, _, _):
            return cells.count
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cells: [SearchUserProfileCellViewModel]
        switch viewModel.state.value {
        case .LoadedAllContent(let c, _):
            cells = c
        case .Loaded(let c, _):
            cells = c
        case .LoadingMore(let c, _, _):
            cells = c
        default:
            preconditionFailure()
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseId, forIndexPath: indexPath) as! ProfileTableViewCell
        let cellModel = cells[indexPath.row]
        
        cell.nameLabel.text = cellModel.profile.name
        cell.listenersCountLabel.text = cellModel.listeningCountString()
        cell.thumbnailImageView.sh_setImageWithURL(cellModel.profile.imagePath?.toURL(), placeholderImage: UIImage.squareAvatarPlaceholder())
        let listenButtonImage = cellModel.isListening ? UIImage.profileStopListeningIcon() : UIImage.profileListenIcon()
        cell.listenButton.setImage(listenButtonImage, forState: .Normal)
        cell.listenButton.hidden = cellModel.hidesListeningButton()
        cell.listenButton.rx_tap.asDriver().driveNext {[weak self, weak cellModel] in
            guard self != nil && self!.validateLoggedUser() else { return }
            cellModel?.toggleIsListening().observeOn(MainScheduler.instance).subscribe({[weak cell] (event) in
                switch event {
                case .Next(let listening):
                    let listenButtonImage = listening ? UIImage.profileStopListeningIcon() : UIImage.profileListenIcon()
                    cell?.listenButton.setImage(listenButtonImage, forState: .Normal)
                case .Completed:
                    self?.viewModel.reloadItemAtIndex(indexPath.row)
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
        let cells: [SearchUserProfileCellViewModel]
        switch viewModel.state.value {
        case .LoadedAllContent(let c, _):
            cells = c
        case .Loaded(let c, _):
            cells = c
        case .LoadingMore(let c, _, _):
            cells = c
        default:
            preconditionFailure()
        }
        let cellViewModel = cells[indexPath.row]
        flowDelegate?.showProfile(cellViewModel.profile)
    }
}
