//
//  HomeShoutsCollectionViewController.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 15.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class HomeShoutsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    let viewModel = HomeShoutsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let collection = self.collectionView {
            viewModel.displayable.applyOnLayout(collection.collectionViewLayout as? UICollectionViewFlowLayout)
        }
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(viewModel.cellReuseIdentifier(), forIndexPath: indexPath)
    
        // Configure the cell
    
        return cell
    }
    
    // MARK: Actions
    
    func changeCollectionViewDisplayMode() {
        viewModel.changeDisplayModel()
        viewModel.displayable.applyOnLayout(self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)
    }
}
