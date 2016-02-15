//
//  ProfileCollectionViewControllerDataSource.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 15.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class ProfileCollectionViewControllerDataSource: NSObject, UICollectionViewDataSource {
    
    let viewModel: ProfileCollectionViewModel
    
    init(viewModel: ProfileCollectionViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 1//viewModel.pages.count
        case 1:
            return 1//viewModel.shouts.count
        default:
            assert(false)
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if indexPath.section == ProfileCollectionViewSection.Pages.rawValue {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ProfileCollectionViewSection.Pages.cellReuseIdentifier, forIndexPath: indexPath)
            return cell
        }
        
        else if indexPath.section == ProfileCollectionViewSection.Shouts.rawValue {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(ProfileCollectionViewSection.Shouts.cellReuseIdentifier, forIndexPath: indexPath)
            return cell
        }
        
        fatalError()
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        guard let view = ProfileCollectionViewSupplementaryView(indexPath: indexPath) else {
            fatalError("Unexpected supplementery view index path")
        }
        
        let supplementeryView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: view.kind.rawValue, forIndexPath: indexPath)
        
        return supplementeryView
    }
}
