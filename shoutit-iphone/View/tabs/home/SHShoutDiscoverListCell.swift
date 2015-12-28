//
//  SHShoutDiscoverListCell.swift
//  shoutit-iphone
//
//  Created by Hitesh Sondhi on 24/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHShoutDiscoverListCell: UICollectionViewCell {
    
    private var viewModel: SHShoutDiscoverListCellViewModel?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        viewModel = SHShoutDiscoverListCellViewModel(cell: self)
        collectionView.delegate = viewModel
        collectionView.dataSource = viewModel
    }
    
    func setUp(viewController: UIViewController) {
        viewModel?.setUp(viewController)
    }
}
