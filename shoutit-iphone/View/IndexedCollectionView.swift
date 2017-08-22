//
//  IndexedCollectionView.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class IndexedCollectionView: UICollectionView {
    @IBInspectable var index: Int = 0
    
    var contentSizeDidChange: ((CGSize) -> Void)?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !bounds.size.equalTo(contentSize) {
            contentSizeDidChange?(contentSize)
        }
    }
}
