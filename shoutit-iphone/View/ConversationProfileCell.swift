//
//  ConversationProfileCell.swift
//  shoutit-iphone
//
//  Created by Łukasz Kasperek on 09.05.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import Foundation

final class ConversationProfileCell: UITableViewCell, ConversationCell {
    
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    @IBOutlet weak var avatarImageView: UIImageView?
    @IBOutlet weak var timeLabel: UILabel?
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    
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
        
        guard let profile = message.attachment()?.profile else {
            self.pictureImageView.image = nil
            return
        }
        
        self.titleLabel.text = profile.name
        self.subtitleLabel?.text = String.localizedStringWithFormat(NSLocalizedString("%@ Listeners", comment: ""), NumberFormatters.numberToShortString(profile.listenersCount))
    }
    
    func setThumbMessage(message: Message) {
        guard let imagePath = message.attachment()?.imagePath(), url = NSURL(string: imagePath) else {
            return
        }
        
        pictureImageView.sh_setImageWithURL(url, placeholderImage: UIImage.shoutsPlaceholderImage(), optionsInfo: nil) { (image, error, cacheType, imageURL) in
            self.activityIndicator?.stopAnimating()
            self.activityIndicator?.hidden = true
        }
    }
}
