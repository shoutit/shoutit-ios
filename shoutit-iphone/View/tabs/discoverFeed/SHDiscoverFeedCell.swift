//
//  SHDiscoverFeedCell.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 1/7/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class SHDiscoverFeedCell: UICollectionViewCell {
    
    private var viewModel: SHDiscoverFeedCellViewModel?
    
    @IBOutlet weak var discoverImage: UIImageView!
    @IBOutlet weak var discoverTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewModel = SHDiscoverFeedCellViewModel(cell: self)
    }
    
    func setUp(viewController: UIViewController?, discoverItem: SHDiscoverItem) {
        viewModel?.setUp(viewController, discoverItem: discoverItem)
    }
}
