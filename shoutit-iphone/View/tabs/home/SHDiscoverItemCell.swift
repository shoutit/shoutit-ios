//
//  SHDiscoverItemCell.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 24/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHDiscoverItemCell: UICollectionViewCell {
    
    private var viewModel: SHDiscoverItemCellViewModel?
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var discoverImage: UIImageView!
    @IBOutlet weak var discoverTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewModel = SHDiscoverItemCellViewModel(cell: self)
    }
    
    func setUp(viewController: UIViewController?, discoverItem: SHDiscoverItem) {
        viewModel?.setUp(viewController, discoverItem: discoverItem)
    }
    
}
