//
//  FlowLayout.swift
//  shoutit
//
//  Created by Piotr Bernad on 31/08/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

class FlowLayout : UICollectionViewFlowLayout {
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
}