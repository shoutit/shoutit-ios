//
//  ProfileCollectionInfoSupplementaryView.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 12.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

protocol ProfileCollectionInfoSupplementaryViewDataSource: class {
    var avatarURL: NSURL? {get}
    var infoButtons: [ProfileCollectionInfoButton] {get}
    var descriptionText: String? {get}
    var websiteString: String? {get}
    var dateJoinedString: String? {get}
    var locationString: String? {get}
    var locationFlag: UIImage? {get}
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
    @IBOutlet weak var bioSectionHeightConstrait: NSLayoutConstraint!
    @IBOutlet weak var websiteSectionHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateJoinedSectionHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationSectionHeightConstraint: NSLayoutConstraint!
    
    
    override func applyLayoutAttributes(layoutAttributes: UICollectionViewLayoutAttributes) {
        super.applyLayoutAttributes(layoutAttributes)
        
        let attributes = layoutAttributes as! ProfileCollectionViewLayoutAttributes
        
        let normalAvatarHeight: CGFloat = 76.0
        
        avatarHeightConstraint.constant = min(1.0, attributes.scaleFactor) * normalAvatarHeight
    }
    
    func setButtons(buttons:[ProfileCollectionInfoButton]) {
        
        for button in buttons {
            switch button.defaultPosition {
            case .SmallLeft:
                hydrateButton(notificationButton, withButtonModel: button)
            case .SmallRight:
                hydrateButton(rightmostButton, withButtonModel: button)
            case .BigLeft:
                hydrateButton(buttonSectionLeftButton, withButtonModel: button)
            case .BigCenter:
                hydrateButton(buttonSectionCenterButton, withButtonModel: button)
            case .BigRight:
                hydrateButton(buttonSectionRightButton, withButtonModel: button)
            }
        }
    }
    
    private func hydrateButton(button: UIButton, withButtonModel buttonModel: ProfileCollectionInfoButton) {
        
        if case .HiddenButton = buttonModel {
            button.hidden = true
            return
        }
        
        if let button = button as? ProfileInfoHeaderButton {
            button.setTitleText(buttonModel.title)
            button.setImage(buttonModel.image)
            
            if case .Listeners(let countString) = buttonModel {
                button.setCountText(countString)
            } else if case .Listening(let countString) = buttonModel {
                button.setCountText(countString)
            } else if case .Interests(let countString) = buttonModel {
                button.setCountText(countString)
            }
        } else {
            button.setImage(buttonModel.image, forState: .Normal)
        }
    }
}

enum ProfileCollectionInfoButton {
    case Listeners(countString: String)
    case Listening(countString: String)
    case Interests(countString: String)
    case Chat
    case Listen(isListening: Bool)
    case Notification
    case EditProfile
    case More
    case HiddenButton(position: ProfileCollectionInfoButtonPosition)
    
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
        default:
            return ""
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
        case .Notification:
            return UIImage.profileNotificationIcon()
        case .EditProfile:
            return UIImage.profileEditUserIcon()
        case .More:
            return UIImage.profileMoreIcon()
        case .HiddenButton:
            return UIImage()
        }
    }
    
    var defaultPosition: ProfileCollectionInfoButtonPosition {
        switch self {
        case .Listeners:
            return .BigLeft
        case .Listening:
            return .BigCenter
        case .Interests:
            return .BigRight
        case .Chat:
            return .BigCenter
        case .Listen:
            return .BigRight
        case .Notification:
            return .SmallLeft
        case .EditProfile:
            return .SmallRight
        case .More:
            return .SmallRight
        case .HiddenButton(let position):
            return position
        }
    }
}

enum ProfileCollectionInfoButtonPosition {
    case SmallLeft
    case SmallRight
    case BigLeft
    case BigCenter
    case BigRight
}
