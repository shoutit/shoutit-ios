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

class ConversationCell: UITableViewCell, MessagePresenting {
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    @IBOutlet weak var avatarImageView: UIImageView?
    @IBOutlet weak var timeLabel: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
    }
    
    func bindWithMessage(message: Message, previousMessage: Message?) {
        // due to xcode building issues subclasses must call super, so fatal error can't be here
        //fatalError("Please Implement this method in subclass")
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
