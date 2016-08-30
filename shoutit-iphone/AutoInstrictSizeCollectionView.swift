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
        return self.contentSize
    }

}
