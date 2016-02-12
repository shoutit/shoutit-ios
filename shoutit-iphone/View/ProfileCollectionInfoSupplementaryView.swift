//
//  ProfileCollectionInfoSupplementaryView.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class ProfileCollectionInfoSupplementaryView: UICollectionReusableView {
    
    // section 1
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var listeningToYouLabel: UILabel!
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var rightmostButton: UIButton!
    
    // section 2
    @IBOutlet weak var buttonSectionLeftButton: UIButton!
    @IBOutlet weak var buttonSectionCenterButton: UIButton!
    @IBOutlet weak var buttonSectionRightButton: UIButton!
    
    // section 3
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var dateJoinedLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationFlagImageView: UIImageView!
    
    // constraints
    @IBOutlet weak var avatarHeightConstraint: NSLayoutConstraint!
    
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        super.applyLayoutAttributes(layoutAttributes)
        
        let attributes = layoutAttributes as! ProfileCollectionViewLayoutAttributes
        
        let normalAvatarHeight: CGFloat = 76.0
        let minimumAvatarHeight: CGFloat = 35.0
        
        avatarHeightConstraint.constant = max(min(1.0, attributes.scaleFactor) * normalAvatarHeight, minimumAvatarHeight)
    }
}