//
//  PublicPagesTableViewController.swift
//  shoutit
//
//  Created by Łukasz Kasperek on 23.06.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import ShoutitKit

class PublicPagesTableViewController: UITableViewController {
    
    // UI
    lazy var tableViewPlaceholder: TableViewPlaceholderView = {[unowned self] in
        let view = Bundle.main.loadNibNamed("TableViewPlaceholderView", owner: nil, options: nil)?[0] as! TableViewPlaceholderView
        view.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: self.tableView.bounds.height)
        return view
    }()
    
    var viewModel: PublicPagesViewModel!
    weak var flowDelegate: FlowController?
    fileprivate let cellConfigurator = ProfileCellConfigurator()
    
    fileprivate let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil)
        registerReusables()
        setupRX()
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
                    self?.tableViewPlaceholder.showMessage(NSLocalizedString("There are no pages available in your country", comment: "Public pages empty message"))
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
        
        cellConfigurator.configureCell(cell, cellViewModel: cellModel, showsListenButton: true)
        
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
                        } else if let error = error {
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
        flowDelegate?.showPage(cellViewModel.profile)
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.bounds.height > scrollView.contentSize.height - 50 {
            viewModel.pager.fetchNextPage()
        }
    }
}
