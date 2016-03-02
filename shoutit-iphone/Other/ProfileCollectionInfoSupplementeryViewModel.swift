//
//  ProfileCollectionInfoSupplementeryViewButtons.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 25.02.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

protocol ProfileCollectionInfoSupplementaryViewDataSource: class {
    var avatarURL: NSURL? {get}
    var infoButtons: [ProfileCollectionInfoButton] {get}
    var descriptionText: String? {get}
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