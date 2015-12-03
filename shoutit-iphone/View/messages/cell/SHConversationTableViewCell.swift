//
//  SHConversationTableViewCell.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 03/12/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHConversationTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imageConvView: UIImageView!
    @IBOutlet weak var isReadImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func setConversation(conversation: SHConversations) {
        self.imageConvView.backgroundColor = UIColor(hexString: Constants.Style.COLOR_SHOUT_DARK_GREEN)
        if let lastMessage = conversation.lastMessage?.createdAt {
            let date = NSDate(timeIntervalSince1970: NSTimeInterval(lastMessage))
            self.timeLabel.text = date.timeAgo
            self.descriptionLabel.text = conversation.lastMessage?.text
            self.imageConvView.contentMode = UIViewContentMode.ScaleAspectFill
            self.imageConvView.clipsToBounds = true
            self.imageConvView.layer.cornerRadius = self.imageConvView.frame.size.width / 15.0
        }
        
        if(conversation.users.count > 1 && conversation.users.count < 3) {
            if(conversation.users[0].username != SHOauthToken.getFromCache()?.user?.username) {
                if let urlString = conversation.users[0].image {
                    self.avatarImageView.setImageWithURL(NSURL(string: urlString), placeholderImage: UIImage(named: "no_image_available_thumb"), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.White)
                    self.nameLabel.text = conversation.users[0].name
                    if(conversation.type == "chat") {
                        self.imageConvView.setImageWithURL(NSURL(string: urlString), placeholderImage: UIImage(named: "image_placeholder"), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                        self.timeLabel.text = conversation.users[0].name
                    }
                } else {
                    if let urlString = conversation.users[1].image {
                        self.avatarImageView.setImageWithURL(NSURL(string: urlString), placeholderImage: UIImage(named: "no_image_available_thumb"), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.White)
                        self.nameLabel.text = conversation.users[1].name
                        if(conversation.type == "chat") {
                            self.imageConvView.setImageWithURL(NSURL(string: urlString), placeholderImage: UIImage(named: "image_placeholder"), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                            self.titleLabel.text = conversation.users[1].name
                        }
                    }
                }
                self.avatarImageView.contentMode = UIViewContentMode.ScaleAspectFill
            }
        } else {
            
        }
    }
    
       
}
