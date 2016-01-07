//
//  SHDiscoverFeedDiscoverItemCell.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 1/7/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class SHDiscoverFeedDiscoverItemCell: UICollectionViewCell {
    
    private var viewModel: SHDiscoverFeedDiscoverItemCellViewModel?
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewModel = SHDiscoverFeedDiscoverItemCellViewModel(cell: self)
        collectionView.delegate = viewModel
        collectionView.dataSource = viewModel
    }
    
    func setUp(viewController: UIViewController) {
        viewModel?.setUp(viewController)
    }
}
