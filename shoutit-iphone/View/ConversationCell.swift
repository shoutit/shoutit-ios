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
