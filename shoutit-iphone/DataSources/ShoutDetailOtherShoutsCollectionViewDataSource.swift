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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.otherShoutsCellModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellViewModel = viewModel.otherShoutsCellModels[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellViewModel.cellReuseIdentifier, for: indexPath)
        
        switch cellViewModel {
        case .content(let shout):
            let contentCell = cell as! ShoutsCollectionViewCell
            contentCell.bindWith(Shout: shout)
        case .noContent(let message):
            let noContentCell = cell as! PlcaholderCollectionViewCell
            noContentCell.setupCellForActivityIndicator(false)
            noContentCell.placeholderTextLabel.text = message
        case .loading:
            let loadingCell = cell as! PlcaholderCollectionViewCell
            loadingCell.setupCellForActivityIndicator(true)
        case .error:
            let errorCell = cell as! PlcaholderCollectionViewCell
            errorCell.setupCellForActivityIndicator(false)
            errorCell.placeholderTextLabel.text = cellViewModel.errorMessage
        case .seeAll:
            break
        }
        
        return cell
    }
}
