//
//  ConversationCell.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 16.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

protocol MessagePresenting {
    func bindWithMessage(message: Message, previousMessage: Message?)
}

struct ConversationCellIdentifier {
    struct Wireframe {
        static let daySection = "conversationSectionDayIdentifier"
    }
    struct Text {
        static let outgoing = "conversationOutGoingCell"
        static let incoming = "conversationIncomingCell"
    }
    struct Location {
        static let outgoing = "conversationIncomingLocationCell"
        static let incoming = "conversationOutGoingLocationCell"
    }
    struct Picture {
        static let outgoing = "conversationOutGoingPictureCell"
        static let incoming = "conversationIncomingPictureCell"
    }
    struct Video {
        static let outgoing = "conversationOutGoingVideoCell"
        static let incoming = "conversationIncomingVideoCell"
    }
    struct Shout {
        static let outgoing = "conversationOutGoingShoutCell"
        static let incoming = "conversationIncomingShoutCell"
    }
}

protocol ConversationCell: MessagePresenting {
    weak var imageHeightConstraint: NSLayoutConstraint? {get set}
    weak var activityIndicator: UIActivityIndicatorView? {get set}
    weak var avatarImageView: UIImageView? {get set}
    weak var timeLabel: UILabel? {get set}
    
    func setImageWith(imgview: UIImageView, message: Message)
    func hideImageView()
    func unHideImageView()
}

extension ConversationCell where Self: UIView {
    
    func setImageWith(imgview: UIImageView, message: Message) {
        if let imagePath = message.user?.imagePath, imgUrl = NSURL(string: imagePath) {
            imgview.sh_setImageWithURL(imgUrl, placeholderImage: UIImage.squareAvatarPlaceholder())
        } else {
            imgview.image = UIImage.squareAvatarPlaceholder()
        }
    }
    
    func hideImageView() {
        avatarImageView?.hidden = true
        
        imageHeightConstraint?.constant = 5.0
        
        layoutIfNeeded()
    }
    
    func unHideImageView() {
        avatarImageView?.hidden = false
        
        imageHeightConstraint?.constant = 40.0
        
        layoutIfNeeded()
    }
}
