//
//  AutoInstrictSizeCollectionView.swift
//  shoutit
//
//  Created by Piotr Bernad on 30/08/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class AutoInstrictSizeCollectionView: UICollectionView {

    override func intrinsicContentSize() -> CGSize {
//        if let flowLayout = self.collectionViewLayout as? UICollectionViewFlowLayout {
//            let items : CGFloat = CGFloat(self.dataSource?.collectionView(self, numberOfItemsInSection: 0) ?? 0)
//            let rowHeight = (flowLayout.itemSize.height + flowLayout.minimumLineSpacing)
//            
//            print(items)
//            
//            return CGSizeMake(self.collectionViewLayout.collectionViewContentSize().width,  rowHeight * items)
//        }
//        
//        print(self.collectionViewLayout.collectionViewContentSize())
        return self.collectionViewLayout.collectionViewContentSize()
    }

    
}
