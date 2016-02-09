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
    
    // view model
    var viewModel: PostSignupSuggestionViewModel!
    
    // RX
    let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRX()
    }
    
    private func setupRX() {
        
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
            return cell
        }
    }
}