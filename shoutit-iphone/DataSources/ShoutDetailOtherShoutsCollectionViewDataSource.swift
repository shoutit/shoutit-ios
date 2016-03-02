//
//  ShoutDetailOtherShoutsCollectionViewDataSource.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class ShoutDetailOtherShoutsCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    
    let viewModel: ShoutDetailViewModel
    
    init(viewModel: ShoutDetailViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.otherShoutsCellModels.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cellViewModel = viewModel.otherShoutsCellModels[indexPath.row]
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(cellViewModel.cellReuseIdentifier, forIndexPath: indexPath)
        
        switch cellViewModel {
        case .Content(let shout):
            let contentCell = cell as! ShoutsCollectionViewCell
            contentCell.imageView.sh_setImageWithURL(shout.thumbnailPath?.toURL(), placeholderImage: UIImage.shoutsPlaceholderImage())
            contentCell.titleLabel.text = cellViewModel.title
            contentCell.subtitleLabel.text = cellViewModel.authorName
            contentCell.priceLabel.text = cellViewModel.priceString
        case .NoContent(let message):
            let noContentCell = cell as! PlcaholderCollectionViewCell
            noContentCell.setupCellForActivityIndicator(false)
            noContentCell.placeholderTextLabel.text = message
        case .Loading:
            let loadingCell = cell as! PlcaholderCollectionViewCell
            loadingCell.setupCellForActivityIndicator(true)
        case .Error:
            let errorCell = cell as! PlcaholderCollectionViewCell
            errorCell.setupCellForActivityIndicator(false)
            errorCell.placeholderTextLabel.text = cellViewModel.errorMessage
        case .SeeAll:
            break
        }
        
        return cell
    }
}
