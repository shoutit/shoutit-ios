//
//  SHDiscoverViewCell.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 08/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import Foundation

class SHDiscoverCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textLabel: UILabel!
    
    private var viewModel: SHDiscoverCellViewModel?
    
    override func awakeFromNib() {
        self.viewModel = SHDiscoverCellViewModel(cell: self)
    }
    
    func setUp(item: SHDiscoverItem) {
        viewModel?.setup(item)
    }
}
