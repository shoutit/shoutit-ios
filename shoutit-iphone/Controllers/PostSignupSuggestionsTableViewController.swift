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

final class PostSignupSuggestionsTableViewController: UITableViewController {
    
    // UI
    @IBOutlet var placeholderView: TableViewPlaceholderView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // view model
    var viewModel: PostSignupSuggestionViewModel!
    
    // RX
    let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 44
        setupRX()
        viewModel.fetchSections()
    }
    
    private func setupRX() {
        
        viewModel.state.asObservable()
            .subscribeNext {[weak self] (state) in
                switch state {
                case .Idle:
                    self?.activityIndicator.hidden = true
                    self?.tableView.tableHeaderView = nil
                case .Loading:
                    self?.activityIndicator.hidden = false
                    self?.tableView.tableHeaderView = nil
                case .ContentUnavailable:
                    self?.activityIndicator.hidden = true
                    self?.placeholderView.label.text = NSLocalizedString("Categories unavilable", comment: "")
                    self?.tableView.tableHeaderView = self?.placeholderView
                case .Error(let error):
                    self?.activityIndicator.hidden = true
                    self?.placeholderView.label.text = (error as NSError).localizedDescription
                    self?.tableView.tableHeaderView = self?.placeholderView
                case .ContentLoaded:
                    self?.activityIndicator.hidden = true
                    self?.tableView.tableHeaderView = nil
                }
                
                self?.tableView.reloadData()
            }
            .addDisposableTo(disposeBag)
        
        tableView.rx_itemSelected
            .subscribeNext{[unowned self] (indexPath) in
                let section = self.viewModel.sections[indexPath.section]
                let cellViewModel = section.cells[indexPath.row]
                cellViewModel.selected = !cellViewModel.selected
                self.tableView.reloadData()
            }
            .addDisposableTo(disposeBag)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        let firstInSection = indexPath.row == 0
        let lastInSection = tableView.numberOfRowsInSection(indexPath.section) == indexPath.row + 1
        if let cell = cell as? PostSignupSuggestionBaseTableViewCell {
            cell.setupCellForRoundedTop(firstInSection, roundedBottom: lastInSection)
        }
    }
}

// MARK: - UITableViewDataSource

extension PostSignupSuggestionsTableViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        guard case LoadingState.ContentLoaded = viewModel.state.value else {
            return 0
        }
        
        return viewModel.sections.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard case LoadingState.ContentLoaded = viewModel.state.value else {
            return 0
        }
        
        let section = viewModel.sections[section]
        return section.cells.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard case LoadingState.ContentLoaded = viewModel.state.value else {
            fatalError()
        }
        
        let section = viewModel.sections[indexPath.section]
        let cellViewModel = section.cells[indexPath.row]
        
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
            let accessoryViewImage = cellViewModel.selected ? UIImage.suggestionAccessoryViewSelected() : UIImage.suggestionAccessoryView()
            let accessoryView = UIImageView(image: accessoryViewImage)
            cell.accessoryView = accessoryView
            return cell
        }
    }
}