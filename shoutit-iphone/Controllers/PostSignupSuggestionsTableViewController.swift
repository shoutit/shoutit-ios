//
//  PostSignupSuggestionsTableViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Kingfisher

final class PostSignupSuggestionsTableViewController<SuggestableType: Suggestable>: UITableViewController {
    
    // UI
    lazy var placeholderView: TableViewPlaceholderView = {
        return NSBundle.mainBundle().loadNibNamed("TableViewPlaceholderView", owner: nil, options: nil)[0] as! TableViewPlaceholderView
    }()
    var activityIndicator: UIActivityIndicatorView?
    
    // view model
    var viewModel: PostSignupSuggestionViewModel!
    var sectionViewModel: PostSignupSuggestionsSectionViewModel<SuggestableType>!
    
    // RX
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    init() {
        super.init(style: .Plain)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register cells
        tableView.registerNib(UINib(nibName: "PostSignupSuggestionsHeaderTableViewCell", bundle: nil), forCellReuseIdentifier: "PostSignupSuggestionsHeaderTableViewCell")
        tableView.registerNib(UINib(nibName: "PostSignupSuggestionsTableViewCell", bundle: nil), forCellReuseIdentifier: "PostSignupSuggestionsTableViewCell")
        
        // configure table view
        tableView.separatorStyle = .None
        tableView.estimatedRowHeight = 44
        
        // configure rx
        setupRX()
    }
    
    override func viewWillLayoutSubviews() {
        activityIndicator?.center = tableView.center
        super.viewWillLayoutSubviews()
    }
    
    private func setupRX() {
        
        viewModel.state.asObservable()
            .subscribeNext {[weak self] (state) in
                switch state {
                case .Idle:
                    self?.showActivityIndicatorView(false)
                    self?.tableView.tableHeaderView = nil
                case .Loading:
                    self?.showActivityIndicatorView(true)
                    self?.tableView.tableHeaderView = nil
                case .ContentUnavailable:
                    self?.showActivityIndicatorView(false)
                    self?.placeholderView.label.text = NSLocalizedString("Categories unava'ilable", comment: "")
                    self?.tableView.tableHeaderView = self?.placeholderView
                case .Error(let error):
                    self?.showActivityIndicatorView(false)
                    self?.placeholderView.label.text = error.sh_message
                    self?.tableView.tableHeaderView = self?.placeholderView
                case .ContentLoaded:
                    self?.showActivityIndicatorView(false)
                    self?.tableView.tableHeaderView = nil
                }
                
                self?.tableView.reloadData()
            }
            .addDisposableTo(disposeBag)
        
        tableView.rx_itemSelected
            .subscribeNext{[unowned self] (indexPath) in
                let cellViewModel = self.sectionViewModel.cells[indexPath.row]
                cellViewModel.selected = !cellViewModel.selected
                self.tableView.reloadData()
            }
            .addDisposableTo(disposeBag)
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let firstInSection = indexPath.row == 0
        let lastInSection = tableView.numberOfRowsInSection(indexPath.section) == indexPath.row + 1
        if let cell = cell as? PostSignupSuggestionBaseTableViewCell {
            cell.setupCellForRoundedTop(firstInSection, roundedBottom: lastInSection)
        }
    }
    
    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        guard case LoadingState.ContentLoaded = viewModel.state.value else {
            return 0
        }
        
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard case LoadingState.ContentLoaded = viewModel.state.value else {
            return 0
        }
        
        return sectionViewModel.cells.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard case LoadingState.ContentLoaded = viewModel.state.value else {
            fatalError()
        }
        
        let cellViewModel = sectionViewModel.cells[indexPath.row]
        
        switch cellViewModel.cellType {
        case .Header(let title):
            let cell = tableView.dequeueReusableCellWithIdentifier(cellViewModel.cellType.reuseIdentifier, forIndexPath: indexPath) as! PostSignupSuggestionsHeaderTableViewCell
            cell.sectionTitleLabel.text = title
            return cell
        case .Normal(let item):
            let cell = tableView.dequeueReusableCellWithIdentifier(cellViewModel.cellType.reuseIdentifier, forIndexPath: indexPath) as! PostSignupSuggestionsTableViewCell
            cell.nameLabel.text = item.suggestionTitle
            if let thumbnailURL = item.thumbnailURL {
                cell.thumbnailImageView.kf_setImageWithURL(thumbnailURL)
            }
            
            let image = cellViewModel.selected ? UIImage.suggestionAccessoryViewSelected() : UIImage.suggestionAccessoryView()
            cell.listenButton.setImage(image, forState: .Normal)
            
            return cell
        }
    }
    
    // MARK: - Helpers
    
    private func showActivityIndicatorView(show: Bool) {
        
        if (activityIndicator == nil) {
            activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        }
        
        let indicator = activityIndicator!
        
        if show {
            if indicator.isAnimating() {
                return
            }
            tableView.addSubview(indicator)
            indicator.startAnimating()
        } else {
            if !indicator.isAnimating() {
                return
            }
            indicator.stopAnimating()
            indicator.removeFromSuperview()
        }
    }
}
