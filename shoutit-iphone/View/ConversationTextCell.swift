//
//  ConversationTextCell.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 16.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class ConversationTextCell: UITableViewCell, ConversationCell {
    
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    @IBOutlet weak var avatarImageView: UIImageView?
    @IBOutlet weak var timeLabel: UILabel?
    @IBOutlet weak var messageLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        unHideImageView()
    }
    
    func bindWithMessage(message: Message, previousMessage: Message?) {
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
