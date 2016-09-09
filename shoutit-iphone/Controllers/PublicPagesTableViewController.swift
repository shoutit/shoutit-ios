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
import DZNEmptyDataSet

class PublicPagesTableViewController: UITableViewController {
    
    var viewModel: PublicPagesViewModel!
    weak var flowDelegate: FlowController?
    private let cellConfigurator = ProfileCellConfigurator()
    
    @IBOutlet var placeholderView : PagesPlaceholderView!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        precondition(viewModel != nil)
        registerReusables()
        setupRX()
        
        self.tableView.emptyDataSetSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.pager.refreshContent()
    }
    
    private func registerReusables() {
        tableView.register(PageTableViewCell.self)
    }
    
    private func setupRX() {
        
        viewModel.pager.state
            .asObservable()
            .subscribeNext {[weak self] (state) in
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
        let cell: PageTableViewCell = tableView.dequeueReusableCell(forIndexPath: indexPath)
        let cellModel = cells[indexPath.row]
        
        cell.bindWithProfileViewModel(cellModel)
        
        cell.listenButton.rx_tap.asDriver().driveNext {[weak self, weak cellModel] in
            guard let `self` = self else { return }
            guard self.checkIfUserIsLoggedInAndDisplayAlertIfNot() else { return }
            cellModel?.toggleIsListening()
                .observeOn(MainScheduler.instance)
                .subscribe({[weak cell] (event) in
                    switch event {
                    case .Next(let (listening, successMessage, newListnersCount, error)):
                        
                        cell?.listenButton.listenState = listening ? .Listening : .Listen
                        
                        if let message = successMessage {
                            self.showSuccessMessage(message)

                            guard let newListnersCount =  newListnersCount, profile = cellModel?.profile  else {
                                return
                            }
                            
                            do {
                                let newProfile : Profile = profile.copyWithListnersCount(newListnersCount, isListening: listening)
                                
                                try self.viewModel.pager.replaceItemAtIndex(indexPath.row, withItem: newProfile)
                            
                                self.tableView.beginUpdates()
                                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
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
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 64
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let cells = viewModel.pager.getCellViewModels() else { assertionFailure(); return; }
        let cellViewModel = cells[indexPath.row]
        flowDelegate?.showPage(cellViewModel.profile)
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y + scrollView.bounds.height > scrollView.contentSize.height - 50 {
            viewModel.pager.fetchNextPage()
        }
    }
}

extension PublicPagesTableViewController : DZNEmptyDataSetSource, DZNEmptyDataSetDelegate  {
    func customViewForEmptyDataSet(scrollView: UIScrollView!) -> UIView! {
        return self.placeholderView
    }
    
    func emptyDataSetShouldAllowTouch(scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    func emptyDataSetDidTapView(scrollView: UIScrollView!) {
        
    }
    
    func emptyDataSetDidTapButton(scrollView: UIScrollView!) {
        
    }
}
