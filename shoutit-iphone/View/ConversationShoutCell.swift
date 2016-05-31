//
//  ConversationShoutCell.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 25/03/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class ConversationShoutCell: UITableViewCell, ConversationCell {

    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    @IBOutlet weak var avatarImageView: UIImageView?
    @IBOutlet weak var timeLabel: UILabel?
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    
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
        
        guard let shout = message.attachment()?.shout else {
            self.pictureImageView.image = nil
            return
        }
        
        self.titleLabel.text = shout.title
        self.subtitleLabel?.text = shout.user?.name
        self.priceLabel.text = NumberFormatters.priceStringWithPrice(shout.price, currency: shout.currency)
    }
    
    func setThumbMessage(message: Message) {
        guard let imagePath = message.attachment()?.imagePath(), url = NSURL(string: imagePath) where imagePath.utf16.count > 0 else {
            activityIndicator?.stopAnimating()
            activityIndicator?.hidden = true
            return
        }
        
        pictureImageView.sh_setImageWithURL(url, placeholderImage: UIImage.shoutsPlaceholderImage(), optionsInfo: nil) {[weak self] (image, error, cacheType, imageURL) in
            self?.activityIndicator?.stopAnimating()
            self?.activityIndicator?.hidden = true
        }
    }
}
