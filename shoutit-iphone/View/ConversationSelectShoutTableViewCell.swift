//
//  ConversationSelectShoutTableViewCell.swift
//  shoutit-iphone
//
//  Created by Piotr Bernad on 25/03/16.
//  Copyright © 2016 Shoutit. All rights reserved.
//

import UIKit

class ConversationSelectShoutTableViewCell: UITableViewCell {

    
    @IBOutlet var shoutImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var shoutTypeLabel: UILabel!
    
    
    func bindWith(shout: Shout) {
        self.titleLabel.text = shout.title
        
        self.subtitleLabel?.text = shout.user.name
        

        self.priceLabel.text = NumberFormatters.priceStringWithPrice(shout.price, currency: shout.currency)
        
  
        if let thumbPath = shout.thumbnailPath, thumbURL = NSURL(string: thumbPath) {
            self.shoutImageView.sh_setImageWithURL(thumbURL, placeholderImage: UIImage(named:"auth_screen_bg_pattern"))
        } else {
            self.shoutImageView.image = UIImage(named:"auth_screen_bg_pattern")
        }
        
        self.shoutTypeLabel?.text = shout.type()?.title()
    }

}
