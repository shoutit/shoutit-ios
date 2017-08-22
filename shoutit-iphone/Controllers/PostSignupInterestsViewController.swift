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

final class PostSignupInterestsViewController: UIViewController {
    
    // consts
    fileprivate let cellReuseID = "PostSignupCategoryTableViewCell"
    
    // IB outlets
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
        }
    }
    @IBOutlet weak var tableViewContainer: UIView!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    lazy var tableViewPlaceholder: TableViewPlaceholderView = {[unowned self] in
        let view = Bundle.main.loadNibNamed("TableViewPlaceholderView", owner: nil, options: nil)?[0] as! TableViewPlaceholderView
        view.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: self.tableView.bounds.height)
        return view
    }()
    
    // view model
    var viewModel: PostSignupInterestsViewModel!
    
    // navigation
    weak var loginDelegate: LoginFlowController?
    weak var flowSimpleDelegate : FlowController?
    
    // Rx
    fileprivate let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRX()
        setupAppearance()
        viewModel.fetchCategories()
        
        if self.flowSimpleDelegate != nil {
            self.skipButton.isHidden = true
        }
    }
    
    // MARK: - Setup
    
    fileprivate func setupRX() {
        
        // table view
        Observable
            .combineLatest(viewModel.state.asObservable(), viewModel.categories.asObservable()){($0, $1)}
            .filter {[weak self] (loadingState, cellViewModels) -> Bool in
                switch loadingState {
                case .idle:
                    self?.tableView.tableHeaderView = nil
                    return false
                case .loading:
                    self?.tableViewPlaceholder.showActivity()
                    self?.tableView.tableHeaderView = self?.tableViewPlaceholder
                    return false
                case .contentUnavailable:
                    self?.tableViewPlaceholder.showMessage(NSLocalizedString("Categories unavilable", comment: "Post signup 1 placeholder"))
                    self?.tableView.tableHeaderView = self?.tableViewPlaceholder
                    return false
                case .error(let error):
                    self?.tableViewPlaceholder.showMessage(error.sh_message)
                    self?.tableView.tableHeaderView = self?.tableViewPlaceholder
                    return false
                case .contentLoaded:
                    self?.tableView.tableHeaderView = nil
                    return true
                }
            }
            .map{$1}
            .bindTo(tableView.rx_itemsWithCellIdentifier(cellReuseID, cellType: PostSignupCategoryTableViewCell.self)) { (row, element, cell) in
                cell.nameLabel.text = element.category.name
                if let path = element.category.icon, let url = path.toURL() {
                    cell.iconImageView.kf_setImageWithURL(url, placeholderImage: nil)
                }
                cell.accessoryType = element.selected ? UITableViewCellAccessoryType.checkmark : UITableViewCellAccessoryType.none
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
                self.loginDelegate?.didFinishLoginProcessWithSuccess(true)
            }
            .addDisposableTo(disposeBag)
        
        let nextTap = nextButton.rx_tap
        nextTap
            .subscribeNext{[unowned self] in
                MBProgressHUD.showAdded(to: self.view, animated: true)
            }
            .addDisposableTo(disposeBag)
        
        nextTap
            .flatMapLatest{self.viewModel.listenToSelectedCategories()}
            .subscribe{[weak self] (event) in
                MBProgressHUD.hide(for: self?.view, animated: true)
                switch event {
                case .next:
                    if let simpleFlow = self?.flowSimpleDelegate{
                        
                        self?.dismiss(animated: true, completion: {
                            simpleFlow.presentSuggestions()
                        })
                        
                        return
                    }
                    self?.loginDelegate?.showPostSignupSuggestions()
                case .Error(let error):
                    self?.showError(error)
                default:
                    break
                }
            }
            .addDisposableTo(disposeBag)
    }
    
    fileprivate func setupAppearance() {
        tableViewContainer.layer.cornerRadius = 10
        tableViewContainer.layer.borderColor = UIColor.lightGray.cgColor
        tableViewContainer.layer.borderWidth = 0.5
        tableViewContainer.layer.shadowColor = UIColor.gray.cgColor
        tableViewContainer.layer.shadowOpacity = 0.6
        tableViewContainer.layer.shadowRadius = 3.0
        tableViewContainer.layer.shadowOffset = CGSize(width: 2, height: 2)
        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = 10
    }
}

// MARK: - NaviagtionBarContext

extension PostSignupInterestsViewController {
    override func prefersNavigationBarHidden() -> Bool {
        return true
    }
}

extension PostSignupInterestsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
}

