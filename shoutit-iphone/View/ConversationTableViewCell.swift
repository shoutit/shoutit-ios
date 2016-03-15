//
//  ConversationTableViewCell.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 14.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class ConversationTableViewCell: UITableViewCell {
    @IBOutlet weak var firstLineLabel: UILabel!
    @IBOutlet weak var secondLineLabel: UILabel!
    @IBOutlet weak var thirdLineLabel: UILabel?
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var participantsImageView: UIImageView!

    func bindWithConversation(conversation: Conversation) {
        self.firstLineLabel.attributedText = conversation.firstLineText()
        self.secondLineLabel.attributedText = conversation.secondLineText()
        self.thirdLineLabel?.attributedText = conversation.thirdLineText()

        self.dateLabel.text = DateFormatters.sharedInstance.stringFromDateEpoch(conversation.modifiedAt)
        self.participantsImageView.sh_setImageWithURL(conversation.imageURL(), placeholderImage: UIImage(named: ""))
    }
}
