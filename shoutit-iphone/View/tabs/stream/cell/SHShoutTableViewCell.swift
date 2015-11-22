//
//  SHShoutTableViewCell.swift
//  shoutit-iphone
//
//  Created by Vishal Thakur on 16/11/15.
//  Copyright © 2015 Shoutit. All rights reserved.
//

import UIKit

class SHShoutTableViewCell: UITableViewCell {
    
    @IBOutlet weak var clockImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var imageViewShout: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
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
    
    func setShout(shout: SHShout) {
        if(shout.thumbnail != "") {
            self.imageViewShout.kf_setImageWithURL(NSURL(string: (shout.thumbnail))!, placeholderImage: UIImage(named: "image_placeholder"))
        } else {
            self.imageViewShout.image = UIImage(named: "no_image_available_thumb")
        }
        self.imageViewShout.contentMode = UIViewContentMode.ScaleAspectFill
        self.imageViewShout.clipsToBounds = true
        self.imageViewShout.layer.cornerRadius = self.imageViewShout.frame.size.width / 15.0
        
        let imgMask = UIImage(named: "shoutMask")
        let mask = CALayer()
        mask.contents = imgMask?.CGImage
        mask.frame = CGRectMake(0, 0, self.imageViewShout.frame.size.width, self.imageViewShout.frame.size.height)
        self.imageViewShout.layer.mask = mask
        self.imageViewShout.layer.masksToBounds = true
        
        if shout.datePublished > 0 {
            self.timeLabel.text = NSDate(timeIntervalSince1970: shout.datePublished).timeAgoSimple
        } else {
            self.timeLabel.text = "-"
        }
        let numberFormatter = NSNumberFormatter()
        numberFormatter.numberStyle = .DecimalStyle
        if let number = numberFormatter.numberFromString(String(format: "%g", shout.price)) {
            let price = String(format: "%@ %@", shout.currency, number.stringValue)
            self.priceLabel.text = price
        }
        self.descriptionLabel.text = shout.text
        self.titleLabel.text = shout.title
        if let city = shout.location?.city {
            self.locationLabel.text = String(format: "%@", arguments: [city])
        }
    }
    
    func setHiddenTime (hidden: Bool) {
        self.clockImageView.hidden = true
        self.timeLabel.hidden = true
    }
    
}
