//
//  ConversationShoutHeader.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 21.03.2016.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit
import ShoutitKit

final class ConversationShoutHeader: UIView {

    @IBOutlet weak var tapGesture: UITapGestureRecognizer!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.borderWidth = 1.0 / UIScreen.main.scale
        self.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.5).cgColor
        self.layer.cornerRadius = 3.0
    }
    
    func bindWith(Shout shout: Shout) {
        
        titleLabel.text = shout.title
        subtitleLabel.text = shout.user?.name
        priceLabel.text = NumberFormatters.priceStringWithPrice(shout.price, currency: shout.currency)

        if let thumbPath = shout.thumbnailPath, let thumbURL = URL(string: thumbPath) {
            imageView.sh_setImageWithURL(thumbURL, placeholderImage: UIImage(named:"auth_screen_bg_pattern"))
        } else {
            imageView.image = UIImage(named:"auth_screen_bg_pattern")
        }
        
        typeLabel.text = shout.type()?.title()
    }
}
