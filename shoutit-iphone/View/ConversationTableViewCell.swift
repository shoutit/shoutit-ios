//
//  ConversationTableViewCell.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 14.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class ConversationTableViewCell: UITableViewCell {
    @IBOutlet weak var participantsLabel: UILabel!
    @IBOutlet weak var messagePreviewLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var participantsImageView: UIImageView!

    func bindWithConversation(conversation: Conversation) {
        self.messagePreviewLabel.text = conversation.lastMessage?.text
        self.participantsLabel.text = conversation.participantsText()
        self.dateLabel.text = DateFormatters.sharedInstance.stringFromDateEpoch(conversation.modifiedAt)
    }
}
