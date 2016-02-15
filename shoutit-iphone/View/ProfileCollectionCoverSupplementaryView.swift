//
//  ProfileCollectionCoverSupplementaryView.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class ProfileCollectionCoverSupplementaryView: UICollectionReusableView {
    
    private let visibleLabelsConstraintConstantValue: CGFloat = 21
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    @IBOutlet weak var titleLabelBottomConstraint: NSLayoutConstraint!
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        super.applyLayoutAttributes(layoutAttributes)
        
        let attributes = layoutAttributes as! ProfileCollectionViewLayoutAttributes
        
        let invisibleLabelsConstraintConstantValue = titleLabel.bounds.height
        
        titleLabelBottomConstraint.constant = min(invisibleLabelsConstraintConstantValue + attributes.segmentScrolledUnderCoverViewLength, visibleLabelsConstraintConstantValue)
    }
}
