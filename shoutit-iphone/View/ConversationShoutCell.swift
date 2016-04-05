//
//  ConversationShoutCell.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 25/03/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class ConversationShoutCell: ConversationImageCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    
    override func bindWithMessage(message: Message, previousMessage: Message?) {
        super.bindWithMessage(message, previousMessage: previousMessage)
        
        guard let shout = message.attachment()?.shout else {
            self.pictureImageView.image = nil
            return
        }
        
        self.titleLabel.text = shout.title
        
        self.subtitleLabel?.text = shout.user.name
        
        
        self.priceLabel.text = NumberFormatters.priceStringWithPrice(shout.price, currency: shout.currency)
    }
}
