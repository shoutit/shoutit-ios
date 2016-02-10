//
//  PostSignupInterestsViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 05.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol PostSignupInterestsViewControllerFlowDelegate: class, PostSignupDisplayable, LoginFinishable {}

class PostSignupInterestsViewController: UIViewController {
    
    // consts
    let cellReuseID = "PostSignupCategoryTableViewCell"
    
    // IB outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet var tableViewPlaceholder: TableViewPlaceholderView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // view model
    var viewModel: PostSignupInterestsViewModel!
    
    // navigation
    weak var flowDelegate: PostSignupInterestsViewControllerFlowDelegate?
    
    // Rx
    let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRX()
        viewModel.fetchCategories()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBarHidden = true
    }
    
    // MARK: - Setup
    
    private func setupRX() {
        
        // table view
        Observable
            .combineLatest(viewModel.state.asObservable(), viewModel.categories.asObservable()){($0, $1)}
            .filter {[weak self] (loadingState, cellViewModels) -> Bool in
                switch loadingState {
                case .Idle:
                    self?.activityIndicator.hidden = true
                    self?.tableView.tableHeaderView = nil
                    return false
                case .Loading:
                    self?.activityIndicator.hidden = false
                    self?.tableView.tableHeaderView = nil
                    return false
                case .ContentUnavailable:
                    self?.activityIndicator.hidden = true
                    self?.tableViewPlaceholder.label.text = NSLocalizedString("Categories unavilable", comment: "")
                    self?.tableView.tableHeaderView = self?.tableViewPlaceholder
                    return false
                case .Error(let error):
                    self?.activityIndicator.hidden = true
                    self?.tableViewPlaceholder.label.text = (error as NSError).localizedDescription
                    self?.tableView.tableHeaderView = self?.tableViewPlaceholder
                    return false
                case .ContentLoaded:
                    self?.activityIndicator.hidden = true
                    self?.tableView.tableHeaderView = nil
                    return true
                }
            }
            .map{$1}.bindTo(tableView.rx_itemsWithCellIdentifier(cellReuseID, cellType: PostSignupCategoryTableViewCell.self)) { (row, element, cell) in
                cell.nameLabel.text = element.category.name
                cell.accessoryType = element.selected ? UITableViewCellAccessoryType.Checkmark : UITableViewCellAccessoryType.None
            }
            .addDisposableTo(disposeBag)
        
        tableView
            .rx_modelSelected(PostSignupInterestCellViewModel.self)
            .subscribeNext { (cellViewModel) in
                cellViewModel.selected = !cellViewModel.selected
                self.tableView.reloadData()
            }
            .addDisposableTo(disposeBag)
        
        // buttons
        
        skipButton
            .rx_tap
            .subscribeNext {[unowned self] in
                self.flowDelegate?.didFinishLoginProcessWithSuccess(true)
            }
            .addDisposableTo(disposeBag)
        
        nextButton
            .rx_tap
            .subscribeNext {[unowned self] in
                self.flowDelegate?.showPostSignupSuggestions()
            }
            .addDisposableTo(disposeBag)
    }
}

