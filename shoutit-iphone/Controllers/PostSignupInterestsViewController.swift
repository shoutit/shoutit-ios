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
import MBProgressHUD

protocol PostSignupInterestsViewControllerFlowDelegate: class, PostSignupDisplayable, LoginFinishable {}

class PostSignupInterestsViewController: UIViewController {
    
    // consts
    let cellReuseID = "PostSignupCategoryTableViewCell"
    
    // IB outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewContainer: UIView!
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
        setupAppearance()
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
        
        let nextTap = nextButton.rx_tap
        nextTap
            .subscribeNext{[unowned self] in
                MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            }
            .addDisposableTo(disposeBag)
        
        nextTap
            .flatMapLatest{self.viewModel.listenToSelectedCategories()}
            .subscribeNext {[weak self] (result) in
                MBProgressHUD.hideHUDForView(self?.view, animated: true)
                switch result {
                case .Success:
                    self?.flowDelegate?.showPostSignupSuggestions()
                case .Failure(let error):
                    let alertViewController = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: error.localizedDescription, preferredStyle: .Alert)
                    alertViewController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .Default, handler: nil))
                    self?.presentViewController(alertViewController, animated: true, completion: nil)
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    private func setupAppearance() {
        tableViewContainer.layer.cornerRadius = 10
        tableViewContainer.layer.borderColor = UIColor.lightGrayColor().CGColor
        tableViewContainer.layer.borderWidth = 0.5
        tableViewContainer.layer.shadowColor = UIColor.grayColor().CGColor
        tableViewContainer.layer.shadowOpacity = 0.6
        tableViewContainer.layer.shadowRadius = 3.0
        tableViewContainer.layer.shadowOffset = CGSize(width: 2, height: 2)
        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = 10
    }
}

