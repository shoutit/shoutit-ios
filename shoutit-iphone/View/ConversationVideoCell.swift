//
//  ConversationVideoCell.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 25/03/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class ConversationVideoCell: UITableViewCell, ConversationCell {
    
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    @IBOutlet weak var avatarImageView: UIImageView?
    @IBOutlet weak var timeLabel: UILabel?
    @IBOutlet weak var pictureImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .None
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        unHideImageView()
    }
    
    func bindWithMessage(message: Message, previousMessage: Message?) {
        if let imgview = avatarImageView {
            setImageWith(imgview, message: message)
        }
        
        timeLabel?.text = DateFormatters.sharedInstance.hourStringFromEpoch(message.createdAt)
        
        if message.isSameSenderAs(previousMessage) {
            hideImageView()
        }
        
        activityIndicator?.startAnimating()
        activityIndicator?.hidden = false
        
        setThumbMessage(message)
    }
    
    func setThumbMessage(message: Message) {
        guard let imagePath = message.attachment()?.imagePath(), url = NSURL(string: imagePath) else {
            return
        }
        
        self.pictureImageView.sh_setImageWithURL(url, placeholderImage: UIImage.shoutsPlaceholderImage(), optionsInfo: nil) {[weak self] (image, error, cacheType, imageURL) in
            self?.activityIndicator?.stopAnimating()
            self?.activityIndicator?.hidden = true
        }
    }
}
