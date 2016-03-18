//
//  SearchUserResultsTableViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 17.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

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
    
    // MARK: - Actions
    
    @IBAction func filterAction(sender: AnyObject) {
        notImplemented()
    }
    
    @IBAction func searchAction(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
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
                case .Loaded:
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
        guard case .Loaded(let cells, _) = viewModel.state.value else {
            return 0
        }
        
        return cells.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard case .Loaded(let cells, _) = viewModel.state.value else {
            preconditionFailure()
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseId, forIndexPath: indexPath) as! ProfileTableViewCell
        let cellModel = cells[indexPath.row]
        
        cell.nameLabel.text = cellModel.profile.name
        cell.listenersCountLabel.text = cellModel.listeningCountString()
        cell.thumbnailImageView.sh_setImageWithURL(cellModel.profile.imagePath?.toURL(), placeholderImage: UIImage.squareAvatarPlaceholder())
        let listenButtonImage = cellModel.isListening ? UIImage.profileStopListeningIcon() : UIImage.profileListenIcon()
        cell.listenButton.setImage(listenButtonImage, forState: .Normal)
        cell.listenButton.rx_tap.asDriver().driveNext {[weak self, weak cellModel] in
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
}
