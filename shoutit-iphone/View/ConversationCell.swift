//
//  ConversationCell.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 16.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import RxSwift

struct ConversationCellIdentifier {
    struct Wireframe {
        static let daySection = "conversationSectionDayIdentifier"
    }
    struct Text {
        static let outgoing = "conversationOutGoingCell"
        static let incoming = "conversationIncomingCell"
    }
    struct Location {
        static let outgoing = "conversationOutGoingLocationCell"
        static let incoming = "conversationIncomingLocationCell"
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
    struct Profile {
        static let outgoing = "OutgoingProfileCell"
        static let incoming = "IncomingProfileCell"
    }
}

protocol ConversationCell: class {
    weak var imageHeightConstraint: NSLayoutConstraint? {get set}
    weak var activityIndicator: UIActivityIndicatorView? {get set}
    weak var avatarImageView: UIImageView? {get set}
    var avatarButton: UIButton? { get set }
    weak var timeLabel: UILabel? {get set}
    var reuseDisposeBag: DisposeBag { get set }
    
    func hydrateAvatarImageView(imageView: UIImageView, withAvatarPath path: String?)
    func hideImageView()
    func unHideImageView()
}

protocol ThumbedConversationCell: ConversationCell {
    weak var pictureImageView: UIImageView! { get set }
}

extension ConversationCell where Self: UIView {
    
    func addAvatarButtonToAvatarImageView() {
        avatarButton = UIButton()
        avatarButton?.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView?.addSubview(avatarButton!)
        let views: [String : AnyObject] = ["button" : avatarButton!]
        avatarImageView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[button]|", options: [], metrics: nil, views: views))
        avatarImageView?.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[button]|", options: [], metrics: nil, views: views))
    }
    
    func hydrateAvatarImageView(imageView: UIImageView, withAvatarPath path: String?) {
        if let imagePath = path, imgUrl = NSURL(string: imagePath) {
            imageView.sh_setImageWithURL(imgUrl, placeholderImage: UIImage.squareAvatarPlaceholder())
        } else {
            imageView.image = UIImage.squareAvatarPlaceholder()
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
