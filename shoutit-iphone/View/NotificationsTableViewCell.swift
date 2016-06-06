//
//  NotificationsTableViewCell.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 14.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ShoutitKit

final class NotificationsTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var notificationImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    
    func bindWithNotificationMessage(message: Notification) {
        self.titleLabel.attributedText = message.attributedText()
        self.notificationImage.sh_setImageWithURL(message.imageURL(), placeholderImage: UIImage.squareAvatarPlaceholder())
        
        if message.read == true {
            self.contentView.backgroundColor = UIColor.whiteColor()
        } else {
            self.contentView.backgroundColor = UIColor(red: 200/255, green: 230/255, blue: 201/255, alpha: 1)
        }
        
        dateLabel.text = DateFormatters.sharedInstance.stringFromDateEpoch(message.createdAt)
        
    }

}
