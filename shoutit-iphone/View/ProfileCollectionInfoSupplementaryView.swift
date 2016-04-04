//
//  ProfileCollectionInfoSupplementaryView.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

class ProfileCollectionInfoSupplementaryView: UICollectionReusableView {
    
    var reuseDisposeBag: DisposeBag = DisposeBag()
    
    override var frame: CGRect {
        didSet {
            layoutButtons()
        }
    }
    
    // section 1
    @IBOutlet weak var avatarImageView: UIImageView! {
        didSet {
            avatarImageView.layer.borderColor = UIColor.whiteColor().CGColor
            avatarImageView.layer.borderWidth = 1
            avatarImageView.layer.cornerRadius = 5
            avatarImageView.layer.masksToBounds = true
        }
    }
    @IBOutlet weak var avatarContainerView: UIView! {
        didSet {
            avatarContainerView.layer.shadowColor = UIColor.grayColor().CGColor
            avatarContainerView.layer.shadowOpacity = 0.6
            avatarContainerView.layer.shadowRadius = 3.0
            avatarContainerView.layer.shadowOffset = CGSize(width: 2, height: 2)
            avatarContainerView.layer.masksToBounds = false
        }
    }
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var listeningToYouLabel: UILabel!
    @IBOutlet weak var notificationButton: UIButton!
    @IBOutlet weak var rightmostButton: UIButton!
    
    // section 2
    @IBOutlet weak var buttonSectionLeftButton: ProfileInfoHeaderButton!
    @IBOutlet weak var buttonSectionCenterButton: ProfileInfoHeaderButton!
    @IBOutlet weak var buttonSectionRightButton: ProfileInfoHeaderButton!
    @IBOutlet weak var verifyAccountButton: UIButton!
    @IBOutlet weak var buttonSectionLeftButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet var buttonSectionCenterButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet var buttonSectionRightButtonWidthConstraint: NSLayoutConstraint!
    
    
    // section 3
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var bioIconImageView: UIImageView!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var dateJoinedLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationFlagImageView: UIImageView!
    
    // constraints
    @IBOutlet weak var avatarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var verifyAccountButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bioSectionHeightConstrait: NSLayoutConstraint!
    @IBOutlet weak var websiteSectionHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateJoinedSectionHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationSectionHeightConstraint: NSLayoutConstraint!
    
    // computed vars
    var buttonSectionButtons: [ProfileInfoHeaderButton]? {
        if let left = buttonSectionLeftButton,
            center = buttonSectionCenterButton,
            right = buttonSectionRightButton {
            return [left, center, right]
        }
        return nil
    }
    var buttonSectionButtonsWidthConstraints: [NSLayoutConstraint]? {
        if let left = buttonSectionLeftButtonWidthConstraint,
            center = buttonSectionCenterButtonWidthConstraint,
            right = buttonSectionRightButtonWidthConstraint {
            return [left, center, right]
        }
        return nil
    }
    
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        super.applyLayoutAttributes(layoutAttributes)
        
        let attributes = layoutAttributes as! ProfileCollectionViewLayoutAttributes
        let normalAvatarHeight: CGFloat = 76.0
        avatarHeightConstraint.constant = min(1.0, attributes.scaleFactor) * normalAvatarHeight
    }
    
    func layoutButtons() {
        guard let buttons = buttonSectionButtons, constraints = buttonSectionButtonsWidthConstraints else {
            return
        }
        let numberOfButtons = buttons
            .reduce(0) {$0 + ($1.hidden == false ? 1 : 0)}
        let buttonWidth = frame.width / CGFloat(numberOfButtons)
        for (button, constraint) in zip(buttons, constraints) {
            constraint.constant = button.hidden ? 0 : buttonWidth
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reuseDisposeBag = DisposeBag()
    }
}
