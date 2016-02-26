//
//  ShoutDetailOtherShoutsCollectionViewDataSource.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class ShoutDetailOtherShoutsCollectionViewDataSource: NSObject, UICollectionViewDataSource {
    
    static let cellReuseIdentifier = "ShoutDetailOtherShoutsCollectionViewCell"
    let viewModel: ShoutDetailViewModel
    
    init(viewModel: ShoutDetailViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        fatalError()
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        fatalError()
    }
}
