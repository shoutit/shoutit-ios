//
//  AutoInstrictSizeCollectionView.swift
//  shoutit
//
//  Created by Piotr Bernad on 30/08/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class AutoInstrictSizeCollectionView: UICollectionView {

    var heightContraint : NSLayoutConstraint?
    
    override var contentSize: CGSize {
        didSet {
            self.heightContraint?.constant = contentSize.height
            self.layoutIfNeeded()
        }
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        heightContraint = NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: self.contentSize.height)
        heightContraint?.active = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        heightContraint = NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: self.contentSize.height)
        heightContraint?.active = true
    }    
}
