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
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var blurredImageView: UIImageView!
    
    
    @IBOutlet weak var titleLabelBottomConstraint: NSLayoutConstraint!
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        super.applyLayoutAttributes(layoutAttributes)
        
        let attributes = layoutAttributes as! ProfileCollectionViewLayoutAttributes
        
        // move title label
        let invisibleLabelsConstraintConstantValue = -titleLabel.bounds.height
        titleLabelBottomConstraint.constant = min(invisibleLabelsConstraintConstantValue + attributes.segmentScrolledUnderCoverViewLength, visibleLabelsConstraintConstantValue)
        
        // animate blur
        let animationProgress = attributes.collapseProgress
        if animationProgress > 0.2 {
            imageView.alpha = 1 - animationProgress
        } else {
            imageView.alpha = 1.0
        }
    }
}
