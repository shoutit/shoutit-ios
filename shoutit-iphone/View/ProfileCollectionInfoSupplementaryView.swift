//
//  ProfileCollectionInfoSupplementaryView.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

enum ProfileCollectionInfoButton {
    case Listeners(countString: String)
    case Listening(countString: String)
    case Interests(countString: String)
    case Chat
    case Listen(isListening: Bool)
    
    var title: String {
        switch self {
        case .Listeners:
            return NSLocalizedString("Listeners", comment: "")
        case .Listening:
            return NSLocalizedString("Listening", comment: "")
        case .Interests:
            return NSLocalizedString("Interests", comment: "")
        case .Chat:
            return NSLocalizedString("Chat", comment: "")
        case .Listen(let listetning):
            if listetning {
                return NSLocalizedString("Stop Listening", comment: "")
            } else {
                return NSLocalizedString("Listen", comment: "")
            }
        }
    }
    
    var image: UIImage {
        switch self {
        case .Listeners:
            return UIImage.profileListenersIcon()
        case .Listening:
            return UIImage.profileListeningIcon()
        case .Interests:
            return UIImage.profileTagsIcon()
        case .Chat:
            return UIImage.profileChatIcon()
        case .Listen(let listetning):
            if listetning {
                return UIImage.profileStopListeningIcon()
            } else {
                return UIImage.profileListenIcon()
            }
        }
    }
}

class ProfileCollectionInfoSupplementaryView: UICollectionReusableView {
    
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
    
    // section 3
    @IBOutlet weak var bioLabel: UILabel!
    @IBOutlet weak var bioIconImageView: UIImageView!
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
        
        avatarHeightConstraint.constant = min(1.0, attributes.scaleFactor) * normalAvatarHeight
    }
    
    func setButtons(buttons:[ProfileCollectionInfoButton]) {
        assert(buttons.count == 3)
        
        let uiButtons = [buttonSectionLeftButton, buttonSectionCenterButton, buttonSectionRightButton]
        for index in 0..<3 {
            let uiButton = uiButtons[index]
            let button = buttons[index]
            
            uiButton.setTitleText(button.title)
            uiButton.setImage(button.image)
            
            if case .Listeners(let countString) = button {
                uiButton.setCountText(countString)
            } else if case .Listening(let countString) = button {
                uiButton.setCountText(countString)
            } else if case .Interests(let countString) = button {
                uiButton.setCountText(countString)
            }
        }
    }
}