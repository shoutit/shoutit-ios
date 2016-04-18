//
//  ConversationShoutHeader.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 21.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

final class ConversationShoutHeader: UIView {

    @IBOutlet weak var tapGesture: UITapGestureRecognizer!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderWidth = 1.0 / UIScreen.mainScreen().scale
        self.layer.borderColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.5).CGColor
        self.layer.cornerRadius = 3.0
    }
    
    func bindWith(Shout shout: Shout) {
        self.titleLabel.text = shout.title
        
        self.subtitleLabel.text = shout.user.name
        
        self.priceLabel.text = NumberFormatters.priceStringWithPrice(shout.price, currency: shout.currency)

        
        
        if let thumbPath = shout.thumbnailPath, thumbURL = NSURL(string: thumbPath) {
            self.imageView.sh_setImageWithURL(thumbURL, placeholderImage: UIImage(named:"auth_screen_bg_pattern"))
        } else {
            self.imageView.image = UIImage(named:"auth_screen_bg_pattern")
        }
        
        self.typeLabel.text = shout.type()?.title()
        
    }

}
