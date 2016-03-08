//
//  EditProfileTableViewHeaderView.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 07.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class EditProfileTableViewHeaderView: UIView {
    
    // cover
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var coverButton: UIButton!
    
    // avatar
    @IBOutlet weak var avatarContainerView: UIView! {
        didSet {
            avatarContainerView.layer.shadowColor = UIColor.grayColor().CGColor
            avatarContainerView.layer.shadowOpacity = 0.6
            avatarContainerView.layer.shadowRadius = 3.0
            avatarContainerView.layer.shadowOffset = CGSize(width: 2, height: 2)
            avatarContainerView.layer.masksToBounds = false
        }
    }
    @IBOutlet weak var avatarImageView: UIImageView! {
        didSet {
            avatarImageView.layer.borderColor = UIColor.whiteColor().CGColor
            avatarImageView.layer.borderWidth = 1
            avatarImageView.layer.cornerRadius = 5
            avatarImageView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var avatarButtonOverlay: UIView! {
        didSet {
            avatarButtonOverlay.layer.borderColor = UIColor.whiteColor().CGColor
            avatarButtonOverlay.layer.borderWidth = 1
            avatarButtonOverlay.layer.cornerRadius = 5
            avatarButtonOverlay.layer.masksToBounds = true
            avatarButtonOverlay.clipsToBounds = true
        }
    }
    @IBOutlet weak var avatarButton: UIButton!
}
