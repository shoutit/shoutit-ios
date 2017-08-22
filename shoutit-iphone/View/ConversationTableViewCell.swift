//
//  ConversationTableViewCell.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 14.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ShoutitKit

final class ConversationTableViewCell: UITableViewCell {
    @IBOutlet weak var firstLineLabel: UILabel!
    @IBOutlet weak var secondLineLabel: UILabel!
    @IBOutlet weak var thirdLineLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var participantsImageView: UIImageView!

    func bindWithConversation(_ conversation: MiniConversation) {
        self.firstLineLabel.text = conversation.display.title
        self.secondLineLabel.text = conversation.display.subtitle
        self.thirdLineLabel.text = conversation.display.lastMessageSummary
        
        if let modifiedEpoch = conversation.modifiedAt {
            self.dateLabel.text = DateFormatters.sharedInstance.stringFromDateEpoch(modifiedEpoch)
        }
        self.participantsImageView.sh_setImageWithURL(conversation.imageURL(), placeholderImage: UIImage.squareAvatarPlaceholder())
        
        if conversation.isRead() {
            self.backgroundColor = UIColor.white
        } else {
            self.backgroundColor = UIColor(shoutitColor: .lightGreen)
        }
    }
    
    override func prepareForReuse() {
        self.participantsImageView.image = nil
    }
}
