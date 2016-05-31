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
        
        guard let profile = message.attachment()?.profile else {
            pictureImageView.image = nil
            return
        }
        
        activityIndicator?.startAnimating()
        activityIndicator?.hidden = false
        
        titleLabel.text = profile.name
        subtitleLabel?.text = String.localizedStringWithFormat(NSLocalizedString("%@ Listeners", comment: ""), NumberFormatters.numberToShortString(profile.listenersCount))
        pictureImageView.sh_setImageWithURL(profile.imagePath?.toURL(), placeholderImage: UIImage.profilePlaceholderImage(), optionsInfo: nil) {[weak self] (image, error, cacheType, imageURL) in
            self?.activityIndicator?.stopAnimating()
            self?.activityIndicator?.hidden = true
        }
    }
}
