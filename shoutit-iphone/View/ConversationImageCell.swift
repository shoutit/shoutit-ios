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
        if let imgview = avatarImageView {
            setImageWith(imgview, message: message)
        }
        
        timeLabel?.text = DateFormatters.sharedInstance.hourStringFromEpoch(message.createdAt)
        
        if message.isSameSenderAs(previousMessage) {
            hideImageView()
        }
        
        self.activityIndicator?.startAnimating()
        self.activityIndicator?.hidden = false
        
        
        setThumbMessage(message)
        
    }
    
    func setThumbMessage(message: Message) {
        guard let imagePath = message.attachment()?.imagePath(), url = NSURL(string: imagePath) else {
            return
        }
        
        pictureImageView.sh_setImageWithURL(url, placeholderImage: UIImage.shoutsPlaceholderImage(), optionsInfo: nil) { (image, error, cacheType, imageURL) in
            self.activityIndicator?.stopAnimating()
            self.activityIndicator?.hidden = true
        }
    }
}
