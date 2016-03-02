//
//  ProfileCollectionCoverSupplementaryView.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class ProfileCollectionCoverSupplementaryView: UICollectionReusableView {
    
    var reuseDisposeBag: DisposeBag?
    private let visibleLabelsConstraintConstantValue: CGFloat = 21
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var gradientView: GradientView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var blurredImageView: UIImageView!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var cartButton: UIButton!
    
    @IBOutlet weak var menuButtonLeadingContainerConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabelBottomConstraint: NSLayoutConstraint!
    
    func setCoverImage(image: UIImage) {
        blurredImageView.image = image
        imageView.image = image
    }
    
    func setBackButtonHidden(hidden: Bool) {
        backButton.hidden = hidden
        menuButtonLeadingContainerConstraint.constant = hidden ? 0 : 44
    }
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        super.applyLayoutAttributes(layoutAttributes)
        
        let attributes = layoutAttributes as! ProfileCollectionViewLayoutAttributes
        
        // move title label
        let invisibleLabelsConstraintConstantValue = -titleLabel.bounds.height
        titleLabelBottomConstraint.constant = min(invisibleLabelsConstraintConstantValue + attributes.segmentScrolledUnderCoverViewLength, visibleLabelsConstraintConstantValue)
        
        // animate blur
        let animationProgress = attributes.collapseProgress
        if animationProgress > 0.05 {
            imageView.alpha = 1 - animationProgress
            gradientView.alpha = 1 - animationProgress
        } else {
            imageView.alpha = 1.0
            gradientView.alpha = 1.0
        }
    }
}
