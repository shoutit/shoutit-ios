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
        self.imageConvView.backgroundColor = UIColor(shoutitColor: .ShoutDarkGreen)
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
                        self.titleLabel.text = conversation.users[0].name
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
            self.avatarImageView.image = UIImage(named: "logo.png")
            self.nameLabel.text = String(format: "%d %@ in chat", arguments: [conversation.users.count, conversation.users.count == 1 ? "person": "people"])
            self.avatarImageView.contentMode = UIViewContentMode.ScaleAspectFill
            if(conversation.type == "chat") {
                self.titleLabel.text = self.nameLabel.text
            }
        }
        self.avatarImageView.clipsToBounds = true
        self.avatarImageView.layer.borderColor = UIColor(shoutitColor: .ShoutDetailProfileImageLightGrey).CGColor
        self.avatarImageView.layer.borderWidth = 2.0
        self.avatarImageView.layer.cornerRadius = self.avatarImageView.frame.size.width / 2.0
        self.isReadImageView.contentMode = UIViewContentMode.ScaleAspectFill
        self.isReadImageView.clipsToBounds = true
        self.isReadImageView.layer.cornerRadius = self.isReadImageView.frame.size.width / 2.0
        if let isRead = conversation.isRead {
            self.isReadImageView.hidden = isRead
        }
        
        if(conversation.type != "chat") {
            if let thumbnail = conversation.about?.thumbnail {
                if(thumbnail != "") {
                    self.imageConvView.setImageWithURL(NSURL(string: thumbnail), placeholderImage: UIImage(named: "image_placeholder"), usingActivityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
                } else {
                    self.imageConvView.image = UIImage(named: "no_image_available_thumb")
                }
            }
            self.titleLabel.text = conversation.about?.title
        } else {
            self.nameLabel.hidden = true
            self.avatarImageView.hidden = true
        }
    }
    
       
}
