//
//  ProfileCollectionInfoSupplementeryViewButtons.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

enum ProfileCollectionInfoSupplementeryViewAvatar {
    case remote(url: URL?)
    case local(image: UIImage?)
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
    case listeners(countString: String)
    case listening(countString: String)
    case interests(countString: String)
    case chat
    case listen(isListening: Bool)
    case notification(position: ProfileCollectionInfoButtonPosition?)
    case editProfile
    case more
    case custom(title: String, icon: UIImage?)
    case hiddenButton(position: ProfileCollectionInfoButtonPosition)
    
    var title: String {
        switch self {
        case .listeners:
            return NSLocalizedString("Listeners", comment: "Profile Button Title")
        case .listening:
            return NSLocalizedString("Listening", comment: "Profile Button Title")
        case .interests:
            return NSLocalizedString("Interests", comment: "Profile Button Title")
        case .chat:
            return NSLocalizedString("Chat", comment: "Profile Button Title")
        case .listen(let listetning):
            if listetning {
                return NSLocalizedString("Stop Listening", comment: "Profile Button Title")
            } else {
                return NSLocalizedString("Listen", comment: "Profile Button Title")
            }
        case .custom(let title, _):
            return title
        default:
            return ""
        }
    }
    
    var image: UIImage {
        switch self {
        case .listeners:
            return UIImage.profileListenersIcon()
        case .listening:
            return UIImage.profileListeningIcon()
        case .interests:
            return UIImage.profileTagsIcon()
        case .chat:
            return UIImage.profileChatIcon()
        case .listen(let listetning):
            if listetning {
                return UIImage.profileStopListeningIcon()
            } else {
                return UIImage.profileListenIcon()
            }
        case .notification:
            return UIImage.profileNotificationIcon()
        case .editProfile:
            return UIImage.profileEditUserIcon()
        case .more:
            return UIImage.profileMoreIcon()
        case .custom(_, let icon):
            return icon ?? UIImage()
        case .hiddenButton:
            return UIImage()
        }
    }
    
    var position: ProfileCollectionInfoButtonPosition {
        switch self {
        case .notification(let position?):
            return position
        default:
            return defaultPosition
        }
    }
    
    fileprivate var defaultPosition: ProfileCollectionInfoButtonPosition {
        switch self {
        case .listeners:
            return .bigLeft
        case .listening:
            return .bigCenter
        case .interests:
            return .bigRight
        case .chat:
            return .bigCenter
        case .listen:
            return .bigRight
        case .notification:
            return .smallLeft
        case .editProfile:
            return .smallRight
        case .more:
            return .smallRight
        case .custom:
            return .bigCenter
        case .hiddenButton(let position):
            return position
        }
    }
}

enum ProfileCollectionInfoButtonPosition {
    case smallLeft
    case smallRight
    case bigLeft
    case bigCenter
    case bigRight
}
