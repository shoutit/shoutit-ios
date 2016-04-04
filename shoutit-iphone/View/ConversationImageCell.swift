//
//  ConversationImageCell.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 24.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class ConversationImageCell: ConversationCell {
    @IBOutlet weak var pictureImageView: UIImageView!
 
    override func bindWithMessage(message: Message, previousMessage: Message?) {
        if let imgview = super.avatarImageView {
            super.setImageWith(imgview, message: message)
        }
        
        super.timeLabel?.text = DateFormatters.sharedInstance.hourStringFromEpoch(message.createdAt)
        
        if message.isSameSenderAs(previousMessage) {
            super.hideImageView()
        }
        
        super.activityIndicator?.startAnimating()
        super.activityIndicator?.hidden = false
        
        
        self.setThumbMessage(message)
    }
    
    func setThumbMessage(message: Message) {
        guard let imagePath = message.attachment()?.imagePath(), url = NSURL(string: imagePath) else {
            return
        }
        
        self.pictureImageView.sh_setImageWithURL(url, placeholderImage: UIImage.shoutsPlaceholderImage(), optionsInfo: nil) { (image, error, cacheType, imageURL) in
            super.activityIndicator?.stopAnimating()
            super.activityIndicator?.hidden = true
        }
    }
}
