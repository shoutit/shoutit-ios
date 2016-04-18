//
//  ShoutDetailOtherShoutsCollectionViewDataSource.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class ShoutDetailOtherShoutsCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    
    unowned let controller: ShoutDetailTableViewController
    var viewModel: ShoutDetailViewModel {
        return controller.viewModel
    }
    
    init(controller: ShoutDetailTableViewController) {
        self.controller = controller
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
            contentCell.hydrateWithShout(shout)
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
