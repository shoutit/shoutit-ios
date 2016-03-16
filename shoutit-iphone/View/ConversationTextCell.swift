//
//  ConversationTextCell.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 16.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class ConversationTextCell: ConversationCell {

    @IBOutlet weak var avatarImageView: UIImageView?
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel?
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint?
    
    override func bindWithMessage(message: Message, previousMessage: Message?) {
        if let imgview = avatarImageView {
            setImageWith(imgview, message: message)
        }
        
        messageLabel.text = message.text
        
        timeLabel?.text = DateFormatters.sharedInstance.hourStringFromEpoch(message.createdAt)
        
        if message.isSameSenderAs(previousMessage) {
            hideImageView()
        }
    }
    
    func setImageWith(imgview: UIImageView, message: Message) {
        if let imagePath = message.user?.imagePath, imgUrl = NSURL(string: imagePath) {
            imgview.sh_setImageWithURL(imgUrl, placeholderImage: nil)
        } else {
            hideImageView()
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        unHideImageView()
    }
}
