//
//  ConversationTextCell.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 16.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class ConversationTextCell: ConversationCell {
    
    @IBOutlet weak var messageLabel: UILabel!
    
    override func bindWithMessage(message: Message, previousMessage: Message?) {
        if let imgview = self.avatarImageView {
            setImageWith(imgview, message: message)
        }
        
        messageLabel.text = message.text
        
        self.timeLabel?.text = DateFormatters.sharedInstance.hourStringFromEpoch(message.createdAt)
        
        if message.isSameSenderAs(previousMessage) {
            hideImageView()
        }
    }
}
