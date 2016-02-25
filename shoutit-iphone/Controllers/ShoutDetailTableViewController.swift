//
//  ShoutDetailTableViewController.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 23.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class ShoutDetailTableViewController: UITableViewController {
    
    // UI
    @IBOutlet weak var headerView: ShoutDetailTableHeaderView!
    
    // view model
    var viewModel: ShoutDetailViewModel!
    
    // data sources
    private var dataSource: ShoutDetailTableViewDataSource!
    private var otherShoutsDataSource: ShoutDetailOtherShoutsCollectionViewDataSource!
    private var relatedShoutsDataSource: ShoutDetailRelatedShoutsCollectionViewDataSource!
    private var imagesDataSource: ShoutDetailImagesPageViewControllerDataSource!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup data sources
        dataSource = ShoutDetailTableViewDataSource(viewModel: viewModel)
        otherShoutsDataSource = ShoutDetailOtherShoutsCollectionViewDataSource(viewModel: viewModel)
        relatedShoutsDataSource = ShoutDetailRelatedShoutsCollectionViewDataSource(viewModel: viewModel)
        imagesDataSource = ShoutDetailImagesPageViewControllerDataSource(viewModel: viewModel)
        
        // setup table view
        tableView.estimatedRowHeight = 40
    }
}

// MARK: - Cells

extension ShoutDetailTableViewController {
    
    enum Cell {
        case SectionHeader
        case Description
        case KeyValue
        case Regular
        case Button
        case OtherShouts
        case RelatedShouts
        
        var reuseIdentifier: String {
            switch self {
            case .SectionHeader:
                return "SectionHeader"
            case .Description:
                return "Description"
            case .KeyValue:
                return "KeyValue"
            case .Regular:
                return "Regular"
            case .Button:
                return "Button"
            case .OtherShouts:
                return "OtherShouts"
            case .RelatedShouts:
                return "RelatedShouts"
            }
        }
    }
}
