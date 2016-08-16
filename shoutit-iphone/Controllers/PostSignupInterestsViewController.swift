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
    private let cellReuseID = "PostSignupCategoryTableViewCell"
    
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
        let view = NSBundle.mainBundle().loadNibNamed("TableViewPlaceholderView", owner: nil, options: nil)[0] as! TableViewPlaceholderView
        view.frame = CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: self.tableView.bounds.height)
        return view
    }()
    
    // view model
    var viewModel: PostSignupInterestsViewModel!
    
    // navigation
    weak var loginDelegate: LoginFlowController?
    weak var flowSimpleDelegate : FlowController?
    
    // Rx
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRX()
        setupAppearance()
        viewModel.fetchCategories()
        
        if self.flowSimpleDelegate != nil {
            self.skipButton.hidden = true
        }
    }
    
    // MARK: - Setup
    
    private func setupRX() {
        
        // table view
        Observable
            .combineLatest(viewModel.state.asObservable(), viewModel.categories.asObservable()){($0, $1)}
            .filter {[weak self] (loadingState, cellViewModels) -> Bool in
                switch loadingState {
                case .Idle:
                    self?.tableView.tableHeaderView = nil
                    return false
                case .Loading:
                    self?.tableViewPlaceholder.showActivity()
                    self?.tableView.tableHeaderView = self?.tableViewPlaceholder
                    return false
                case .ContentUnavailable:
                    self?.tableViewPlaceholder.showMessage(NSLocalizedString("Categories unavilable", comment: "Post signup 1 placeholder"))
                    self?.tableView.tableHeaderView = self?.tableViewPlaceholder
                    return false
                case .Error(let error):
                    self?.tableViewPlaceholder.showMessage(error.sh_message)
                    self?.tableView.tableHeaderView = self?.tableViewPlaceholder
                    return false
                case .ContentLoaded:
                    self?.tableView.tableHeaderView = nil
                    return true
                }
            }
            .map{$1}
            .bindTo(tableView.rx_itemsWithCellIdentifier(cellReuseID, cellType: PostSignupCategoryTableViewCell.self)) { (row, element, cell) in
                cell.nameLabel.text = element.category.name
                if let path = element.category.icon, url = path.toURL() {
                    cell.iconImageView.kf_setImageWithURL(url, placeholderImage: nil)
                }
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
                self.loginDelegate?.didFinishLoginProcessWithSuccess(true)
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
            .subscribe{[weak self] (event) in
                MBProgressHUD.hideHUDForView(self?.view, animated: true)
                switch event {
                case .Next:
                    if let simpleFlow = self?.flowSimpleDelegate{
                        
                        self?.dismissViewControllerAnimated(true, completion: {
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

// MARK: - NaviagtionBarContext

extension PostSignupInterestsViewController {
    override func prefersNavigationBarHidden() -> Bool {
        return true
    }
}

extension PostSignupInterestsViewController: UITableViewDelegate {
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .None
    }
}

