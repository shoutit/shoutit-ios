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
    
    // view model
    var viewModel: PostSignupInterestsViewModel!
    
    // navigation
    weak var flowDelegate: PostSignupInterestsViewControllerFlowDelegate?
    
    // Rx
    let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup
        setupRX()
        
        // fetch
        self.viewModel.fetchCategories()
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
            .filter { (loadingState, cellViewModels) -> Bool in
                switch loadingState {
                case .Idle:
                    return false
                case .Loading:
                    // show activity indicator
                    return false
                case .ContentUnavailable:
                    // show placeholder
                    return false
                case .Error(let error):
                    // display error
                    return false
                case .ContentLoaded:
                    return true
                }
            }
            .map{$1}.bindTo(tableView.rx_itemsWithCellIdentifier(cellReuseID, cellType: PostSignupCategoryTableViewCell.self)) { (row, element, cell) in
                cell.nameLabel.text = element.category.name
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

