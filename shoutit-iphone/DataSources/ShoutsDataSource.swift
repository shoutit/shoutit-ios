//
//  DiscoverDataSource.swift
//  shoutit
//
//  Created by Piotr Bernad on 29/08/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class ShoutsDataSource: BasicDataSource, UICollectionViewDataSource {
    
    enum CellType {
        case Shout
        case Placeholder
        
        var resuseIdentifier: String {
            switch self {
            case .Shout:
                return "ShoutsExpandedCollectionViewCell"
            case .Placeholder:
                return "PlaceholderCollectionViewCell"
                
            }
        }
    }
    
    var viewModel : ShoutsCollectionViewModel!
    
    override func loadContent() {
        viewModel.reloadContent()
    }
    
    convenience init(context: ShoutsCollectionViewModel.Context) {
        self.init()
        
        self.viewModel = ShoutsCollectionViewModel(context: context)
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch viewModel.pager.state.value {
        case .Idle:
            return 0
        case .Error, .NoContent, .Loading:
            return 1
        default:
            return self.viewModel.pager.shoutCellViewModels().count
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let placeholderCellWithMessage: (message: String?, activityIndicator: Bool) -> PlcaholderCollectionViewCell = {(message, activity) in
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellType.Placeholder.resuseIdentifier, forIndexPath: indexPath) as! PlcaholderCollectionViewCell
            cell.setupCellForActivityIndicator(activity)
            cell.placeholderTextLabel.text = message
            return cell
        }
        
        let shoutCellWithModel: (ShoutCellViewModel -> UICollectionViewCell) = {cellViewModel in
            
            let cell: ShoutsCollectionViewCell
            cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellType.Shout.resuseIdentifier, forIndexPath: indexPath) as! ShoutsCollectionViewCell
            
            if let shout = cellViewModel.shout {
                cell.bindWith(Shout: shout)
                cell.bookmarkButton?.tag = indexPath.item
            } else if let ad = cellViewModel.ad {
                cell.bindWithAd(Ad: ad)
            }
            
            return cell
        }
        
        switch viewModel.pager.state.value {
        case .Idle:
            fatalError()
        case .Error(let error):
            return placeholderCellWithMessage(message: error.sh_message, activityIndicator: false)
        case .NoContent:
            return placeholderCellWithMessage(message: self.viewModel.noContentMessage(), activityIndicator: false)
        case .Loading:
            return placeholderCellWithMessage(message: nil, activityIndicator: true)
        default:
            let cellViewModel = self.viewModel.pager.shoutCellViewModels()[indexPath.row]
            return shoutCellWithModel(cellViewModel)
        }
    }
    

}
