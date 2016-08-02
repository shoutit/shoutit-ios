//
//  ProfileCollectionInfoSupplementeryViewButtons.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

enum ProfileCollectionInfoSupplementeryViewAvatar {
    case Remote(url: NSURL?)
    case Local(image: UIImage?)
}

protocol ProfileCollectionInfoSupplementaryViewDataSource: class {
    
    var avatar: ProfileCollectionInfoSupplementeryViewAvatar {get}
    var infoButtons: [ProfileCollectionInfoButton] {get}
    var hidesVerifyAccountButton: Bool {get}
    var descriptionText: String? {get}
    var descriptionIcon: UIImage? {get}
    var websiteString: String? {get}
    var dateJoinedString: String? {get}
    var locationString: String? {get}
    var locationFlag: UIImage? {get}
}

enum ProfileCollectionInfoButton {
    case Listeners(countString: String)
    case Listening(countString: String)
    case Interests(countString: String)
    case Chat
    case Listen(isListening: Bool)
    case Notification(position: ProfileCollectionInfoButtonPosition?)
    case EditProfile
    case More
    case Custom(title: String, icon: UIImage?)
    case HiddenButton(position: ProfileCollectionInfoButtonPosition)
    
    var title: String {
        switch self {
        case .Listeners:
            return NSLocalizedString("Listeners", comment: "Profile Button Title")
        case .Listening:
            return NSLocalizedString("Listening", comment: "Profile Button Title")
        case .Interests:
            return NSLocalizedString("Interests", comment: "Profile Button Title")
        case .Chat:
            return NSLocalizedString("Chat", comment: "Profile Button Title")
        case .Listen(let listetning):
            if listetning {
                return NSLocalizedString("Stop Listening", comment: "Profile Button Title")
            } else {
                return NSLocalizedString("Listen", comment: "Profile Button Title")
            }
        case .Custom(let title, _):
            return title
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
        case .Custom(_, let icon):
            return icon ?? UIImage()
        case .HiddenButton:
            return UIImage()
        }
    }
    
    var position: ProfileCollectionInfoButtonPosition {
        switch self {
        case .Notification(let position?):
            return position
        default:
            return defaultPosition
        }
    }
    
    private var defaultPosition: ProfileCollectionInfoButtonPosition {
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
        case .Custom:
            return .BigCenter
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